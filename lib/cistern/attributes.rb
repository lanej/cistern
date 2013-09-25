module Cistern::Attributes
  def self.parsers
    @parsers ||= {
      :string  => lambda { |v| v.to_s },
      :time    => lambda { |v| v.is_a?(Time) ? v : v && Time.parse(v.to_s) },
      :integer => lambda { |v| v && v.to_i },
      :float   => lambda { |v| v && v.to_f },
      :array   => lambda { |v| [*v] },
      :boolean => lambda { |v| ['true', '1'].include?(v.to_s.downcase) }
    }
  end

  def self.processors
    @processors ||= {
      :drill => Proc.new do |mc, n, p|
        path      = [*p]
        root      = path.first.to_s.to_sym
        drill_bit = Proc.new do |h, x|
          head = x.shift
          if h.is_a?(::Hash)
            if h.key?(head.to_s.to_sym)
              drill_bit.call(h[head.to_s.to_sym], x)
            elsif h.has_key?(head.to_s)
              drill_bit.call(h[head.to_s], x)
            end
          elsif x.empty?
            h
          end
        end

        # root processor sets path of associated attribute and leaves return value intact
        mc.attribute_writer(root)
        mc.processors[root].unshift(lambda { |m, v| m.send("#{n}=", drill_bit.call(v, path.dup[1..-1])); v })
      end,
      :parser => Proc.new do |mc, n, block|
        mc.processors[n].push(lambda { |m, v| block.call(v) })
      end,
      :type => Proc.new do |mc, n, args|
        mc.processors[n].push(lambda { |m, v| Cistern::Attributes.parsers[args || :string].call(v) })
      end,
    }
  end

  module ClassMethods
    def _load(marshalled)
      new(Marshal.load(marshalled))
    end

    def aliases
      @aliases ||= Hash.new { |h, k| h[k] = [] }
    end

    def attributes
      @attributes ||= {}
    end

    def processors
      @processors ||= Hash.new { |h, k| h[k] = [] }
    end

    def attribute_writer(name)
      unless self.instance_methods.include?("#{name}=")
        self.send(:define_method, "#{name}=") { |v| attribute_set(name, self.class.processors[name].inject(v) { |r, p| p.call(self, r) }) }
      end
    end

    def attribute_reader(name)
      self.send(:define_method, name) { attributes[name.to_s.to_sym] }
    end

    def attribute(name, options = {})
      attributes[name.to_s.to_sym] = options

      transform_options = (options.keys & Cistern::Attributes.processors.keys).inject({}) { |r, k| r.merge(k => options[k]) }
      transform_options.each { |k, opts| Cistern::Attributes.processors[k].call(self, name.to_s.to_sym, opts) }

      # default accessor
      attribute_reader(name.to_s.to_sym)
      attribute_writer(name.to_s.to_sym)

      Array(options[:aliases]).each do |new_alias|
        aliases[new_alias] << name
      end
    end

    def identity(name, options = {})
      @identity = name
      self.attribute(name, options)
    end

    def ignore_attributes(*args)
      @ignored_attributes = args
    end

    def ignored_attributes
      @ignored_attributes ||= []
    end
  end

  module InstanceMethods
    def _dump(level)
      Marshal.dump(attributes)
    end

    def attribute_set(name, value)
      attributes[name.to_s.to_sym] = value
    end

    def attributes
      @attributes ||= {}
    end

    def attributes=(attributes)
      @attributes = attributes
    end

    def dup
      super.tap { |d| d.attributes = self.attributes.dup }
    end

    def identity
      send(self.class.instance_variable_get('@identity'))
    end

    def identity=(new_identity)
      send("#{self.class.instance_variable_get('@identity')}=", new_identity)
    end

    def merge_attributes(new_attributes = {})
      for key, value in new_attributes
        unless self.class.ignored_attributes.include?(key)
          if self.class.aliases.has_key?(key)
            self.class.aliases[key].each do |aliased_key|
              send("#{aliased_key}=", value)
            end
          end
          if self.respond_to?("#{key}=", true)
            send("#{key}=", value)
          end
        end
      end
      self
    end

    def new_record?
      !identity
    end

    # check that the attributes specified in args exist and is not nil
    def requires(*args)
      missing = missing_attributes(args)
      if missing.length == 1
        raise(ArgumentError, "#{missing.first} is required for this operation")
      elsif missing.any?
        raise(ArgumentError, "#{missing[0...-1].join(", ")} and #{missing[-1]} are required for this operation")
      end
    end

    def requires_one(*args)
      missing = missing_attributes(args)
      if missing.length == args.length
        raise(ArgumentError, "#{missing[0...-1].join(", ")} or #{missing[-1]} are required for this operation")
      end
    end

    protected

    def missing_attributes(args)
      ([:connection] | args).select{|arg| send("#{arg}").nil?}
    end
  end
end
