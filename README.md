# GraphQL Filters

A way to define automated filters on GraphQL fields.

This gem provides a module to include (or prepend, see below) in your resolvers that will automatically generate a tree of input types that your clients can use to filter the result of their queries. The filters are completely typed in the GraphQL schema, and are transpiled into an Active Record relation. The relation uses subqueries instead of joins to apply filters on associations, which might be less efficient. This, however, makes it possible for the client to make a query like "I need all the Kanto routes where I can catch Oddish, but for each route I also need all the other Pokémon".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-filters', '~> 0.1.0'
```

And then execute:
```bash
$ bundle
```

## Usage

The easiest way to use GraphQL Filters is on top of [SearchObject](https://github.com/RStankov/SearchObject) and its [GraphQL plugin](https://github.com/RStankov/SearchObjectGraphQL). Just include `GraphQL::Filters::Filterable` in your resolvers, and it will add an option to automatically filter the underlying collection. For example:

```ruby
class RoutesResolver < BaseResolver
  include SearchObject.module(:graphql)
  
  scope { Route.all }

  type [RouteType], null: false

  include GraphQL::Filters::Filterable
end
```

Otherwise, you have to explicitly define a `resolve` method and have it return an `ActiveRecord::Relation`; in this case youy need to prepend `GraphQL::Filters::Filterable` in the resolver, otherwise it won't have access to the starting scope:

```ruby
class RoutesResolver < BaseResolver
  type [RouteType], null: false
  
  def resolve
    Route.all
  end

  prepend GraphQL::Filters::Filterable
end
```

Using either of these resolvers for a `routes` field will generate all the necessary input types to make a query like this:

```graphql
query {
  routes(
    filter: {
      fields: {
        region: {
          fields: {
            name: { equals: "Kanto" }
          }
        },
        catchablePokemon: {
          any: {
            fields: {
              pokemon: {
                types: {
                  any: {
                    fields: {
                      name: { equals: "Water"}
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ){
    name
    trainers{
      name
      isDouble
    }
    catchablePokemon{
      levelRange
      rate
      pokemon{
        name
        types{
          name
        }
      }
    }
}
```

Notice that eager loading is outside the scope of this gem, so if without anything else the above query will fall victim to the N+1 problem.

Each input type is generated based on the respective type: scalar and enum types allow for basic comparisons like equality and inclusion, while object types let you build complex queries that mix and match comparisons on their fields. List types let you make `any`, `all`, and `none` queries based on a nested filter. Support for null-checked filters is planned for future development.

### Underlying models

GraphQL Filters relies on the assumption that every object type exists on top of an Active Record model. A field of type `PokemonType` will always be resolved to an instance of `Pokemon`, and its fields will match (at least loosely) the attributes of the model. This assumption allows the gem to generate appropriate subqueries for nested filters.

By default, the gem assumes that if an object type is `<Name>Type`, then its underlying model is `<Name>` and it is in the same module. This isn't always the case, especially if you follow the convention suggested by the GraphQL Ruby documentation, so all your object types are in a `Types` module. For a single exception you can explicitly declare the model inside your object type:

```ruby
module Types
  class PokemonType < BaseObject
    model_class Pokemon
    ...
  end
end
```

To change the default behavior of the gem, override the `default_model_class` class method in your base object class:

```ruby
module Types
  class BaseObject < GraphQL::Schema::Object
    def self.default_model_class
      model_name = name
                     .delete_prefix('Types::')
                     .delete_suffix('Type')

      const_get model_name
    end
  end
end
```

### Comparators

The best way to know what comparators you can use with each field is to open the GraphQL schema in your favorite client. What follows is a description of what each comparator does; unless explicitly indicated, `not<Comparison>` will match if and only if `<comparison>` will not.

#### Constant

`constant` is available for all types, and either always or never matches, depending on the passed boolean value. It can be useful to build complex filters.

#### Equality

`equals` is available for all scalar and enum types, and their respective list types, and matches if the field has the provided value.

#### Inclusion

`in` is available for all scalar and enum types, and their respective list types, and matches if the field has one of the provided values.

#### Numerical comparisons

`greaterThan`, `greaterThanOrEqualsTo`, `lessThan` and `lessThanOrEqualsTo` are available for numerical types (including `ISO8601Date` and `ISO8601DateTime`) and behave as expected.

#### Pattern matching

`matches` is available for the `String` type. Its value is a string in the format `<version>/<pattern>/<options>`.

- At the moment, `<version>` can only be `v1`, but extensions are planned for future development.
- For version `v1`, `<pattern>` will match a `.` with any one character and a `*` with zero or more characters. To match any literal character you can prefix it with `\​`.
- For version `v1`, `<options>` can be empty, or be `i`, which will make the match case insensitive.

#### List comparisons

`any`, `all`, and `none` are available for any list, take a comparator for the type of the elements of the list, and match, respectively, if at least one, all, or none, of the elements of the list match the nested comparator.

#### Object comparisons

For each object type `<Type>`, two comparison input types are generated. `<Type>ComplexFilterInput` has `and`, `or`, and `not` fields to build complex comparators, plus a `fields` field of type `<Type>ComparisonInput`. For each field of `<Type>`, `<Type>ComparisonInput` has a field with the same name and the respective comparison input type. For example , if `Pokemon` has a `name` field of type `String`, then `PokemonComparisonInput` has a `name` field of type `StringComparisonInput`.

### Configuration

To configure the behavior of GraphQL Filters, create an initializer in `config/initializers`, and call the `configure` method:

```ruby
GraphQL::Filters.configure do |config|
  ...
end
```

#### `config.base_input_object_class`

By default, GraphQL Filters uses `GraphQL::Schema::InputObject` as base class for comparison input types. To use another class, assign it to `config.base_input_object_class`.

### Options

The `field` method accepts some options that can tweak the generated input types and the transpilation of the arguments into a query. You can pass these options in three ways, in order of priority:

- as a keyword argument to the `field` method:

```ruby
field :name, String, null: false, filter: {...}
```

- as a single positional argument to the `filter` method inside the block you pass to the `field` method:

```ruby
field :name, String, null: false do
  filter({...})
end
```

- as keyword arguments to the `filter` method inside the block you pass to the `field` method:

```ruby
field :name, String, null: false do
  filter ...
end
```

#### Valid options

- `enabled`

  Can be `true` or `false` (default: `true`). Controls whether or not the client can use this field in the filters. Passing `true` or `false` directly to `filter` is a shortcut:

```ruby
field :name, String, null: false, filter: false 

# is equivalent to

field :name, String, null: false, filter: {enabled: false}
```

- `attribute_name`

  The name of the attribute that the field is tied to in the model. Defaults to the name of the resolver method for the field (which by default is the same as the name of the field itself).

- `association_name`
  
  The name of the Active Record association that the field is tied to in the model. Equivalent to `attribute_name`, has the same default.

## Version numbers

GraphQL Filters loosely follows [Semantic Versioning](https://semver.org/), with a hard guarantee that breaking changes to the public API will always coincide with an increase to the `MAJOR` number.

Version numbers are in three parts: `MAJOR.MINOR.PATCH`.

- Breaking changes to the public API increment the `MAJOR`. There may also be changes that would otherwise increase the `MINOR` or the `PATCH`.
- Additions, deprecations, and "big" non breaking changes to the public API increment the `MINOR`. There may also be changes that would otherwise increase the `PATCH`.
- Bug fixes and "small" non breaking changes to the public API increment the `PATCH`.

Notice that any feature deprecated by a minor release can be expected to be removed by the next major release.

## Changelog

Full list of changes in [CHANGELOG.md](CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moku-io/graphql-filters.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
