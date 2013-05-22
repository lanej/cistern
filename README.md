# Cistern

[![Build Status](https://secure.travis-ci.org/lanej/cistern.png)](http://travis-ci.org/lanej/cistern)
[![Dependencies](https://gemnasium.com/lanej/cistern.png)](https://gemnasium.com/lanej/cistern.png)

Cistern helps you consistenly build your API clients and faciliates building mock support.

## Usage

### Service

This represents the remote service that you are wrapping. If the service name is 'foo' then a good name is 'Foo::Client'.

Service initialization will only accept parameters enumerated by ```requires``` and ```recognizes```. ```model```, ```collection```, and ```request``` enumerate supported features and require them directly within the context of the ```model_path``` and ```request_path```.

```Mock.data``` is commonly used to store mock data.  It is often easiest to use identity to raw response mappings within the ```Mock.data``` hash.

    class Foo::Client < Cistern::Service

      model_path "foo/models"
      request_path "foo/requests"

      model :bar
      collection :bars
      request :create_bar
      request :get_bar
      request :get_bars

      requires :hmac_id, :hmac_secret
      recognizes :host

      class Real
        def initialize(options={})
          # setup connection
        end
      end

      class Mock
        def self.data
          @data ||= {
                      :bars => {},
                    }
        end

        def self.reset!
          @data = nil
        end

        def data
          self.class.data
        end
        def initialize(options={})
          # setup mock data
        end
      end
    end

### Model

```connection``` represents the associated ```Foo::Client``` instance.

    class Foo::Client::Bar < Cistern::Model
      identity :id

      attribute :flavor
      attribute :keypair_id, aliases: "keypair",  squash: "id"
      attribute :private_ips, type: :array

      def destroy
        params  = {
          "id" => self.identity
        }
        self.connection.destroy_bar(params).body["request"]
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
          request_attributes = connection.create_bar(params).body["request"]
          merge_attributes(new_attributes)
        end
      end
    end

### Collection

```model``` tells Cistern which class is contained within the collection.  ```Cistern::Collection``` inherits from ```Array``` and lazy loads where applicable.

    class Foo::Client::Bars < Cistern::Collection

      model Foo::Client::Bar

      def all(params = {})
        response = connection.get_bars(params)

        data = self.clone.load(response.body["bars"])

        collection.attributes.clear
        collection.merge_attributes(data)
      end

      def discover(provisioned_id, options={})
        params = {
          "provisioned_id" => provisioned_id,
        }
        params.merge!("location" => options[:location]) if options.key?(:location)

        connection.requests.new(connection.discover_bar(params).body["request"])
      end

      def get(id)
        if data = connection.get_bar("id" => id).body["bar"]
          new(data)
        else
          nil
        end
      end
    end


### Request

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
