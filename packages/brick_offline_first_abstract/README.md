# Brick Offline First Abstract

This package abstracts models and annotations required by both [brick_build](https://github.com/greenbits/brick/tree/master/packages/brick_build) (which requires `dart:mirrors`) and [brick_sqlite](https://github.com/greenbits/brick/tree/master/packages/brick_sqlite) (which uses Flutter and does not support `dart:mirrors`). While admittedly unintuitive, these classes can be imported cleanly by utilizing a separate package.
