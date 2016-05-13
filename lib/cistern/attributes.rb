module Cistern::Attributes
  PROTECTED_METHODS = [:cistern, :service, :identity, :collection].freeze
  TRUTHY = ['true', '1'].freeze

  def self.parsers
    @parsers ||= {
      array:   ->(v, _) { [*v] },
      boolean: ->(v, _) { TRUTHY.include?(v.to_s.downcase) },
      float:   ->(v, _) { v && v.to_f },
      integer: ->(v, _) { v && v.to_i },
      string:  ->(v, opts) { (opts[:allow_nil] && v.nil?) ? v : v.to_s },
      time:    ->(v, _) { v.is_a?(Time) ? v : v && Time.parse(v.to_s) },
    }
  end

  def self.transforms
    @transforms ||= {
      squash: proc do |_k, _v, options|
        v      = Cistern::Hash.stringify_keys(_v)
        squash = options[:squash]

        if v.is_a?(::Hash) && squash.is_a?(Array)
          travel = lambda do |tree, path|
            if tree.is_a?(::Hash)
              travel.call(tree[path.shift], path)
            else
              tree
            end
          end

          travel.call(v, squash.dup)
        elsif v.is_a?(::Hash)
          squash_s = squash.to_s

          if v.key?(key = squash_s.to_sym)
            v[key]
          elsif v.key?(squash_s)
            v[squash_s]
          else
            v
          end
        else v
        end
      end,
      none: ->(_, v, _) { v }
    }
  end

  def self.default_parser
    @default_parser ||= ->(v, _opts) { v }
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

    def attribute(_name, options = {})
      if defined? Cistern::Coverage
        attribute_call = Cistern::Coverage.find_caller_before('cistern/attributes.rb')

        # Only use DSL attribute calls from within a model
        if attribute_call && attribute_call.label.start_with?('<class:')
          options[:coverage_file] = attribute_call.absolute_path
          options[:coverage_line] = attribute_call.lineno
          options[:coverage_hits] = 0
        end
      end

      name = _name.to_s.to_sym

      send(:define_method, name) do
        read_attribute(name)
      end unless instance_methods.include?(name)

      send(:alias_method, "#{name}?", name) if options[:type] == :boolean

      send(:define_method, "#{name}=") do |value|
        write_attribute(name, value)
      end unless instance_methods.include?("#{name}=".to_sym)

      if attributes[name]
        fail(ArgumentError, "#{self.name} attribute[#{_name}] specified more than once")
      else
        if options[:squash]
          options[:squash] = Array(options[:squash]).map(&:to_s)
        end
        attributes[name] = options
      end

      options[:aliases] = Array(options[:aliases] || options[:alias]).map { |a| a.to_s.to_sym }

      options[:aliases].each do |new_alias|
        aliases[new_alias] << name.to_s.to_sym
      end
    end

    def identity(name, options = {})
      @identity = name
      attribute(name, options)
    end

    def ignore_attributes(*args)
      @ignored_attributes = args
    end

    def ignored_attributes
      @ignored_attributes ||= []
    end
  end

  module InstanceMethods
    def dump
      Marshal.dump(attributes)
    end

    def read_attribute(name)
      key = name.to_s.to_sym
      options = self.class.attributes[key]
      default = options[:default]

      # record the attribute was accessed
      if defined?(Cistern::Coverage) && options[:coverage_hits]
        options[:coverage_hits] += 1
      end

      default = Marshal.load(Marshal.dump(default)) unless default.nil?

      attributes.fetch(key, default)
    end

    def write_attribute(name, value)
      options = self.class.attributes[name] || {}

      transform = Cistern::Attributes.transforms[options[:squash] ? :squash : :none] ||
                  Cistern::Attributes.default_transform

      parser = Cistern::Attributes.parsers[options[:type]] ||
               options[:parser] ||
               Cistern::Attributes.default_parser

      transformed = transform.call(name, value, options)

      new_value = parser.call(transformed, options)
      attribute = name.to_s.to_sym

      previous_value = attributes[attribute]

      attributes[attribute] = new_value

      changed!(attribute, previous_value, new_value)

      new_value
    end

    def attributes
      @attributes ||= {}
    end

    def attributes=(attributes)
      @attributes = attributes
    end

    def dup
      copy = super
      copy.attributes = copy.attributes.dup
      copy
    end

    def identity
      key = self.class.instance_variable_get('@identity')

      public_send(key) if key
    end

    def identity=(new_identity)
      key = self.class.instance_variable_get('@identity')

      if key
        public_send("#{key}=", new_identity)
      else
        fail ArgumentError, 'Identity not specified'
      end
    end

    def merge_attributes(new_attributes = {})
      protected_methods  = (Cistern::Model.instance_methods - PROTECTED_METHODS)
      ignored_attributes = self.class.ignored_attributes
      class_attributes   = self.class.attributes
      class_aliases      = self.class.aliases

      new_attributes.each do |_key, value|
        string_key = _key.is_a?(String) ? _key : _key.to_s
        symbol_key = case _key
                     when String
                       _key.to_sym
                     when Symbol
                       _key
                     else
                       string_key.to_sym
                     end

        # find nested paths
        value.is_a?(::Hash) && class_attributes.each do |name, options|
          if options[:squash] && options[:squash].first == string_key
            send("#{name}=", symbol_key => value)
          end
        end

        next if ignored_attributes.include?(symbol_key)

        if class_aliases.key?(symbol_key)
          class_aliases[symbol_key].each do |aliased_key|
            send("#{aliased_key}=", value)
          end
        end

        assignment_method = "#{string_key}="

        if !protected_methods.include?(symbol_key) && self.respond_to?(assignment_method, true)
          send(assignment_method, value)
        end
      end

      changed.clear

      self
    end

    def new_record?
      identity.nil?
    end

    # check that the attributes specified in args exist and is not nil
    def requires(*args)
      missing = missing_attributes(args)
      if missing.length == 1
        fail(ArgumentError, "#{missing.first} is required for this operation")
      elsif missing.any?
        fail(ArgumentError, "#{missing[0...-1].join(', ')} and #{missing[-1]} are required for this operation")
      end
    end

    def requires_one(*args)
      missing = missing_attributes(args)
      if missing.length == args.length
        fail(ArgumentError, "#{missing[0...-1].join(', ')} or #{missing[-1]} are required for this operation")
      end
    end

    def dirty?
      changed.any?
    end

    def dirty_attributes
      changed.inject({}) { |r, (k, (_, v))| r.merge(k => v) }
    end

    def changed
      @changes ||= {}
    end

    protected

    def missing_attributes(args)
      args.select { |arg| send("#{arg}").nil? }
    end

    def changed!(attribute, from, to)
      changed[attribute] = if existing = changed[attribute]
                             [existing.first, to]
                           else
                             [from, to]
                           end
    end
  end
end
