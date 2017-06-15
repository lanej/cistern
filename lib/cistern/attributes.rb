# frozen_string_literal: true
module Cistern::Attributes
  PROTECTED_METHODS = [:cistern, :service, :identity, :collection].freeze
  TRUTHY = %w(true 1).freeze

  module ClassMethods
    def parsers
      @parsers ||= {
        array:   ->(v, _) { [*v] },
        boolean: ->(v, _) { TRUTHY.include?(v.to_s.downcase) },
        float:   ->(v, _) { v && v.to_f },
        integer: ->(v, _) { v && v.to_i },
        string:  ->(v, _) { v && v.to_s },
        time:    ->(v, _) { v.is_a?(Time) ? v : v && Time.parse(v.to_s) },
      }
    end

    def squasher(tree, path)
      tree.is_a?(::Hash) ? squasher(tree[path.shift], path) : tree
    end

    def transforms
      @transforms ||= {
        squash: proc do |_, rv, options|
          v      = Cistern::Hash.stringify_keys(rv)
          squash = options[:squash]

          v.is_a?(::Hash) ? squasher(v, squash.dup) : v
        end,
        none: ->(_, v, _) { v },
      }
    end

    def default_parser
      @default_parser ||= ->(v, _opts) { v }
    end

    def aliases
      @aliases ||= Hash.new { |h, k| h[k] = [] }
    end

    def attributes
      @attributes ||= parent_attributes || {}
    end

    def attribute(name, options = {})
      name_sym = name.to_sym

      if attributes.key?(name_sym)
        raise(ArgumentError, "#{self.name} attribute[#{name_sym}] specified more than once")
      end

      add_coverage(options)

      normalize_options(options)

      attributes[name_sym] = options

      define_attribute_reader(name_sym, options) unless options[:reader] == false
      define_attribute_writer(name_sym, options) unless options[:writer] == false

      name_sym
    end

    def identity(*args)
      args.any? ? @identity = attribute(*args) : (@identity ||= parent_identity)
    end

    def ignore_attributes(*args)
      @ignored_attributes = args
    end

    def ignored_attributes
      @ignored_attributes ||= []
    end

    protected

    def add_coverage(options)
      return unless defined? Cistern::Coverage

      attribute_call = Cistern::Coverage.find_caller_before('cistern/attributes.rb')

      # Only use DSL attribute calls from within a model
      return unless attribute_call && attribute_call.label.start_with?('<class:')

      options[:coverage_file] = attribute_call.absolute_path
      options[:coverage_line] = attribute_call.lineno
      options[:coverage_hits] = 0
    end

    def define_attribute_reader(name, options)
      send(:define_method, name) do
        read_attribute(name)
      end unless instance_methods.include?(name)

      send(:alias_method, "#{name}?", name) if options[:type] == :boolean

      options[:aliases].each { |new_alias| aliases[new_alias] << name }
    end

    def define_attribute_writer(name, _options)
      return if instance_methods.include?("#{name}=".to_sym)

      send(:define_method, "#{name}=") { |value| write_attribute(name, value) }
    end

    private

    def normalize_options(options)
      options[:squash] = Array(options[:squash]).map(&:to_s) if options[:squash]
      options[:aliases] = Array(options[:aliases] || options[:alias]).map(&:to_sym)

      transform = options.key?(:squash) ? :squash : :none
      options[:transform] ||= transforms.fetch(transform)
      options[:parser] ||= parsers[options[:type]] || default_parser
    end

    def parent_attributes
      superclass && superclass.respond_to?(:attributes) && superclass.attributes.dup
    end

    def parent_identity
      superclass && superclass.respond_to?(:identity) && superclass.identity
    end
  end

  module InstanceMethods
    def clone_attributes
      Marshal.load Marshal.dump(attributes)
    end

    def read_attribute(name)
      key = name.to_sym

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

      transform = options[:transform]

      parser = options[:parser]

      transformed = transform.call(name, value, options)

      new_value = parser.call(transformed, options)
      attribute = name.to_s.to_sym

      previous_value = read_attribute(name)

      attributes[attribute] = new_value

      changed!(attribute, previous_value, new_value)

      new_value
    end

    def attributes
      @attributes ||= {}
    end

    def dup
      super.tap { |m| m.set_attributes attributes.dup }
    end

    def identity
      key = self.class.identity

      public_send(key) if key
    end

    def identity=(new_identity)
      key = self.class.identity

      raise ArgumentError, 'Identity not specified' unless key

      public_send("#{key}=", new_identity)
    end

    # Update model's attributes.  New attributes take precedence over existing attributes.
    #
    # This is bst called within a {Cistern::Model#save}, when {#new_attributes} represents a recently presented remote
    # resource.  {#dirty_attributes} is cleared after merging.
    #
    # @param new_attributes [Hash] attributes to merge with current attributes
    def merge_attributes(new_attributes = {})
      _merge_attributes(new_attributes)

      changed.clear

      self
    end

    alias attributes= merge_attributes

    # Update model's attributes.  New attributes take precedence over existing attributes.
    #
    # This is best called within a {Cistern::Model#update}, when {#new_attributes} represents attributes to be
    # presented to a remote service. {#dirty_attributes} will contain the valid portion of {#new_attributes}
    #
    # @param new_attributes [Hash] attributes to merge with current attributes
    def stage_attributes(new_attributes = {})
      _merge_attributes(new_attributes)
      self
    end

    def new_record?
      identity.nil?
    end

    # Require specification of certain attributes
    #
    # @raise [ArgumentError] if any requested attribute does not have a value
    # @return [Hash] of matching attributes
    def requires(*args)
      missing, required = missing_attributes(args)

      return required if missing.empty?

      if missing.length == 1
        raise(ArgumentError, "#{missing.keys.first} is required for this operation")
      end

      raise(ArgumentError, "#{missing.keys[0...-1].join(', ')} and #{missing.keys[-1]} are required for this operation")
    end

    # Require specification of one or more attributes.
    #
    # @raise [ArgumentError] if no requested attributes have values
    # @return [Hash] of matching attributes
    def requires_one(*args)
      missing, required = missing_attributes(args)

      if missing.length == args.length
        raise(ArgumentError, "#{missing.keys[0...-1].join(', ')} or #{missing.keys[-1]} are required for this operation")
      end

      required
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

    def request_attributes(set = attributes)
      set.inject({}) do |a, (k, v)|
        aliases = self.class.attributes[k.to_sym][:aliases]
        aliases << k if aliases.empty?
        aliases.each_with_object(a) { |n, r| r[n.to_s] = v }
      end
    end

    def dirty_request_attributes
      request_attributes(dirty_attributes)
    end

    private

    def missing_attributes(keys)
      keys.map(&:to_sym).reduce({}) { |a, e| a.merge(e => public_send(e.to_s)) }
          .partition { |_, v| v.nil? }
          .map { |s| Hash[s] }
    end

    def changed!(attribute, from, to)
      changed[attribute] = if existing = changed[attribute]
                             [existing.first, to]
                           else
                             [from, to]
                           end
    end

    def _merge_attributes(new_attributes)
      protected_methods  = (Cistern::Model.instance_methods - PROTECTED_METHODS)
      ignored_attributes = self.class.ignored_attributes
      specifications     = self.class.attributes
      class_aliases      = self.class.aliases

      # this has the side effect of dup'ing the incoming hash
      new_attributes = Cistern::Hash.stringify_keys(new_attributes)

      new_attributes.each do |key, value|
        symbol_key = key.to_sym

        # find nested paths
        value.is_a?(::Hash) && specifications.each do |name, options|
          if options[:squash] && options[:squash].first == key
            send("#{name}=", key => value)
          end
        end

        next if ignored_attributes.include?(symbol_key)

        if class_aliases.key?(symbol_key)
          class_aliases[symbol_key].each { |attribute_alias| public_send("#{attribute_alias}=", value) }
        end

        assignment_method = "#{key}="

        if !protected_methods.include?(symbol_key) && respond_to?(assignment_method, true)
          public_send(assignment_method, value)
        end
      end
    end

    protected

    # rubocop:disable Style/AccessorMethodName
    def set_attributes(attributes)
      @attributes = attributes
    end
  end
end
