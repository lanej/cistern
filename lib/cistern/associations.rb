# frozen_string_literal: true
module Cistern::Associations

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
  def has_many(name, scope)
    name_sym = name.to_sym

    reader_method = name
    writer_method = "#{name}="

    attribute name, type: :array

    define_method reader_method do
      collection = instance_exec(&scope)
      records = attributes[name_sym] || []

      collection.load(records)
    end

    define_method writer_method do |models|
      attributes[name] = Array(models).map do |model|
        model.respond_to?(:attributes) ? model.attributes : model
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
  def belongs_to(name, block)
    name_sym = name.to_sym

    attribute name_sym

    define_method name_sym do
      attributes[name_sym] ||= instance_exec(&block)
    end

    associations[:belongs_to] << name_sym
  end
end
