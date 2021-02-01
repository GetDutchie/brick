[![Build Status](https://travis-ci.org/greenbits/brick.svg?branch=master)](https://travis-ci.org/greenbits/brick)

![An intuitive way to work with persistent data](./docs/logo.svg)

An intuitive way to work with persistent data in Dart.

## [Full documentation](https://brick.github.io)

## Why Brick?

* Out-of-the-box [offline access](packages/brick_offline_first) to data
* [Handle and hide](packages/brick_build) complex serialization/deserialization logic
* Single [access point](#repository) and opinionated DSL
* Automatic, [intelligently-generated migrations](packages/brick_sqlite)
* Legible [querying interface](#query)

## What is Brick?

Brick is an extensible query interface for Dart applications. It's an [all-in-one solution](https://www.youtube.com/watch?v=2noLcro9iIw) responsible for representing business data in the application, regardless of where your data comes from. Using Brick, developers can focus on implementing the application, without [concern for where the data lives](https://www.youtube.com/watch?v=jm5i7e_BQq0). Brick was inspired by the need for applications to work offline first, even if an API represents your source of truth.
