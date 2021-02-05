<h1 align="center">GraphQL::Extras</h1>

<div align="center">

![Build](https://github.com/rzane/graphql-extras/workflows/Build/badge.svg)
![Version](https://img.shields.io/gem/v/graphql-extras)

</div>

A collection of utilities for building GraphQL APIs.

**Table of Contents**

- [Installation](#installation)
- [Usage](#usage)
  - [GraphQL::Extras::Controller](#graphqlextrascontroller)
  - [GraphQL::Extras::AssociationLoader](#graphqlextrasassociationloader)
  - [GraphQL::Extras::Preload](#graphqlextraspreload)
  - [GraphQL::Extras::Types](#graphqlextrastypes)
    - [Date](#date)
    - [DateTime](#datetime)
    - [Decimal](#decimal)
    - [Upload](#upload)
  - [GraphQL::Extras::Test](#graphqlextrastest)
- [Development](#development)
- [Contributing](#contributing)

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

### GraphQL::Extras::AssociationLoader

This is a subclass of [`GraphQL::Batch::Loader`](https://github.com/Shopify/graphql-batch) that performs eager loading of Active Record associations.

```ruby
loader = GraphQL::Extras::AssociationLoader.for(:blog)
loader.load(Post.first)
loader.load_many(Post.all)
```

### GraphQL::Extras::Preload

This allows you to preload associations before resolving fields.

```ruby
class BaseField < GraphQL::Schema::Field
  prepend GraphQL::Extras::Preload
end

class BaseObject < GraphQL::Schema::Object
  field_class BaseField
end

class PostType < BaseObject
  field :author, AuthorType, preload: :author, null: false
  field :author_posts, [PostType], preload: {author: :posts}, null: false
  field :depends_on_author, Integer, preload: :author, null: false

  def author_posts
    object.author.posts
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

_Note: This is just an alias for the `ISO8601DateTime` type that is included in the `graphql` gem._

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

See [apollo-link-upload](https://github.com/rzane/apollo-link-upload) for the client-side implementation.

### GraphQL::Extras::Test

This module makes it really easy to test your schema.

First, create a test schema:

```ruby
# spec/support/test_schema.rb
require "graphql/extras/test"

class TestSchema < GraphQL::Extras::Test::Schema
  configure schema: Schema, queries: "spec/**/*.graphql"
end
```

Now, you can run tests like so:

```ruby
require "support/test_schema"

RSpec.describe "hello" do
  let(:context) { { name: "Ray" } }
  let(:schema)  { TestSchema.new(context) }

  it "allows easily executing queries" do
    query = schema.hello

    expect(query).to be_successful
    expect(query.data["hello"]).to eq("world")
  end

  it "parses errors" do
    query = schema.kaboom

    expect(query).not_to be_successful
    expect(query.errors[0].message).to eq("Invalid")
    expect(query.errors[0].code).to eq("VALIDATION_ERROR")
  end
end
```

## Development

To install dependencies:

    $ bundle install

To run the test suite:

    $ bundle exec rspec

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/graphql-extras.
