# Cistern

[![Join the chat at https://gitter.im/lanej/cistern](https://badges.gitter.im/lanej/cistern.svg)](https://gitter.im/lanej/cistern?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://secure.travis-ci.org/lanej/cistern.png)](http://travis-ci.org/lanej/cistern)
[![Dependencies](https://gemnasium.com/lanej/cistern.png)](https://gemnasium.com/lanej/cistern.png)
[![Gem Version](https://badge.fury.io/rb/cistern.svg)](http://badge.fury.io/rb/cistern)
[![Code Climate](https://codeclimate.com/github/lanej/cistern/badges/gpa.svg)](https://codeclimate.com/github/lanej/cistern)

Cistern helps you consistently build your API clients and faciliates building mock support.

## Usage

### Notice: Cistern 3.0

Cistern 3.0 will change the way Cistern interacts with your `Request`, `Collection` and `Model` classes.

Prior to 3.0, your `Request`, `Collection` and `Model` classes would have inherited from `<service>::Client::Request`, `<service>::Client::Collection` and `<service>::Client::Model` classes, respectively.

In cistern `~> 3.0`, the default will be for `Request`, `Collection` and `Model` classes to instead include their respective `<service>::Client` modules.

If you want to be forwards-compatible today, you can configure your client by using `Cistern::Client.with`

```ruby
class Blog
  include Cistern::Client.with(interface: :module)
end
```

Now request classes would look like:

```ruby
class Blog::GetPost
  include Blog::Request

  def real
    "post"
  end
end
```


### Service

This represents the remote service that you are wrapping. If the service name is `blog` then a good name is `Blog`.

Service initialization parameters are enumerated by `requires` and `recognizes`. Parameters defined using `recognizes` are optional.

```ruby
# lib/blog.rb
class Blog
  include Cistern::Client

  requires :hmac_id, :hmac_secret
  recognizes :url
end

# Acceptable
Blog.new(hmac_id: "1", hmac_secret: "2")                            # Blog::Real
Blog.new(hmac_id: "1", hmac_secret: "2", url: "http://example.org") # Blog::Real

# ArgumentError
Blog.new(hmac_id: "1", url: "http://example.org")
Blog.new(hmac_id: "1")
```

Cistern will define for you two classes, `Mock` and `Real`. Create the corresponding files and initialzers for your
new service.

```ruby
# lib/blog/real.rb
class Blog::Real
  attr_reader :url, :connection

  def initialize(attributes)
    @hmac_id, @hmac_secret = attributes.values_at(:hmac_id, :hmac_secret)
    @url = attributes[:url] || 'http://blog.example.org'
    @connection = Faraday.new(url)
  end
end
```

```ruby
# lib/blog/mock.rb
class Blog::Mock
  attr_reader :url

  def initialize(attributes)
    @url = attributes[:url]
  end
end
```

### Mocking

Cistern strongly encourages you to generate mock support for your service. Mocking can be enabled using `mock!`.

```ruby
Blog.mocking?          # falsey
real = Blog.new        # Blog::Real
Blog.mock!
Blog.mocking?          # true
fake = Blog.new        # Blog::Mock
Blog.unmock!
Blog.mocking?          # false
real.is_a?(Blog::Real) # true
fake.is_a?(Blog::Mock) # true
```

### Working with data

`Cistern::Hash` contains many useful functions for working with data normalization and transformation.

**#stringify_keys**

```ruby
# anywhere
Cistern::Hash.stringify_keys({a: 1, b: 2}) #=> {'a' => 1, 'b' => 2}
# within a Resource
hash_stringify_keys({a: 1, b: 2}) #=> {'a' => 1, 'b' => 2}
```

**#slice**

```ruby
# anywhere
Cistern::Hash.slice({a: 1, b: 2, c: 3}, :a, :c) #=> {a: 1, c: 3}
# within a Resource
hash_slice({a: 1, b: 2, c: 3}, :a, :c) #=> {a: 1, c: 3}
```

**#except**

```ruby
# anywhere
Cistern::Hash.except({a: 1, b: 2}, :a) #=> {b: 2}
# within a Resource
hash_except({a: 1, b: 2}, :a) #=> {b: 2}
```


**#except!**

```ruby
# same as #except but modify specified Hash in-place
Cistern::Hash.except!({:a => 1, :b => 2}, :a) #=> {:b => 2}
# within a Resource
hash_except!({:a => 1, :b => 2}, :a) #=> {:b => 2}
```


### Requests

Requests are defined by subclassing `#{service}::Request`.

* `cistern` represents the associated `Blog` instance.

```ruby
class Blog::GetPost < Blog::Request
  def real(params)
    # make a real request
    "i'm real"
  end

  def mock(params)
    # return a fake response
    "imposter!"
  end
end

Blog.new.get_post # "i'm real"
```

The `#cistern_method` function allows you to specify the name of the generated method.

```ruby
class Blog::GetPosts < Blog::Request
  cistern_method :get_all_the_posts

  def real(params)
    "all the posts"
  end
end

Blog.new.respond_to?(:get_posts) # false
Blog.new.get_all_the_posts       # "all the posts"
```

All declared requests can be listed via `Cistern::Client#requests`.

```ruby
Blog.requests # => [Blog::GetPosts, Blog::GetPost]
```

### Models

* `cistern` represents the associated `Blog::Real` or `Blog::Mock` instance. 
* `collection` represents the related collection.
* `new_record?` checks if `identity` is present
* `requires(*requirements)` throws `ArgumentError` if an attribute matching a requirement isn't set
* `requires_one(*requirements)` throws `ArgumentError` if no attribute matching requirement is set
* `merge_attributes(attributes)` sets attributes for the current model instance
* `dirty_attributes` represents attributes changed since the last `merge_attributes`.  This is useful for using `update`

#### Attributes

Cistern attributes are designed to make your model flexible and developer friendly.

* `attribute :post_id` adds an accessor to the model.
	```ruby
	attribute :post_id

	model.post_id #=> nil
	model.post_id = 1 #=> 1
	model.post_id #=> 1
	model.attributes #=> {'post_id' => 1 }
	model.dirty_attributes #=> {'post_id' => 1 }
	```
* `identity` represents the name of the model's unique identifier.  As this is not always available, it is not required.
	```ruby
	identity :name
	```

	creates an attribute called `name` that is aliased to identity.

	```ruby
	model.name = 'michelle'

	model.identity   #=> 'michelle'
	model.name       #=> 'michelle'
	model.attributes #=> {  'name' => 'michelle' }
	```
* `:aliases` or `:alias` allows a attribute key to be different then a response key. 
	```ruby
	attribute :post_id, alias: "post"
	```

	allows

	```ruby
	model.merge_attributes("post" => 1)
	model.post_id #=> 1
	```
* `:type` automatically casts the attribute do the specified type. 
	```ruby
	attribute :private_ips, type: :array

	model.merge_attributes("private_ips" => 2)
	model.private_ips #=> [2]
	```
* `:squash` traverses nested hashes for a key. 
	```ruby
	attribute :post_id, aliases: "post", squash: "id"

	model.merge_attributes("post" => {"id" => 3})
	model.post_id #=> 3
	```

#### Persistence

* `save` is used to persist the model into the remote service.  `save` is responsible for determining if the operation is an update to an existing resource or a new resource.
* `reload` is used to grab the latest data and merge it into the model.  `reload` uses `collection.get(identity)` by default.
* `update(attrs)` is a `merge_attributes` and a `save`.  When calling `update`, `dirty_attributes` can be used to persist only what has changed locally.


For example:

```ruby
class Blog::Post < Blog::Model
  identity :id, type: :integer

  attribute :body
  attribute :author_id, aliases: "author",  squash: "id"
  attribute :deleted_at, type: :time

  def destroy
    requires :identity

    data = cistern.destroy_post(params).body['post']
  end

  def save
    requires :author_id

    response = if new_record?
                 cistern.create_post(attributes)
               else
                 cistern.update_post(dirty_attributes)
               end

    merge_attributes(response.body['post'])
  end
end
```

Usage:

**create**

```ruby
blog.posts.create(author_id: 1, body: 'text')
```

is equal to

```ruby
post = blog.posts.new(author_id: 1, body: 'text')
post.save
```

**update**

```ruby
post = blog.posts.get(1)
post.update(author_id: 1) #=> calls #save with #dirty_attributes == { 'author_id' => 1 }
post.author_id #=> 1
```

### Singular

Singular resources do not have an associated collection and the model contains the `get` and`save` methods.

For instance:

```ruby
class Blog::PostData
  include Blog::Singular

  attribute :post_id, type: :integer
  attribute :upvotes, type: :integer
  attribute :views, type: :integer
  attribute :rating, type: :float

  def get
    response = cistern.get_post_data(post_id)
    merge_attributes(response.body['data'])
  end
  
  def save
    response = cistern.update_post_data(post_id, dirty_attributes)
    merge_attributes(response.data['data'])
  end
end
```

Singular resources often hang off of other models or collections.

```ruby
class Blog::Post
  include Cistern::Model

  identity :id, type: :integer

  def data
    cistern.post_data(post_id: identity).load
  end
end
```

They are special cases of Models and have similar interfaces.

```ruby
post.data.views #=> nil
post.data.update(views: 3)
post.data.views #=> 3
```


### Collection

* `model` tells Cistern which resource class this collection represents.
* `cistern` is the associated `Blog::Real` or `Blog::Mock` instance
* `attribute` specifications on collections are allowed. use `merge_attributes`
* `load` consumes an Array of data and constructs matching `model` instances

```ruby
class Blog::Posts < Blog::Collection

  attribute :count, type: :integer

  model Blog::Post

  def all(params = {})
    response = cistern.get_posts(params)

    data = response.body

    load(data["posts"])    # store post records in collection
    merge_attributes(data) # store any other attributes of the response on the collection
  end

  def discover(author_id, options={})
    params = {
      "author_id" => author_id,
    }
    params.merge!("topic" => options[:topic]) if options.key?(:topic)

    cistern.blogs.new(cistern.discover_blog(params).body["blog"])
  end

  def get(id)
    data = cistern.get_post(id).body["post"]

    new(data) if data
  end
end
```

### Associations

Associations allow the use of a resource's attributes to reference other resources.  They act as lazy loaded attributes
and push any loaded data into the resource's `attributes`.

There are two types of associations available.

* `belongs_to` references a specific resource and defines a reader.
* `has_many` references a collection of resources and defines a reader / writer.

```ruby
class Blog::Tag < Blog::Model
  identity :id
  attribute :author_id

  has_many :posts -> { cistern.posts(tag_id: identity) }
  belongs_to :creator -> { cistern.authors.get(author_id) }
end
```

Relationships store the collection's attributes within the resources' attributes on write / load.

```ruby
tag = blog.tags.get('ruby')
tag.posts = blog.posts.load({'id' => 1, 'author_id' => '2'}, {'id' => 2, 'author_id' => 3})
tag.attributes[:posts] #=> {'id' => 1, 'author_id' => '2'}, {'id' => 2, 'author_id' => 3}

tag.creator = blogs.author.get(name: 'phil')
tag.attributes[:creator] #=> { 'id' => 2, 'name' => 'phil' }
```

Foreign keys can be updated with with the association writer by aliasing the original writer and accessing the
underlying attributes.

```ruby
Blog::Tag.class_eval do
  alias cistern_creator= creator=
  def creator=(creator)
    self.cistern_creator = creator
    self.author_id = attributes[:creator][:id]
  end
end

tag = blog.tags.get('ruby')
tag.author_id = 4
tag.creator = blogs.author.get(name: 'phil') #=> #<Blog::Author id=2 name='phil'>
tag.author_id #=> 2
```

#### Data

A uniform interface for mock data is mixed into the `Mock` class by default.

```ruby
Blog.mock!
client = Blog.new # Blog::Mock
client.data       # Cistern::Data::Hash
client.data["posts"] += ["x"] # ["x"]
```

Mock data is class-level by default

```ruby
Blog::Mock.data["posts"] # ["x"]
```

`reset!` dimisses the `data` object.

```ruby
client.data.object_id # 70199868585600
client.reset!
client.data["posts"]  # []
client.data.object_id # 70199868566840
```

`clear` removes existing keys and values but keeps the same object.

```ruby
client.data["posts"] += ["y"] # ["y"]
client.data.object_id         # 70199868378300
client.clear
client.data["posts"]          # []
client.data.object_id         # 70199868378300
```

* `store` and `[]=` write
* `fetch` and `[]` read

You can make the service bypass Cistern's mock data structures by simply creating a `self.data` function in your service `Mock` declaration.

```ruby
class Blog
  include Cistern::Client

  class Mock
    def self.data
      @data ||= {}
    end
  end
end
```

#### Storage

Currently supported storage backends are:

* `:hash` : `Cistern::Data::Hash` (default)
* `:redis` : `Cistern::Data::Redis`


Backends can be switched by using `store_in`.

```ruby
# use redis with defaults
Patient::Mock.store_in(:redis)
# use redis with a specific client
Patient::Mock.store_in(:redis, client: Redis::Namespace.new("cistern", redis: Redis.new(host: "10.1.0.1"))
# use a hash
Patient::Mock.store_in(:hash)
```


#### Dirty

Dirty attributes are tracked and cleared when `merge_attributes` is called.

* `changed` returns a Hash of changed attributes mapped to there initial value and current value
* `dirty_attributes` returns Hash of changed attributes with there current value.  This should be used in the model `save` function.


```ruby
post = Blog::Post.new(id: 1, flavor: "x") # => <#Blog::Post>

post.dirty?           # => false
post.changed          # => {}
post.dirty_attributes # => {}

post.flavor = "y"

post.dirty?           # => true
post.changed          # => {flavor: ["x", "y"]}
post.dirty_attributes # => {flavor: "y"}

post.save
post.dirty?           # => false
post.changed          # => {}
post.dirty_attributes # => {}
```

### Custom Architecture

When configuring your client, you can use `:collection`, `:request`, and `:model` options to define the name of module or class interface for the service component.

For example: if you'd `Request` is to be used for a model, then the `Request` component name can be remapped to `Demand`

For example:

```ruby
class Blog
  include Cistern::Client.with(interface: :modules, request: "Demand")
end
```

allows a model named `Request` to exist

```ruby
class Blog::Request
  include Blog::Model

  identity :jovi
end
```

while living on a `Demand`

```ruby
class Blog::GetPost
  include Blog::Demand

  def real
    cistern.request.get("/wing")
  end
end
```

## Examples

* [zendesk2](https://github.com/lanej/zendesk2)
* [you_track](https://github.com/lanej/you_track)

## Releasing

    $ gem bump -trv (major|minor|patch)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
