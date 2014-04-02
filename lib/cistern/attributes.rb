module Cistern::Attributes
  def self.parsers
    @parsers ||= {
      :string  => lambda { |v,opts| v.to_s },
      :time    => lambda { |v,opts| v.is_a?(Time) ? v : v && Time.parse(v.to_s) },
      :integer => lambda { |v,opts| v && v.to_i },
      :float   => lambda { |v,opts| v && v.to_f },
      :array   => lambda { |v,opts| [*v] },
      :boolean => lambda { |v,opts| ['true', '1'].include?(v.to_s.downcase) }
    }
  end

  def self.transforms
    @transforms ||= {
      :squash  => Proc.new do |k, v, options|
        squash = options[:squash]
        if v.is_a?(::Hash) && squash.is_a?(Array)
          travel = lambda do |tree, path|
            if tree.is_a?(::Hash)
              subtree = tree[path.shift]
              travel.call(subtree, path)
            else tree
            end
          end

          travel.call(v, squash.dup)
        elsif v.is_a?(::Hash)
          if v.key?(squash.to_s.to_sym)
            v[squash.to_s.to_sym]
          elsif v.has_key?(squash.to_s)
            v[squash.to_s]
          else
            v
          end
        else v
        end
      end,
      :none => lambda { |k, v, opts| v },
    }
  end

  def self.default_parser
    @default_parser ||= lambda { |v, opts| v }
  end

  module ClassMethods
    def _load(marshalled)
      new(Marshal.load(marshalled))
    end

    def aliases
      @aliases ||= {}
    end

    def attributes
      @attributes ||= {}
    end

    def attribute(_name, options = {})
      if defined? Cistern::Coverage
        attribute_call = Cistern::Coverage.find_caller_before("cistern/attributes.rb")

        # Only use DSL attribute calls from within a model
        if attribute_call and attribute_call.label.start_with? "<class:"
          options[:coverage_file] = attribute_call.absolute_path
          options[:coverage_line] = attribute_call.lineno
          options[:coverage_hits] = 0
        end
      end

      name = _name.to_s.to_sym

      parser = Cistern::Attributes.parsers[options[:type]] ||
        options[:parser] ||
        Cistern::Attributes.default_parser
      transform = Cistern::Attributes.transforms[options[:squash] ? :squash : :none] ||
        Cistern::Attributes.default_transform

      self.send(:define_method, name) do
        # record the attribute was accessed
        self.class.attributes[name.to_s.to_sym][:coverage_hits] += 1 rescue  nil

        attributes[name.to_s.to_sym]
      end

      self.send(:define_method, "#{name}=") do |value|
        transformed = transform.call(name, value, options)
        attributes[name.to_s.to_sym]= parser.call(transformed, options)
      end

      if self.attributes[name]
        raise(ArgumentError, "#{self.name} attribute[#{_name}] specified more than once")
      else
        self.attributes[name] = options
      end

      Array(options[:aliases]).each do |new_alias|
        aliases[new_alias] ||= []
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

    def attributes
      @attributes ||= {}
    end

    def attributes=(attributes)
      @attributes = attributes
    end

    def dup
      copy = super
      copy.attributes= copy.attributes.dup
      copy
    end

    def identity
      send(self.class.instance_variable_get('@identity'))
    end

    def identity=(new_identity)
      send("#{self.class.instance_variable_get('@identity')}=", new_identity)
    end

    def merge_attributes(new_attributes = {})
      new_attributes.each do |key, value|
        # find nested paths
        value.is_a?(::Hash) && self.class.attributes.each do |name, options|
          if (options[:squash] || []).first == key
            send("#{name}=", {key => value})
          end
        end
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
