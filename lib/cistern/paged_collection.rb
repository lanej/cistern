# @abstract Subclass and set #{collection_method}, #{collection_root}, #{model_method}, #{model_root} and #{model}
# adds {#create!} method to {Cistern::Collection}.
# @example
#   class Zendesk2::Client::Users < Cistern::PagedCollection
#     model Zendesk2::Client::User
#
#     self.collection_method = :get_users
#     self.collection_root   = "users"
#     self.model_method      = :get_user
#     self.model_root        = "user"
#   end
# 
class Cistern::PagedCollection < Cistern::Collection
  def self.inherited(klass)
    klass.send(:attribute, :count)
    klass.send(:attribute, :next_page_link, {:aliases => "next_page"})
    klass.send(:attribute, :previous_page_link, {:aliases => "previous_page"})
    klass.send(:extend, ClassMethods)
  end

  def collection_method; self.class.collection_method; end
  def collection_root; self.class.collection_root; end
  def model_method; self.class.model_method; end
  def model_root; self.class.model_root; end

  def next_page
    clone.clear.all("url" => next_page_link) if next_page_link
  end

  # @return [Cistern::Collection, NilClass] previous page of results
  def previous_page
    clone.clear.all("url" => previous_page_link) if previous_page_link
  end

  # @param
  # @return [Cistern::Collection, NilClass] previous page of results
  def all(params={})
    scoped_attributes = self.class.scopes.inject({}){|r,k| r.merge(k.to_s => send(k))}
    scoped_attributes.merge!(params)
    body = connection.send(collection_method, scoped_attributes).body

    collection = self.load(body[collection_root])
    collection.merge_attributes(Cistern::Hash.slice(body, "count", "next_page", "previous_page"))
    collection
  end

  module ClassMethods
    attr_accessor :collection_method, :collection_root, :model_method, :model_root

    def scopes
      @scopes ||= []
    end
  end
end
