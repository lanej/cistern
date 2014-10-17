# Cistern

[![Build Status](https://secure.travis-ci.org/lanej/cistern.png)](http://travis-ci.org/lanej/cistern)
[![Dependencies](https://gemnasium.com/lanej/cistern.png)](https://gemnasium.com/lanej/cistern.png)

Cistern helps you consistenly build your API clients and faciliates building mock support.

## Usage

### Service

This represents the remote service that you are wrapping. If the service name is 'foo' then a good name is 'Foo::Client'.

#### Requests

Requests are enumerated using the `request` method and required immediately via the relative path specified via `request_path`.

```ruby
class Foo::Client < Cistern::Service
  request_path "my-foo/requests"

  request :get_bar  # require my-foo/requests/get_bar.rb
  request :get_bars # require my-foo/requests/get_bars.rb

  class Real
    def request(url)
      Net::HTTP.get(url)
    end
  end
end
```


<!--todo move to a request section-->
A request is method defined within the context of service and mode (Real or Mock).  Defining requests within the service mock class is optional.

```ruby
# my-foo/requests/get_bar.rb
class Foo::Client
  class Real
    def get_bar(bar_id)
      request("http://example.org/bar/#{bar_id}")
    end
  end # Real

  # optional, but encouraged
  class Mock
    def get_bars
      # do some mock things
    end
  end # Mock
end # Foo::client
```

All declared requests can be listed via `Cistern::Service#requests`.

```ruby
Foo::Client.requests # => [:get_bar, :get_bars]
```

#### Models and Collections

Models and collections have declaration semantics similar to requests.  Models and collections are enumerated via `model` and `collection` respectively.

```ruby
class Foo::Client < Cistern::Service
  model_path "my-foo/models"

  model :bar       # require my-foo/models/bar.rb
  collection :bars # require my-foo/models/bars.rb
end
```

#### Initialization

Service initialization parameters are enumerated by `requires` and `recognizes`.  `recognizes` parameters are optional.

```ruby
class Foo::Client < Cistern::Service
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


### Mocking

Cistern strongly encourages you to generate mock support for service. Mocking can be enabled using `mock!`.

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

client.data.object_id        # 70199868566840
```

* `store` and `[]=` write
* `fetch` and `[]` read

You can make the service bypass Cistern's mock data structures by simply creating a `self.data` function in your service `Mock` declaration.

```ruby
class Foo::Client < Cistern::Service
  class Mock
    def self.data
      @data ||= {}
    end
  end
end
```


#### Requests

Mock requests should be defined within the contextual `Mock` module and interact with the `data` object directly.

```ruby
# lib/foo/requests/create_bar.rb
class Foo::Client
  class Mock
    def create_bar(options={})
      id = Foo.random_hex(6)

      bar = {
        "id" => id
      }.merge(options)

      self.data[:bars][id] = bar

      response(
        :body   => {"bar" => bar},
        :status => 201,
        :path => '/bar',
      )
    end
  end # Mock
end # Foo::Client
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

### Model

* `service` represents the associated `Foo::Client` instance.
* `collection` represents the related collection (if applicable)

Example

```ruby
class Foo::Client::Bar < Cistern::Model
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

### Collection

`model` tells Cistern which class is contained within the collection.  `Cistern::Collection` inherits from `Array` and lazy loads where applicable.

```ruby
class Foo::Client::Bars < Cistern::Collection

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

### Request

```ruby
module Foo
  class Client
    class Real
      def create_bar(options={})
        request(
          :body     => {"bar" => options},
          :method   => :post,
          :path     => '/bar'
        )
      end
    end # Real

    class Mock
      def create_bar(options={})
        id = Foo.random_hex(6)

        bar = {
          "id" => id
        }.merge(options)

        self.data[:bars][id]= bar

        response(
          :body   => {"bar" => bar},
          :status => 201,
          :path => '/bar',
        )
      end
    end # Mock
  end # Client
end # Foo
```

## Examples

* [zendesk2](https://github.com/lanej/zendesk2)

## Releasing

    $ gem bump -trv (major|minor|patch)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
