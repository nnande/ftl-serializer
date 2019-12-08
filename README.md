# FTL (Faster Than Light) Serializer 🚀

A ruby serializer that can make the kessel run in less than 12 parsecs.

## Why FTL?
This library is an extraction from Fullscript. We originally wrote this at a time when there weren't many options out there. Serializers were mostly slow, with over-complicated DSLs, or they weren't flexible enough for our needs (for example only supporting a specific spec like JSON:API).

Our main design decisions centered around 3 principles.

- Speed. Slow stuff happens at boot time rather than at runtime. 
- Simple DSL. We've opted for a very simple DSL. Mostly to avoid any meta-programming slowness (no has_many, belongs_to, etc. that you see in most serializers) but we also wanted an early-career developer pick up FTL without much effort.
- Flexibility. You should be able to serialize data to an existing spec (like JSON:API) or come up with your own.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ftl-serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ftl-serializer

Then in an initializer you just need to point to the path(s) where you're FTL serializers live.

```ruby
# app/initializers/ftl.rb

FTL::Configuration.serializer_paths = ["#{Rails.root.join}/app/serializers"]
```

## Usage

### Example Rails Model

For our examples here's a simple Rails Model. (Note that FTL can accept any data structure and isn't limited to models.)

```ruby
class Ship
  belongs_to :classification
  
  attr_accessor :id, :name, :special_modifications
end
```

```ruby
ship = Ship.new(id: 10, name: "Millenium Falcon", special_modifications: true, classification_id: 20)
```


### Serializer Definition

We define our serializer by inheriting from FTL::Serializer::Base

```ruby
class FastestHunkOfJunkInTheGalaxy < FTL::Serializer::Base
  attributes :name, :special_modifications, :type

  def type
    obj.classification.name
  end
end
```

#### .to_h

```ruby
hash = FastestHunkOfJunkInTheGalaxy.new(ship).to_h
```

returns:

```ruby
{
  id: "10",
  name: "Millenium Falcon",
  special_modifications: true,
  type: "YT-1300 Corellian light freighter"
}
```


#### .to_json

```ruby
json_string = FastestHunkOfJunkInTheGalaxy.new(ship).to_json
```

returns:

```json
{
  "id": "10",
  "name": "Millenium Falcon",
  "special_modifications": true,
  "type": "YT-1300 Corellian light freighter"
}
```

### Options

#### format

By default FTL underscores the key names but it also supports camel case.

```ruby
class FastestHunkOfJunkInTheGalaxy < FTL::Serializer::Base
  # Available options :camel, :underscore (default)
  format :camel
end
```

Examples:

```ruby
keys :camel # "some_key" => "someKey"
keys :underscore # "some_key" => "some_key"
```

#### root

FTL can also support a root key.

```ruby
class FastestHunkOfJunkInTheGalaxy < FTL::Serializer::Base
  root "starship"
end
```

Returns:

```json
{
  "starship": {
    "id": "10",
    "name": "Millenium Falcon",
    "special_modifications": true,
    "type": "YT-1300 Corellian light freighter"
  }
}
```

Roots can also be disabled when you are initializing your serializer. (Occasionally helpful when calling other serializers from within another serializer.)

```ruby
FastestHunkOfJunkInTheGalaxy.new(obj).root(:disabled)
```

### Attributes

Attributes are defined using the `attributes` keyword.

```ruby
class FastestHunkOfJunkInTheGalaxy < FTL::Serializer::Base
  attributes :name
end
```

Custom attributes can be overridden by defining a method.

The object (that is passed into the serializer) is referrenced to as `obj`.

```ruby
class FastestHunkOfJunkInTheGalaxy < FTL::Serializer::Base
  attributes :name

  def name
    obj.first_name
  end
end
```

### Locals

In some cases, you might want to use some ancillary data that's not necessarily available on your objects. For example, `current_user` or `current_account` are examples of a dependency that you may want to inject into your serializer.

To do this you can just pass a `locals` hash into the serializer.

```ruby
class FastestHunkOfJunkInTheGalaxy < FTL::Serializer::Base
  attributes :name, :current_pilot

  def current_pilot
    locals.current_pilot.full_name
  end
end

# ...
lando = User.find_by(first_name: "Lando", last_name: "Calrissian")
serializer = FastestHunkOfJunkInTheGalaxy.new(ship, { locals: { current_pilot: lando } })
serializer.to_h
```

Locals can be in a hash format or it can be chained as a method.

```ruby
# This is the same:
FastestHunkOfJunkInTheGalaxy.new(ship, { locals: { current_pilot: lando } })

# as this:
FastestHunkOfJunkInTheGalaxy.new(ship).locals(current_pilot: lando)
```

### Loading

It's also worth mentioning how serializers are loaded. They're hooked into a `Rails::Railtie` that loads up the serializers and sets all the attributes during the Rails boot time. We did this for speed so that everything is ready to go and we don't need to do any expensive meta-programming when you call your serializer. All the attributes are set and you just need to pass it some data to serialize.

If you ever need to manually load up a serializer it's just:

```ruby
FTL::Serializer.bootstrap!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fullscript/ftl-serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ftl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ftl/blob/master/CODE_OF_CONDUCT.md).
