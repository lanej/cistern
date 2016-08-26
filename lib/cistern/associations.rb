# frozen_string_literal: true
module Cistern::Associations

  def self.extended(klass)
    def klass.association_overlay
      @association_overlay ||= const_set(:Associations, Module.new)
    end

    klass.send(:include, klass.association_overlay)

    super
  end

  # Lists the associations defined on the resource
  # @return [Hash{Symbol=>Array}] mapping of association type to name
  def associations
    @associations ||= Hash.new { |h,k| h[k] = [] }
  end

  # Define an assocation that references a collection.
  # @param name [Symbol] name of association and corresponding reader and writer.
  # @param scope [Proc] returning {Cistern::Collection} instance to load models into. {#scope} is evaluated within the
  #   context of the model.
  # @return [Cistern::Collection] as defined by {#scope}
  # @example
  #   class Firm < Law::Model
  #     identity :registration_id
  #     has_many :lawyers, -> { cistern.associates(firm_id: identity) }
  #    end
  def has_many(name, *args, &block)
    name_sym = name.to_sym

    reader_method = name
    writer_method = "#{name}="

    options = args.last.is_a?(::Hash) ? args.pop : {}
    scope = args.first || block

    attribute name_sym, options.merge(writer: false, reader: false, type: :array)

    association_overlay.module_eval do
      define_method reader_method do
        collection = instance_exec(&scope)
        records = attributes[name_sym] || []

        collection.load(records) if records.any?
        collection
      end
    end

    association_overlay.module_eval do
      define_method writer_method do |models|
        attributes[name] = Array(models).map do |model|
          model.respond_to?(:attributes) ? model.attributes : model
        end
      end
    end

    associations[:has_many] << name_sym
  end

  # Define an assocation that references a model.
  # @param name [Symbol] name of association and corresponding reader.
  # @param scope [Proc] returning a {Cistern::Model} that is evaluated within the context of the model.
  # @return [Cistern::Model] as defined by {#scope}
  # @example
  #   class Firm < Law::Model
  #     identity :registration_id
  #     belongs_to :leader, -> { cistern.employees.get(:ceo) }
  #    end
  def belongs_to(name, *args, &block)
    name_sym = name.to_sym

    reader_method = name
    writer_method = "#{name}="

    options = args.last.is_a?(::Hash) ? args.pop : {}
    scope = args.first || block

    attribute name_sym, options.merge(writer: false, reader: false)

    association_overlay.module_eval do
      define_method reader_method do
        model = instance_exec(&scope)
        attributes[name_sym] = model.attributes
        model
      end
    end

    association_overlay.module_eval do
      define_method writer_method do |model|
        data = model.respond_to?(:attributes) ? model.attributes : model
        attributes[name_sym] = data
        model
      end
    end

    associations[:belongs_to] << name_sym
  end
end
