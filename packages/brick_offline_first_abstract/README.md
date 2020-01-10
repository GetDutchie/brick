# Brick Offline First Abstract

This package abstracts models and annotations required by both [brick_build](../brick_build) (which requires `dart:mirrors`) and [brick_sqlite](../brick_sqlite) (which uses Flutter and does not support `dart:mirrors`). While admittedly unintuitive, these classes can be imported cleanly by utilizing a separate package.
