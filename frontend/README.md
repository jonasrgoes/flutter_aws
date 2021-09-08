# Flutter AWS

## Flutter with AWS Integration

    This code can be useful as a skeleton or "How To Do" to start a Flutter project using AWS, Cognito, reactive programming with RxDart and connect to external resurces.

## Technologies

- [X] Flutter
- [X] AWS
- [X] Cognito
- [X] RxDart
- [X] API using DynamoDB

## Structure

- 1st Layer: UI
- 2nd Layer: BLOC
- 3rd Layer: MODEL
- 4th Layer: RESOURCE

## DEBUG

1. Connection failed

    Add to file `DebugProfile.entitlements` under directory `macos/Runner/`

    ```
    <key>com.apple.security.network.client</key>
    <true/>
    ```

    Source: (https://github.com/flutter/flutter/issues/47606)