module Cistern
  module Attributes
    def self.parsers
      @parsers ||= {
        :string  => lambda{|v,opts| v.to_s},
        :time    => lambda{|v,opts| v.is_a?(Time) ? v : v && Time.parse(v.to_s)},
        :integer => lambda{|v,opts| v && v.to_i},
        :float   => lambda{|v,opts| v && v.to_f},
        :array   => lambda{|v,opts| [*v]},
        :squash  => Proc.new do |v, opts|
          squash = options[:squash]
          if v.is_a?(::Hash)
            if v.has_key(squash.to_s.to_sym)
              v[squash.to_s.to_sym]
            elsif v.has_key?(squash.to_s)
              v[squash.to_s]
            else
              [v]
            end
          end
        end,
        :boolean => Proc.new do |v, opts|
          {
            true    => true,
            "true"  => true,
            "1"     => true,
            false   => false,
            "false" => false,
            "0"     => false
          }[v]
        end,
      }
    end

    def self.default_parser
      @default_parser ||= lambda{|v, opts| v}
    end

    module ClassMethods
      def _load(marshalled)
        new(Marshal.load(marshalled))
      end

      def aliases
        @aliases ||= {}
      end

      def attributes
        @attributes ||= []
      end

      def attribute(name, options = {})
        parser = Cistern::Attributes.parsers[options[:type]] ||
          options[:parser] ||
          Cistern::Attributes.default_parser
        self.send(:define_method, name) do
          attributes[name.to_s.to_sym]
        end
        self.send(:define_method, "#{name}=") do |value|
          attributes[name.to_s.to_sym]= parser.call(value, options)
        end

        @attributes ||= []
        @attributes |= [name]
        for new_alias in [*options[:aliases]]
          aliases[new_alias] = name
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

      def dup
        copy = super
        copy.dup_attributes!
        copy
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
            if aliased_key = self.class.aliases[key]
              send("#{aliased_key}=", value)
            elsif self.respond_to?("#{key}=",true)
              send("#{key}=", value)
            else
              attributes[key] = value
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
        missing = []
        for arg in [:connection] | args
          unless send("#{arg}") || attributes.has_key?(arg)
            missing << arg
          end
        end
        missing
      end

      def dup_attributes!
        @attributes = @attributes.dup
      end

      private

      def remap_attributes(attributes, mapping)
        for key, value in mapping
          if attributes.key?(key)
            attributes[value] = attributes.delete(key)
          end
        end
      end
    end
  end
end
