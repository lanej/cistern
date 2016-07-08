# Cistern

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

This represents the remote service that you are wrapping. If the service name is `foo` then a good name is `Blog`.

Service initialization parameters are enumerated by `requires` and `recognizes`. Parameters defined using `recognizes` are optional.

```ruby
# lib/foo.rb
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

Cistern will define for you two classes, `Mock` and `Real`.

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

* `cistern` represents the associated `Blog` instance.
* `collection` represents the related collection (if applicable)
* `new_record?` checks if `identity` is present
* `requires(*requirements)` throws `ArgumentError` if an attribute matching a requirement isn't set
* `merge_attributes(attributes)` sets attributes for the current model instance

#### Attributes

Attributes are designed to be a flexible way of parsing service request responses.

`identity` is special but not required.

`attribute :flavor` makes `Blog::Post.new.respond_to?(:flavor)`

* `:aliases` or `:alias` allows a attribute key to be different then a response key. `attribute :keypair_id, alias: "keypair"` with `merge_attributes("keypair" => 1)` sets `keypair_id` to `1`
* `:type` automatically casts the attribute do the specified type. `attribute :private_ips, type: :array` with `merge_attributes("private_ips" => 2)` sets `private_ips` to `[2]`
* `:squash` traverses nested hashes for a key. `attribute :keypair_id, aliases: "keypair", squash: "id"` with `merge_attributes("keypair" => {"id" => 3})` sets `keypair_id` to `3`

Example

```ruby
class Blog::Post < Blog::Model
  identity :id

  attribute :flavor
  attribute :keypair_id, aliases: "keypair",  squash: "id"
  attribute :private_ips, type: :array

  def destroy
    params  = {
      "id" => self.identity
    }
    self.cistern.destroy_post(params).body["request"]
  end

  def save
    requires :keypair_id

    params = {
      "keypair" => self.keypair_id,
      "post"     => {
        "flavor" => self.flavor,
      },
    }

    if new_record?
      merge_attributes(cistern.create_post(params).body["post"])
    else
      requires :identity

      merge_attributes(cistern.update_post(params).body["post"])
    end
  end
end
```

### Collection

* `model` tells Cistern which class is contained within the collection.
* `cistern` is the associated `Blog` instance
* `attribute` specifications on collections are allowed. use `merge_attributes`
* `load` consumes an Array of data and constructs matching `model` instances

```ruby
class Blog::Posts < Blog::Collection

  attribute :count, type: :integer

  model Blog::Post

  def all(params = {})
    response = cistern.get_posts(params)

    data = response.body

    self.load(data["posts"])     # store post records in collection
    self.merge_attributes(data) # store any other attributes of the response on the collection
  end

  def discover(provisioned_id, options={})
    params = {
      "provisioned_id" => provisioned_id,
    }
    params.merge!("location" => options[:location]) if options.key?(:location)

    cistern.requests.new(cistern.discover_post(params).body["request"])
  end

  def get(id)
    if data = cistern.get_post("id" => id).body["post"]
      new(data)
    else
      nil
    end
  end
end
```

#### Data

A uniform interface for mock data is mixed into the `Mock` class by default.

```ruby
Blog.mock!
client = Blog.new     # Blog::Mock
client.data                  # Cistern::Data::Hash
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
client.data["posts"]   # []
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
