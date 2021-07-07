# example_with_flavors

A new Flutter project to showcase how to use different icons

## How to run this project

After cloning, run `flutter create .` in the project's root directory to create folders with generated code (i.e. `web`, `ios`, `android`, ...).

This project has the following flavors:

- production: `flutter run --flavor production`
- development: `flutter run --flavor development`
- integration: `flutter run --flavor integration`

## Notes

- `flutter_launcher_icons-development.yaml` and `flutter_launcher_icons-integration.yaml` both contain `web: false`, while
`flutter_launcher_icons-production.yaml` contains `web: true`. If you don't need to support `web`, these lines can be omitted (similar to
in the [default example](../default_example))! For more information about supporting `web` while using flavored icons for
`iOS` and `android`, please see the [project's README!](../../README.md#flutter-run---flavor-doesnt-work-with-web)