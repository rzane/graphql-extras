# GraphQL::Extras [![Build Status](https://travis-ci.org/rzane/graphql-extras.svg?branch=master)](https://travis-ci.org/rzane/graphql-extras)

A collection of utilities for building GraphQL APIs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-extras'
```

And then execute:

    $ bundle

## Usage

### GraphQL::Extras::Controller

The [`graphql` gem](https://github.com/rmosolgo/graphql-ruby) will generate a controller for you with a bunch of boilerplate. This module will encapsulate that boilerplate:

```ruby
class GraphqlController < ApplicationController
  include GraphQL::Extras::Controller

  def execute
    graphql(schema: MySchema, context: { current_user: current_user })
  end
end
```

### GraphQL::Extras::Batch::AssociationLoader

This is a subclass of [`GraphQL::Batch::Loader`](https://github.com/Shopify/graphql-batch) that performs eager loading of Active Record associations.

```ruby
loader = GraphQL::Extras::Batch::AssociationLoader.for(:blog)
loader.load(Post.first)
loader.load_many(Post.all)
```

### GraphQL::Extras::Batch::Resolvers

This includes a set of convenience methods for query batching.

```ruby
class Post < GraphQL::Schema::Object
  include GraphQL::Extras::Batch::Resolver

  field :blog, BlogType, resolve: association(:blog), null: false
  field :comments, [CommentType], resolve: association(:comments, preload: { comments: :user }), null: false
  field :blog_title, String, null: false

  def blog_title
    association(object, :blog).then(&:title)
  end
end
```

### GraphQL::Extras::Types

In your base classes, you should include the `GraphQL::Extras::Types`.

```ruby
class BaseObject < GraphQL::Schema::Object
  include GraphQL::Extras::Types
end

class BaseInputObject < GraphQL::Schema::InputObject
  include GraphQL::Extras::Types
end
```

#### Date

This scalar takes a `Date` and transmits it as a string, using ISO 8601 format.

```ruby
field :birthday, Date, required: true
```

#### DateTime

This scalar takes a `DateTime` and transmits it as a string, using ISO 8601 format.

```ruby
field :created_at, DateTime, required: true
```

*Note: This is just an alias for the `ISO8601DateTime` type that is included in the `graphql` gem.*

#### Decimal

This scalar takes a `BigDecimal` and transmits it as a string.

```ruby
field :weight, BigDecimal, required: true
```

#### Upload

This scalar is used for accepting file uploads.

```ruby
field :image, Upload, required: true
```

It achieves this by passing in all file upload parameters through context. This will work out of the box if you're using `GraphQL::Extras::Controller`.

Here's an example using CURL:

    $ curl -X POST \
        -F query='mutation { uploadFile(image: "image") }' \
        -F image=@cats.png \
        localhost:3000/graphql

Take note of the correspondence between the value `"image"` and the additional HTTP parameter called `-F image=@cats.png`.

See [apollo-absinthe-upload-link](https://github.com/bytewitchcraft/apollo-absinthe-upload-link) for the client-side implementation.

### RSpec integration

Add the following to your `rails_helper.rb` (or `spec_helper.rb`).

```ruby
require "graphql/extras/rspec"
```

Now, you can run tests like so:

```ruby
RSpec.describe "hello" do
  let(:context) { { name: "Ray" } }
  let(:schema)  { use_schema(Schema, context: context) }
  let(:queries) { graphql_fixture("hello.graphql") }

  it "allows easily executing queries" do
    result = schema.execute(queries.hello)

    expect(result).to be_successful_query
    expect(result['data']['hello']).to eq("world")
  end
end
```

The `graphql_fixture` method assumes that your queries live in `spec/fixtures/graphql`. You can change this assumption with the following configuration:

```ruby
RSpec.configure do |config|
  config.graphql_fixture_path = '/path/to/queries'
end
```

## Development

To install dependencies:

    $ bundle install

To run the test suite:

    $ bundle exec rspec

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/graphql-extras.
