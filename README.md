# Cistern

[![Build Status](https://secure.travis-ci.org/lanej/cistern.png)](http://travis-ci.org/lanej/cistern)
[![Dependencies](https://gemnasium.com/lanej/cistern.png)](https://gemnasium.com/lanej/cistern.png)
[![Gem Version](https://badge.fury.io/rb/cistern.svg)](http://badge.fury.io/rb/cistern)
[![Code Climate](https://codeclimate.com/github/lanej/cistern/badges/gpa.svg)](https://codeclimate.com/github/lanej/cistern)

Cistern helps you consistently build your API clients and faciliates building mock support.

## Usage

### Service

This represents the remote service that you are wrapping. If the service name is `foo` then a good name is `Foo::Client`.

Service initialization parameters are enumerated by `requires` and `recognizes`. Parameters defined using `recognizes` are optional.

```ruby
class Foo::Client
  include Cistern::Client

  requires :hmac_id, :hmac_secret
  recognizes :url
end

# Acceptable
Foo::Client.new(hmac_id: "1", hmac_secret: "2")                            # Foo::Client::Real
Foo::Client.new(hmac_id: "1", hmac_secret: "2", url: "http://example.org") # Foo::Client::Real

# ArgumentError
Foo::Client.new(hmac_id: "1", url: "http://example.org")
Foo::Client.new(hmac_id: "1")
```

Cistern will define for you two classes, `Mock` and `Real`.

### Mocking

Cistern strongly encourages you to generate mock support for your service. Mocking can be enabled using `mock!`.

```ruby
Foo::Client.mocking?          # falsey
real = Foo::Client.new        # Foo::Client::Real
Foo::Client.mock!
Foo::Client.mocking?          # true
fake = Foo::Client.new        # Foo::Client::Mock
Foo::Client.unmock!
Foo::Client.mocking?          # false
real.is_a?(Foo::Client::Real) # true
fake.is_a?(Foo::Client::Mock) # true
```

### Requests

Requests are defined by subclassing `#{service}::Request`.

* `service` represents the associated `Foo::Client` instance.

```ruby
class Foo::Client::GetBar < Foo::Client::Request
  def real(params)
    # make a real request
    "i'm real"
  end

  def mock(params)
    # return a fake response
    "imposter!"
  end
end

Foo::Client.new.get_bar # "i'm real"
```

The `#service_method` function allows you to specify the name of the generated method.

```ruby
class Foo::Client::GetBars < Foo::Client::Request
  service_method :get_all_the_bars

  def real(params)
    "all the bars"
  end
end

Foo::Client.new.respond_to?(:get_bars) # false
Foo::Client.new.get_all_the_bars       # "all the bars"
```

All declared requests can be listed via `Cistern::Client#requests`.

```ruby
Foo::Client.requests # => [Foo::Client::GetBars, Foo::Client::GetBar]
```

### Models

* `service` represents the associated `Foo::Client` instance.
* `collection` represents the related collection (if applicable)
* `new_record?` checks if `identity` is present
* `requires(*requirements)` throws `ArgumentError` if an attribute matching a requirement isn't set
* `merge_attributes(attributes)` sets attributes for the current model instance

#### Attributes

Attributes are designed to be a flexible way of parsing service request responses.

`identity` is special but not required.

`attribute :flavor` makes `Foo::Client::Bar.new.respond_to?(:flavor)`

* `:aliases` or `:alias` allows a attribute key to be different then a response key. `attribute :keypair_id, alias: "keypair"` with `merge_attributes("keypair" => 1)` sets `keypair_id` to `1`
* `:type` automatically casts the attribute do the specified type. `attribute :private_ips, type: :array` with `merge_attributes("private_ips" => 2)` sets `private_ips` to `[2]`
* `:squash` traverses nested hashes for a key. `attribute :keypair_id, aliases: "keypair", squash: "id"` with `merge_attributes("keypair" => {"id" => 3})` sets `keypair_id` to `3`

Example

```ruby
class Foo::Client::Bar < Foo::Client::Model
  identity :id

  attribute :flavor
  attribute :keypair_id, aliases: "keypair",  squash: "id"
  attribute :private_ips, type: :array

  def destroy
    params  = {
      "id" => self.identity
    }
    self.service.destroy_bar(params).body["request"]
  end

  def save
    requires :keypair_id

    params = {
      "keypair" => self.keypair_id,
      "bar"     => {
        "flavor" => self.flavor,
      },
    }

    if new_record?
      merge_attributes(service.create_bar(params).body["bar"])
    else
      requires :identity

      merge_attributes(service.update_bar(params).body["bar"])
    end
  end
end
```

### Collection

* `model` tells Cistern which class is contained within the collection.
* `service` is the associated `Foo::Client` instance
* `attribute` specifications on collections are allowed. use `merge_attributes`
* `load` consumes an Array of data and constructs matching `model` instances

```ruby
class Foo::Client::Bars < Foo::Client::Collection

  attribute :count, type: :integer

  model Foo::Client::Bar

  def all(params = {})
    response = service.get_bars(params)

    data = response.body

    self.load(data["bars"])     # store bar records in collection
    self.merge_attributes(data) # store any other attributes of the response on the collection
  end

  def discover(provisioned_id, options={})
    params = {
      "provisioned_id" => provisioned_id,
    }
    params.merge!("location" => options[:location]) if options.key?(:location)

    service.requests.new(service.discover_bar(params).body["request"])
  end

  def get(id)
    if data = service.get_bar("id" => id).body["bar"]
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
Foo::Client.mock!
client = Foo::Client.new     # Foo::Client::Mock
client.data                  # Cistern::Data::Hash
client.data["bars"] += ["x"] # ["x"]
```

Mock data is class-level by default

```ruby
Foo::Client::Mock.data["bars"] # ["x"]
```

`reset!` dimisses the `data` object.

```ruby
client.data.object_id # 70199868585600
client.reset!
client.data["bars"]   # []
client.data.object_id # 70199868566840
```

`clear` removes existing keys and values but keeps the same object.

```ruby
client.data["bars"] += ["y"] # ["y"]
client.data.object_id        # 70199868378300
client.clear
client.data["bars"]          # []
client.data.object_id        # 70199868378300
```

* `store` and `[]=` write
* `fetch` and `[]` read

You can make the service bypass Cistern's mock data structures by simply creating a `self.data` function in your service `Mock` declaration.

```ruby
class Foo::Client
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
bar = Foo::Client::Bar.new(id: 1, flavor: "x") # => <#Foo::Client::Bar>

bar.dirty?           # => false
bar.changed          # => {}
bar.dirty_attributes # => {}

bar.flavor = "y"

bar.dirty?           # => true
bar.changed          # => {flavor: ["x", "y"]}
bar.dirty_attributes # => {flavor: "y"}

bar.save
bar.dirty?           # => false
bar.changed          # => {}
bar.dirty_attributes # => {}
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
