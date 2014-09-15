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

        class Real
          def initialize(options={})
          end
        end

        class Mock
          def initialize(options={})
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

    def collection_path(collection_path = nil)
      if collection_path
        @collection_path = collection_path
      else
        @collection_path
      end
    end

    def model_path(model_path = nil)
      if model_path
        @model_path = model_path
      else
        @model_path
      end
    end

    def request_path(request_path = nil)
      if request_path
        @request_path = request_path
      else
        @request_path
      end
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

    def request(request_name, options={})
      requests << [request_name, options]
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

      unrecognized_options = options.keys - (required_arguments + recognized_arguments)

      unless unrecognized_options.empty?
        raise "Unrecognized options: #{unrecognized_options.inspect}"
      end
    end

    def setup_requirements
      @required ||= false
      unless @required

        # setup models
        models.each do |model, options|
          unless options[:require] == false
            require(options[:require] || File.join(@model_path, model.to_s))
          end

          class_name    = options[:class] || model.to_s.split("_").map(&:capitalize).join
          singular_name = options[:model] || model.to_s.gsub("/", "_")

          self.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
            def #{singular_name}(attributes={})
              #{service}::#{class_name}.new({connection: self}.merge(attributes))
            end
          EOS
        end

        # setup requests
        requests.each do |request, options|
          unless options[:require] == false || service::Real.method_defined?(request.to_s)
            require(options[:require] || File.join(@request_path, request.to_s))
          end

          if service::Mock.method_defined?(request)
            mocked_requests << request
          else
            service::Mock.module_eval <<-EOS, __FILE__, __LINE__
              def #{request}(*args)
                Cistern::Mock.not_implemented(request)
              end
            EOS
          end
        end

        # setup collections
        collections.each do |collection, options|
          unless options[:require] == false
            require(options[:require] || File.join(@collection_path || @model_path, collection.to_s))
          end

          class_name = collection.to_s.split("/").map(&:capitalize).join("::").split("_").map { |s| "#{s[0].upcase}#{s[1..-1]}" }.join
          plural_name = options[:collection] || collection.to_s.gsub("/", "_")

          self.const_get(:Collections).module_eval <<-EOS, __FILE__, __LINE__
            def #{plural_name}(attributes={})
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

      self.const_get(self.mocking? ? :Mock : :Real).new(options)
    end

    def reset!
      self.const_get(:Mock).reset!
    end
  end
end
