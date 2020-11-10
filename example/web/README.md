# flutter_launcher_icons

A new example Flutter project to quickly test flutter_launcher_icons, **with web support**.

# Using it

 * Open a terminal and switch to the example directory.
 * Run `flutter create .`. This creates the folders with generated code (i.e. `web`, `android`, `ios`, etc.)
  * Any files this creates in `tests` can be deleted.
 * Run `flutter pub run flutter_launcher_icons:main` to generate icons based on the contents of `pubspec.yaml`
      - If this fails, you might not have web support enabled! 
        Consider setting `web: ` to `false` in `pubspec.yaml` or [enabling web support](https://flutter.dev/docs/get-started/web)!
