# Changelog

<!--[//]: # (
## <Release number> <Date YYYY-MM-DD>
### Breaking changes
### Deprecations
### New features
### Bug fixes
)-->

## 1.1.4 2025-07-17

### New features

- Added the `comparison_input_type` field option. It is for internal use only and *not part of the public API documented in the [README](README.md)*. 

## 1.1.3 2025-05-21

### New features

- Added the `filtered_type` field option.

### Bug fixes

- Ensured the arguments of a `ComparisonInput` are defined after all the fields of the respective object type have been defined. Before, some cases of circular references made certain arguments not get defined.

## 1.1.2 2025-05-16

### Bug fixes

- Using `definition_methods` broke something in newer versions of the `graphql` gem. We now use `ActiveSupport::Concern`.

## 1.1.1 2025-05-16

### Bug fixes

- Relaxed the constraint on the `graphql` gem. It doesn't use semantic versioning, so the constraint was useless.

## 1.1.0 2025-04-14

### New features

- Added integration with interfaces.

## 1.0.8 2025-01-22

### Bug fixes

- Explicitly declared the dependency from `ostruct`.

## 1.0.7 2025-01-17

### Bug fixes

- Fixed `Filterable` redefining `resolve` instead of overriding it.

## 1.0.6 2025-01-17

### Bug fixes

- Fixed `NoMethodError` when using `Filterable` without `SearchObject` and not passing a filter.

## 1.0.5 2024-11-29

### Bug fixes

- Fixed an internal bug in resolution of the filtered type for a resolver.

## 1.0.4 2024-10-14

### New features

- Added `filtered_type` to declare a type for the filters which differs from the result type of the resolver.

### Bug fixes

- Fixed a broken `require`.

## 1.0.3 2024-10-09

### Bug fixes

- Made dependency to Rails more lax
- Extracted the pairing of models and GraphQL types into [a separate gem](https://github.com/moku-io/graphql-models_connect)

## 1.0.2 2023-07-24

### Bug fixes

- Fixed constant false conditions

## 1.0.1 2023-03-15

### Bug fixes

- Fixed the priority of options declarations for fields
- Fixed the override of `method_name` for the column name to use in the Active Record query

## 1.0.0 2023-03-06

First release. Refer to [README.md](README.md) for the full documentation.
