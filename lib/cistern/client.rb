# frozen_string_literal: true
module Cistern::Client
  module Collections
    def collections
      cistern.collections
    end

    def requests
      cistern.requests
    end
  end

  # custom include
  def self.with(options = {})
    client_module = Module.new

    custom_include = <<-EOS
      def self.included(klass)
        Cistern::Client.setup(klass, #{options.inspect})

        super
      end
    EOS

    client_module.class_eval(custom_include, __FILE__, __LINE__)

    client_module
  end

  # vanilla include
  def self.included(klass)
    setup(klass)

    super
  end

  # rubocop:disable Metrics/MethodLength
  def self.setup(klass, options = {})
    request_class    = options[:request] || 'Request'
    collection_class = options[:collection] || 'Collection'
    model_class      = options[:model] || 'Model'
    singular_class   = options[:singular] || 'Singular'

    interface = options[:interface] || :class
    interface_callback = :class == interface ? :inherited : :included

    if interface == :class
      Cistern.deprecation(
        "'class' interface is deprecated. Use `include Cistern::Client.with(interface: :module). See https://github.com/lanej/cistern#custom-architecture",
        caller[2],
      )
    end

    unless klass.name
      raise ArgumentError, "can't turn anonymous class into a Cistern cistern"
    end

    klass.class_eval <<-EOS, __FILE__, __LINE__
      module Collections
        include ::Cistern::Client::Collections

        def cistern
          Cistern.deprecation(
            '#cistern is deprecated.  Please use #cistern',
            caller[0]
          )
    #{klass.name}
        end

        def cistern
    #{klass.name}
        end
      end

      def self.cistern
        Cistern.deprecation(
          '#cistern is deprecated.  Please use #cistern',
          caller[0]
        )
    #{klass.name}
      end

      def self.cistern
    #{klass.name}
      end

      class Real
        def initialize(options={})
        end

        def mocking?
          false
        end
      end

      class Mock
        def initialize(options={})
        end

        def mocking?
          true
        end
      end

    #{interface} #{model_class}
        def self.#{interface_callback}(klass)
          cistern.models << klass

          klass.send(:include, ::Cistern::Model)

          super
        end

        def self.cistern
          Cistern.deprecation(
            '#cistern is deprecated.  Please use #cistern',
            caller[0]
          )
    #{klass.name}
        end

        def self.cistern
    #{klass.name}
        end
      end

    #{interface} #{singular_class}
        def self.#{interface_callback}(klass)
          cistern.singularities << klass

          klass.send(:include, ::Cistern::Singular)

          super
        end

        def self.service
          Cistern.deprecation(
            '#service is deprecated.  Please use #cistern',
            caller[0]
          )
    #{klass.name}
        end

        def self.cistern
    #{klass.name}
        end
      end

    #{interface} #{collection_class}
        include ::Cistern::Collection

        def self.#{interface_callback}(klass)
          klass.send(:extend, Cistern::Attributes::ClassMethods)
          klass.send(:extend, Cistern::Collection::ClassMethods)
          klass.send(:include, Cistern::Attributes::InstanceMethods)

          cistern.collections << klass

          super
        end

        def self.service
          Cistern.deprecation(
            '#service is deprecated.  Please use #cistern',
            caller[0]
          )
    #{klass.name}
        end

        def self.cistern
    #{klass.name}
        end
      end

    #{interface} #{request_class}
        include ::Cistern::Request

        def self.service
          Cistern.deprecation(
            '#service is deprecated.  Please use #cistern',
            caller[0]
          )
    #{klass.name}
        end

        def self.cistern
    #{klass.name}
        end

        def self.#{interface_callback}(klass)
          klass.extend(::Cistern::Request::ClassMethods)

          cistern.requests << klass

          super
        end
      end
    EOS

    klass.send(:extend, Cistern::Client::ClassMethods)
    klass.send(:const_set, :Timeout, Class.new(Cistern::Error))

    klass::Mock.send(:include, klass::Collections)
    klass::Mock.send(:extend, Cistern::WaitFor)
    klass::Mock.timeout_error = klass::Timeout

    klass::Mock.send(:extend, Cistern::Data)

    klass::Real.send(:include, klass::Collections)
    klass::Real.send(:extend, Cistern::WaitFor)
    klass::Real.timeout_error = klass::Timeout
  end

  module ClassMethods
    def mock!
      @mocking = true
    end

    def mocking?
      @mocking
    end

    def unmock!
      @mocking = false
    end

    def collections
      @collections ||= []
    end

    def models
      @_models ||= []
    end

    def singularities
      @_singularities ||= []
    end

    def recognized_arguments
      @_recognized_arguments ||= []
    end

    def required_arguments
      @_required_arguments ||= []
    end

    def requests
      @_requests ||= []
    end

    def requires(*args)
      required_arguments.concat(args)
    end

    def recognizes(*args)
      recognized_arguments.concat(args)
    end

    def validate_options(options = {})
      required_options = Cistern::Hash.slice(options, *required_arguments)

      missing_required_options = required_arguments - required_options.keys

      unless missing_required_options.empty?
        raise "Missing required options: #{missing_required_options.inspect}"
      end

      unrecognized_options = options.keys - (required_arguments + recognized_arguments)

      return if unrecognized_options.empty?

      raise "Unrecognized options: #{unrecognized_options.inspect}"
    end

    def setup
      return true if @_setup

      requests.each do |klass|
        name = klass.cistern_method ||
               Cistern::String.camelize(Cistern::String.demodulize(klass.name))

        Cistern::Request.cistern_request(self, klass, name)
      end

      collections.each do |klass|
        name = klass.cistern_method ||
               Cistern::String.underscore(klass.name.gsub("#{self.name}::", '').gsub('::', ''))

        Cistern::Collection.cistern_collection(self, klass, name)
      end

      models.each do |klass|
        name = klass.cistern_method ||
               Cistern::String.underscore(klass.name.gsub("#{self.name}::", '').gsub('::', ''))

        Cistern::Model.cistern_model(self, klass, name)
      end

      singularities.each do |klass|
        name = klass.cistern_method ||
               Cistern::String.underscore(klass.name.gsub("#{self.name}::", '').gsub('::', ''))

        Cistern::Singular.cistern_singular(self, klass, name)
      end

      @_setup = true
    end

    def new(options = {})
      setup
      validate_options(options)

      const_get(mocking? ? :Mock : :Real).new(options)
    end

    def reset!
      const_get(:Mock).reset!
    end
  end
end
