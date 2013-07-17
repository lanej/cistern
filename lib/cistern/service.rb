class Cistern::Service

  def self.mock!;    @mocking = true; end
  def self.mocking?; @mocking; end
  def self.unmock!;  @mocking = false; end

  module Collections
    def collections
      service.collections
    end

    def mocked_requests
      service.mocked_requests
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
      EOS

      klass.send(:const_set, :Timeout, Class.new(Cistern::Error))
    end

    def model_path(model_path)
      @model_path = model_path
    end

    def request_path(request_path)
      @request_path = request_path
    end

    def collections
      @collections ||= []
    end

    def models
      @models ||= []
    end

    def recognized_arguments
      @recognized_arguments ||= []
    end

    def required_arguments
      @required_arguments ||= []
    end

    def requests
      @requests ||= []
    end

    def requires(*args)
      self.required_arguments.concat(args)
    end

    def recognizes(*args)
      self.recognized_arguments.concat(args)
    end

    def model(model_name, options={})
      models << [model_name, options]
    end

    def mocked_requests
      @mocked_requests ||= []
    end

    def request(request_name)
      requests << request_name
    end

    def collection(collection_name, options={})
      collections << [collection_name, options]
    end

    def validate_options(options={})
      required_options = Cistern::Hash.slice(options, *required_arguments)
      missing_required_options = required_arguments - required_options.keys
      unless missing_required_options.empty?
        raise "Missing required options: #{missing_required_options.inspect}"
      end
      recognized_options = Cistern::Hash.slice(options, *(required_arguments + recognized_arguments))
      unrecognized_options = options.keys - (required_arguments + recognized_arguments)
      unless unrecognized_options.empty?
        raise "Unrecognized options: #{unrecognized_options.inspect}"
      end
    end

    def setup_requirements
      @required ||= false
      unless @required
        models.each do |model, options|
          require File.join(@model_path, model.to_s) unless options[:require] == false
          class_name = model.to_s.split("_").map(&:capitalize).join
          self.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
            def #{model}(attributes={})
              #{service}::#{class_name}.new({connection: self}.merge(attributes))
            end
          EOS
        end
        requests.each do |request|
          require File.join(@request_path, request.to_s)
          if service::Mock.method_defined?(request)
            mocked_requests << request
          else
            service::Mock.module_eval <<-EOS, __FILE__, __LINE__
              def #{request}(*args)
                Cistern::Mock.not_implemented
              end
            EOS
          end
        end
        collections.each do |collection, options|
          require File.join(@model_path, collection.to_s) unless options[:require] == false
          class_name = collection.to_s.split("_").map(&:capitalize).join
          self.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
            def #{collection}(attributes={})
              #{service}::#{class_name}.new({connection: self}.merge(attributes))
            end
          EOS
        end
        @required = true
      end
    end

    def new(options={})
      validate_options(options)
      setup_requirements

      klass = self.const_get(self.mocking? ? :Mock : :Real)

      klass.send(:include, service::Collections)
      klass.send(:extend, Cistern::WaitFor)
      klass.timeout_error = service::Timeout
      klass.new(options)
    end

    def reset!
      self.const_get(:Mock).reset!
    end
  end
end
