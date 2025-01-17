# Changelog

<!--[//]: # (
## <Release number> <Date YYYY-MM-DD>
### Breaking changes
### Deprecations
### New features
### Bug fixes
)-->

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
