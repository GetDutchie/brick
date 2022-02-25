## Unreleased

* Loosen dependency restrictions to major versions

## 2.0.0

* **BREAKING CHANGE** This package no longer manages the `OfflineFirstWithRest` domain. Please add `brick_offline_first_with_rest: any` to your `pubspec.yaml` and update package imports to use this new package.
* **BREAKING CHANGE** This package no longer manages the `OfflineFirstWithGraphql` domain. Please add `brick_offline_first_with_graphql: any` to your `pubspec.yaml` and update package imports to use this new package.
* Add Dart Lints
* Upgrade `brick_core`
* Add `ConnectOfflineFirstWithGraphql` annotation

## 2.0.0-rc.2

* **BREAKING CHANGE** This package no longer manages the `OfflineFirstWithRest` domain. Please add `brick_offline_first_with_rest: any` to your `pubspec.yaml` and update package imports to use this new package.
* **BREAKING CHANGE** This package no longer manages the `OfflineFirstWithGraphql` domain. Please add `brick_offline_first_with_graphql: any` to your `pubspec.yaml` and update package imports to use this new package.

## 2.0.0-rc.1

* Add Dart Lints
* Upgrade `brick_core`
* Add `ConnectOfflineFirstWithGraphql` annotation

## 1.0.0+1

* Null safety cleanup and refactor

## 1.0.0

* Null safety

## 0.0.8

* Bump dependency versions

## 0.0.7

* Bump dependency versions

## 0.0.5

* Bump dependency versions
* Remove placeholders from `OfflineFirst` annotation (moves to `FieldSerializable`)

## 0.0.3

* Rename `ConnectOfflineFirst` as `ConnectOfflineFirstWithRest` to reflect the narrow scope of the annotation

## 0.0.2

* Fix linter hints

## 0.0.1+1

* SqliteModel moved from this package to `brick_sqlite_abstract`
