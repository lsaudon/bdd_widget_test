# bdd_widget_test [![Build Status](https://github.com/olexale/bdd_widget_test/actions/workflows/dart.yml/badge.svg)](https://github.com/olexale/bdd_widget_test/actions/workflows/dart.yml) [![Coverage Status](https://coveralls.io/repos/github/olexale/bdd_widget_test/badge.svg?branch=master)](https://coveralls.io/github/olexale/bdd_widget_test?branch=master) [![pub package](https://img.shields.io/pub/v/bdd_widget_test.svg)](https://pub.dartlang.org/packages/bdd_widget_test)

A BDD-style widget testing library

## Why?

Isn't it cool to develop mobile apps in natural language? A language each of your team members can read and understand so that it involves everyone working on the project productively. While Dart is on its way to this goal, for tests there is a language for that! It's called Gherkin.

The aim of this library is in combining two effective and easy-to-use techniques: BDD(Gherkin) and widget testing.

## Getting Started

### Add the dependency

Add `build_runner` and `bdd_widget_test` dependencies to `dev_dependencies` section of the `pubspec.yaml` file.
```yaml
dev_dependencies:
  build_runner:
  bdd_widget_test: <put the latest version here>
  ...
```

You may get the actual version from [installation instructions](https://pub.dartlang.org/packages/bdd_widget_test#-installing-tab-) on Pub site.

### Write features

Create `*.feature` file inside `test` folder. Let's say you're testing the default Flutter counter app, the content might be:
```gherkin
Feature: Counter
    Scenario: Initial counter value is 0
        Given the app is running
        Then I see {'0'} text
```

Now ask `built_value` to generate Dart files for you. You may do this with the command:
```
dart run build_runner watch --delete-conflicting-outputs
```
After that, the corresponding `dart` file will be generated for each of your `feature` files. Do not change the code inside these `dart` files as **they will be recreated** each time you change something in feature files.

During feature-to-dart generation additional `step` folder will be created. It will contain all steps required to run the scenario. **These files will not be updated** hence feel free to adapt the content according to your needs.

### Run tests

You're good to go! `bdd_widget_test` generated plain old Dart tests, so feel free to run you tests within your IDE or using the following command
```
flutter test
```

## Feature file syntax

Feature file sample:
```gherkin
# comment here

Feature: Counter

  Background:
    Given the answer is {42}

  After:
    Then clean up after the test

  Scenario: Initial counter value is 0
    Given the app is running
    Then I see {'0'} text

  Scenario: Plus button increases the counter
    Given the app is running
    When I tap {Icons.add} icon
    Then I see {'1'} text
```

`Backround` and `After` sections are optional. A `Background` allows you to add some context to the scenarios that follow it. It can contain one or more Given steps, which are run before each scenario. An `After` scenarion run even if a test fails, to ensure that it has a chance to clean up after itself. Most probably you don't need to use this keyword.

Each feature file must have one or more `Feature:`s. Features become test groups in Flutter tests.

Each feature group must have one or more `Scenario:`s (or `Example:`s). Scenario become widget tests.

Each scenario must have one or more lines with steps. Each of them must start with `Given`, `When`, `Then`, `And`, or `But` keywords. Conventionally `Given` steps are used for test arrangements, `When` — for interaction, `Then` — for asserts. Keywords are not taken into account when looking for a step definition.
You can have as many steps as you like, but it's recommended you keep the number at 3-5 per scenario. Having too many steps will cause it to lose it’s expressive power as specification and documentation. 

The `Scenario Outline` keyword can be used to run the same `Scenario` multiple times, with different combinations of values.

A Scenario Outline must contain an `Examples` (or `Scenarios`) section. Its steps are interpreted as a template which is never directly run. Instead, the Scenario Outline is run once for each row in the Examples section beneath it (not counting the first header row).

The steps can use `<>` delimited parameters that reference headers in the examples table. The plugin will replace these parameters with values from the table before it tries to match the step against a step definition.

Scenario Outline example:
```gherkin
Feature: Sample

  Scenario Outline: Plus button increases the counter
    Given the app is running
    When I tap {Icons.add} icon <times> times
    Then I see <result> text

    Examples:
    | times | result |
    |    0  |   '0'  |
    |    1  |   '1'  |
    |   42  |  '42'  |
```

If you need to have the same step but with different parameters, you may use a `DataTable`-like syntax:
```gherkin
Feature: Sample

  Scenario: An answer
    Given the app is running
    When I enter <input> text into <field> text field
    | input      | field |
    | '42'       |   0   |
    | 'question' |   1   |
    Then I see {'Do not forget your towel!'} text
```
The above is equivalent to:
```gherkin
Feature: Sample

  Scenario: An answer
    Given the app is running
    When I enter {'42'} text into {0} text field
    And I enter {'question'} text into {1} text field
    Then I see {'Do not forget your towel!'} text
```

While the `DataTable`-like syntax is a good practice for scenarios that require repeated steps, for example, entering text in different fields, sometimes we want to prepare test data in a readable way and mock our scneario's prerequisites and assert the expected result in an explicit domain driven way.
To handle this, we create a data table:
```gherkin
Feature: Search songs

  Scenario: Searched text matches a song's details
    Given available songs
    | 'artist'      | 'name'                      |
    | 'The Doors'   | 'Riders on the storm'       |
    | 'Bob Dylan'   | "Knockin' On Heaven's Door" |
    | 'The Beatles' | 'Here Comes the Sun'        |
    When I search for text {'door'}
    Then I see songs
    | 'artist'      | 'name'                      |
    | 'The Doors'   | 'Riders on the storm'       |
    | 'Bob Dylan'   | "Knockin' On Heaven's Door" |
```
For each of the above step lines that are followed by a table, in the related generate step file, the created function will have an object parameter of type `DataTable`:
```dart
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

/// Usage: Given available songs
Future<void> availableSongs(WidgetTester tester, bdd.DataTable dataTable) async {
  throw UnimplementedError();
}
```
Use the `DataTable` parameter to get access to the data:
```dart
final dataAsList = dataTable.asLists(); // [['artist', 'name'], ['The Doors', 'Riders on the storm'], ...]
final dataAsMaps = dataTable.asMaps(); // [{'artist: 'The Doors', 'name: 'Riders on the storm'}, ...]
```
## Tags

Tags are used to filter scenarios in the test runner. Here are some examples:
```gherkin
@slow
@integration
Feature: Sample

  @important
  Scenario: An answer
    Given the app is running
```

Here we mark the test as `slow`, `integration`, and `important`. 

To run tests that are marked with `@important` tag, you can use the following command:
```sh
flutter test --tags important
```
To exclude tests that are marked with `@slow` tag, you can use the following command:
```sh
flutter test --exclude-tags slow
```

## Predefined steps

This library comes with a list of predefined steps. They will be auto-generated for you, but you may want to adjust their implementation according to your needs.

List of predefined steps:
* I dismiss the page
* I don't see {..} icon
* I don't see {..} rich text
* I don't see {..} text
* I don't see {..} widget
* I enter {..} into {..} input field
* I see disabled elevated button
* I see enabled elevated button
* I see exactly {..} {..} widgets
* I see {..} icon
* I see multiple {..} texts
* I see multiple {..} widgets
* I see {..} rich text
* I see {..} text
* I tap {..} icon
* I tap {..} text
* The app is running

## Hooks
If you want to add hooks, you need to add the addHooks flag to the `build.yaml`. This will generate a file that allows you to handle a beforeAll, afterAll, beforeEach and afterEach call.
These hooks will be generated per directory, just like the steps. Also like with the steps, you can define a directory in the build.yaml to define one set location for the hooks. These hooks will then be used everywhere.

```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          addHooks: true
          hookFolderName: bdd_hooks
```

The beforeAll and afterAll do not take any properties, but the beforeEach and afterEach both provide the name and the tags of the feature. On top of this, the afterEach provides whether or not the test was successful. 

## FAQ

### How to pass a parameter?

You may use curly brackets to pass the parameter into a `step`. The syntax is following:
```gherkin
  When I see {42} number
  And I see {Icons.add} icon
```
Notice, that the value inside brackets is copied to the Dart test file without changes hence it must be a valid Dart code. In the example above first step will have an `int` value. In order to pass a valid Dart string use `'42'` or `"42"`.

You may call methods in step parameters, but most probably it's not what you want.

### How to add additional imports to test files?

Most of the time you shouldn't do that, as the BDD tests simulate user's behavior and it's just not possible for users to know the implementation details. Nevertheless, sometimes it might be in hand, i.e. when you have custom domain models or components. For example, if you need to check Cupertino icons in the test, you may have:
```gherkin
import 'package:flutter/cupertino.dart';

Feature: ...
  Then I see {CupertinoIcons.back} cupertino icon
```

### How to adjust linter for auto-generated tests?

Use the same trick as above, just write linter rules you wish to ignore at the beginning of the feature file:
```gherkin
// ignore_for_file: avoid_as, prefer_is_not_empty

Feature: ...
```

### Any video tutorials on this?

Sure, you may find a [BDD in Flutter playlist](https://www.youtube.com/playlist?list=PLjaSBcAZ8TqFx51f30aRi_A2szelttOpq) on youtube with the basic showcase.

### How to test the UI? (golden tests)

BDD is UI agnostic, the main focus is on the requirements. If you need to test colors and layouts the simplest option would be to combine BDD widget tests with [golden_toolkit](https://pub.dev/packages/golden_toolkit) plugin.

Everything will stay pretty much the same, but you'll need to tell the plugin to name test methods `testGoldens` instead of `testWidgets`.
There are three ways on how you can do that:
1. If you have only few golden test scenarios per feature, you may mark them with the `testMethodName` tag like that:
```gherkin
@testMethodName: testGoldens
Scenario: My golden scenario
```
2. For features full of golden tests you may move the `testMethodName` tag above the `Feature` declaration like that:
```gherkin
@testMethodName: testGoldens
Feature: My golden feature
```
3. If you plan to have golden tests only, you may want to override `testMethodName` for the whole plugin. For that modify your `build.yaml` file like that:
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          testMethodName: testGoldens
```

You may refer to a video from [BDD in Flutter playlist](https://www.youtube.com/playlist?list=PLjaSBcAZ8TqFx51f30aRi_A2szelttOpq) for a live demo.

### How to reuse steps between projects?

You may reference any step using `build.yaml` file (see the `example` folder):
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          externalSteps:
            - package:<your_package>/<your_step>.dart
```

If you have many packages you might want to reuse the whole list of external steps. For that you'll have to create a `bdd_options.yaml` file in the root folder of your project with the following content: 
```yaml
include: package:<package_a>/bdd_options.yaml # will include all steps defined in bdd_options.yaml of package_a
externalSteps:
  - package:<package_b>/<your_step>.dart
  - package:<package_c>/<your_step>.dart
```

Alternatively, if you need just to include an external config, use the `include` option in the `build.yaml` config:
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          include: package:<your_package>/bdd_options.yaml
```

### How to add custom headers to generated files?

You can add custom header lines (imports, comments, etc.) to all generated step files **and feature files** using the `customHeaders` option in the `build.yaml` file:
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          customHeaders:
            - "import 'package:flutter_test/flutter_test.dart';"
            - "import 'package:patrol/patrol.dart';"
            - "// Custom test utilities"
            - "import 'package:my_custom_package/my_helper.dart';"
```

This is useful when you need to:
- Use custom test frameworks (like Patrol) instead of the default flutter_test
- Import custom helper classes or utilities in all your generated files
- Add specific packages that your tests will commonly use
- Include custom test utilities, mocks, or constants
- Add custom comments or documentation to generated files

The custom headers will be added to:
- **Feature files**: After any data table imports, replacing the default flutter/material and flutter_test imports
- **Step files**: After any data table imports, replacing the default flutter_test import

### How to group steps in a single project?

You may create sub-folders (like `common`, `login`, `home`, etc.) in the `step` folder and move generated steps there. The plugin is smart enough to find them (see the `example` folder).

### I don't like the `step` folder name, how can I change it?

By setting the `stepFolderName` parameter with any name you like in the `build.yaml` file (see the `example` folder):
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          stepFolderName: bdd_steps
```

That will tell the plugin to create a `bdd_steps` folder under `test` (instead of `step` near each feature) and put all the steps there.

You may set a relative path here (like `../../bdd_steps`), just be sure that the target folder is still somewhere under the `test` folder.

### How to write integration tests?

1. Add `integration_test` dependency to the `pubspec.yaml` file:
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```
2. Modify `build.yaml` file to support code generation in the `integration_test` folder like that (here is the full [sample](example/build.yaml)):
```yaml
targets:
  $default:
    sources:
      - integration_test/**   # By default, build runner will not generate code in the integration folder
      - test/**               # so we override paths for code generation here
      - lib/**
      - $package$
```
3. (Optional) If you plan to re-use steps between integration and widget tests set a common step folder in the `build.yaml` file like that (here is the full [sample](example/build.yaml)):
```yaml
stepFolderName: step
```
4. Done. Now you may create feature files in `integration_test` folder. You may want to review the [official documentation](https://flutter.dev/docs/testing/integration-tests) for instructions on how to run integration tests.

### Patrol tests

[Patrol](https://pub.dev/packages/patrol) is a popular testing framework for Flutter. It provides a possibility to control native UI from the Dart code, and also provides a new custom finder that simplifies the development process of the widget tests. You may use Patrol together with bdd_widget_test to get the best from both worlds.

Here is an example of a BDD scenario with Patrol framework:
```gherkin
import 'package:patrol/patrol.dart';

@testMethodName: patrolTest
@testerName: $
@testerType: PatrolIntegrationTester
Feature: Counter
    
    Background:
        Given the app is running
    
    Scenario: Initial counter value is 0
        Then I see {'0'} text

    @scenarioParams: nativeAutomation: true
    Scenario: Add button increments the counter
        When I tap {Icons.add} icon
        Then I see {'1'} text
```

Notice how the second scenario is annotated with `nativeAutomation` enabling you to control native UI elements. Setting the tester type to `PatrolIntegrationTester` allows you to use the power of the custom finder introduced by Patrol.

To streamline your testing setup, you can conveniently configure key parameters in the `build.yaml` file if you plan to use Patrol in all your tests:
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          testMethodName: patrolTest
          testerName: $
          testerType: PatrolIntegrationTester
          includeIntegrationTestBinding: false
          customHeaders:
            - "import 'package:flutter_test/flutter_test.dart';"
            - "import 'package:patrol/patrol.dart';"
```

Since Patrol version 3.0.0, `IntegrationTestWidgetsFlutterBinding.ensureInitialized` must not be called. Set `includeIntegrationTestBinding` to `false`.

### I don't like that the plugin creates steps under `test` folder. How to change that?

You may set a relative path in the `build.yaml` file (see the `example` folder):
```yaml
relativeToTestFolder: false
stepFolderName: integration_test/steps # if you want to have steps in the integration_test folder
hookFolderName: integration_test/bdd_hooks # if you want to have hooks in the integration_test folder
```

## Contributing

If you find a bug or would like to request a new feature, just [open an issue](https://github.com/olexale/bdd_widget_test/issues/new). Your contributions are always welcome!

## License
`bdd_widget_test` is released under a [MIT License](https://opensource.org/licenses/MIT). See `LICENSE` for details.
