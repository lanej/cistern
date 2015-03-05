class Cistern::Service

  def self.mock!;    @mocking = true; end
  def self.mocking?; @mocking; end
  def self.unmock!;  @mocking = false; end

  module Collections
    def collections
      service.collections
    end

    def requests
      service.requests
    end
  end

  class << self
    def inherited(klass)
      klass.class_eval <<-EOS, __FILE__, __LINE__
        module Collections
          include Cistern::Service::Collections

          def service
            #{klass.name}
          end
        end

        def self.service
          #{klass.name}
        end

        class Real
          def initialize(options={})
          end
        end

        class Mock
          def initialize(options={})
          end
        end

        class Model
          include Cistern::Model

          def self.inherited(klass)
            service.models << klass
          end

          def self.service
            #{klass.name}
          end
        end

        class Collection
          include Cistern::Collection

          def self.inherited(klass)
            klass.send(:extend, Cistern::Attributes::ClassMethods)
            klass.send(:extend, Cistern::Collection::ClassMethods)
            klass.send(:include, Cistern::Attributes::InstanceMethods)

            service.collections << klass
          end

          def self.service
            #{klass.name}
          end
        end

        class Request
          include Cistern::Request

          def self.inherited(klass)
            klass.extend(Cistern::Request::ClassMethods)

            service.requests << klass
          end

          def self.service
            #{klass.name}
          end

          def _mock(*args)
            mock(*args)
          end

          def _real(*args)
            real(*args)
          end
        end
      EOS

      klass.send(:const_set, :Timeout, Class.new(Cistern::Error))

      klass::Mock.send(:include, klass::Collections)
      klass::Mock.send(:extend, Cistern::WaitFor)
      klass::Mock.timeout_error = klass::Timeout

      klass::Mock.send(:extend, Cistern::Data)

      klass::Real.send(:include, klass::Collections)
      klass::Real.send(:extend, Cistern::WaitFor)
      klass::Real.timeout_error = klass::Timeout
    end

    def collections
      @collections ||= []
    end

    def models
      @_models ||= []
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
      self.required_arguments.concat(args)
    end

    def recognizes(*args)
      self.recognized_arguments.concat(args)
    end

    def validate_options(options={})
      required_options = Cistern::Hash.slice(options, *required_arguments)

      missing_required_options = required_arguments - required_options.keys

      unless missing_required_options.empty?
        raise "Missing required options: #{missing_required_options.inspect}"
      end

      unrecognized_options = options.keys - (required_arguments + recognized_arguments)

      unless unrecognized_options.empty?
        raise "Unrecognized options: #{unrecognized_options.inspect}"
      end
    end

    def setup
      return true if @_setup

      requests.each do |klass|
        name = klass.service_method ||
          Cistern::String.camelize(Cistern::String.demodulize(klass.name))

        Cistern::Request.service_request(self, klass, name)
      end

      collections.each do |klass|
        name = klass.service_method ||
          Cistern::String.underscore(klass.name.gsub("#{self.name}::", "").gsub("::", ""))

        Cistern::Collection.service_collection(self, klass, name)
      end

      models.each do |klass|
        name = klass.service_method ||
          Cistern::String.underscore(klass.name.gsub("#{self.name}::", "").gsub("::", ""))

        Cistern::Model.service_model(self, klass, name)
      end

      @_setup = true
    end

    def new(options={})
      setup
      validate_options(options)

      self.const_get(self.mocking? ? :Mock : :Real).new(options)
    end

    def reset!
      self.const_get(:Mock).reset!
    end
  end
end
