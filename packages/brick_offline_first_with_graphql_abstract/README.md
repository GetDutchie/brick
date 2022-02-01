![brick_offline_first_with_graphql_abstract workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_graphql_abstract.yaml/badge.svg)

# Brick Offline First with GraphQL Abstract

This package abstracts models and annotations required by both [brick_build](https://github.com/GetDutchie/brick/tree/main/packages/brick_build) (which requires `dart:mirrors`) and [brick_sqlite](https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite) (which uses Flutter and does not support `dart:mirrors`). While admittedly unintuitive, these classes can be imported cleanly by utilizing a separate package.
