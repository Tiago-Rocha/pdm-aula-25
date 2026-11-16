# pdm-aula-25 · Bug hunt: tests, CI and logs

Repository for lesson 25 of PDM (Mobile Device Programming), CTeSP DAW, ESTA, University of the Azores, 2026/27.

Tempo Açores, as you know it, now with a five-day forecast for each island. It runs on your phone at **https://tiago-rocha.github.io/pdm-aula-25/** and it has bugs. People reported six of them: they are in the [Issues](../../issues), each with what the person saw and a hint.

Today you fix them the way a team does: a test that fails, the fix, a pull request, the CI green, the merge. A few minutes after the merge, the fix is on everyone's phone.

## Getting started

```bash
git clone https://github.com/<you>/pdm-aula-25.git   # your fork
cd pdm-aula-25
flutter pub get
flutter test
flutter run -d chrome --dart-define=CLIENT_ID=pdm-ab12cd --dart-define=CLIENT_SECRET=your-secret
```

`flutter test` is green on `main`: the tests that exist pass, and none of them looks at the bugs yet. Your `clientId` and `clientSecret` are in issue #1 of your group's repository. Keep the `flutter run` command on one line.

## Fixing a bug

1. Say in the issue that you are taking it, so two people do not fix the same thing.
2. Make it happen in Chrome. Look at the logs on the projector: your lines have your name.
3. Write a test that fails because of the bug. The file next to the bug already has a test you can copy.
4. Fix the code. `flutter test` is green again.
5. Push a branch to your fork and open a pull request to this repository, with `Fixes #N` in the description.
6. The CI runs `flutter analyze` and `flutter test`. Red: read the log, fix, push again. Green: the teacher merges.
7. The CI publishes the web app. Reload the page on your phone: the bug is gone, and the version in the logs is your commit.

## Where the magic happens

| What | Where | What you see |
|---|---|---|
| One log for the whole app: lines with context, sent in batches, kept while offline | `AppLog` in `lib/telemetry/app_log.dart` | `log.info('favorite saved', {'island': 'corvo'})` |
| Errors nobody caught go to the log, with the stack | `FlutterError.onError` and `platformDispatcher.onError` in `lib/main.dart` | A red line in the logs, with the screen and the island |
| The app never talks to the log server: the course API does | `log.sink` in `lib/main.dart`, `POST /v1/logs` in the API | Your name and your app on every line, added by the API |
| A screen drawn in a test, with fake data and Ana logged in | `pumpScreen()` in `test/fakes.dart` | `await pumpScreen(tester, const IslandsScreen());` |
| Repositories that answer straight away, or fail on purpose | `FakeForecastRepository` in `test/fakes.dart` | `FakeForecastRepository()..failing = true` |
| Every pull request is tested; every merge is published | `.github/workflows/ci.yml` | The green tick in the pull request, then the new version on the phone |

## The tests

| Kind | Example | What it checks |
|---|---|---|
| Unit: a function or a model, no Flutter | `test/models/forecast_test.dart`, `test/location/nearest_test.dart` | JSON in, values out. Distances. |
| State: a notifier with a fake repository | `test/state/forecast_notifier_test.dart`, `test/state/favorites_notifier_test.dart`, `test/state/settings_test.dart` | What the notifier keeps after `load()` or `toggle()` |
| Widget: a screen, with taps | `test/screens/islands_screen_test.dart`, `test/screens/forecast_screen_test.dart` | What is on screen, what a tap does |

Each test has three parts, separated by a blank line: prepare, do, check.

## What goes in a log line, and what never does

In: what happened, the screen, the island, the version, the error and the stack. The API adds the app and the user.

Never: passwords, tokens, the exact position, anything the person typed. The log of `nearestIsland` says the island and the kilometres, not where the person is.

API documentation: https://api-pdm.sublimecipher.com/docs

Teacher's content licensed CC BY-NC-SA 4.0.
