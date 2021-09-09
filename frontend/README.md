# Flutter AWS

## Flutter with AWS Integration

    This code can be useful as a skeleton or "How To Do" to start a Flutter project using AWS, Cognito, AWS API & DynamoDB reactive programming with RxDart and connect to external resurces.

## Running 

    Build and tested on Flutter (Channel beta, 2.5.0-5.3.pre, on Mac OS X 10.15.7 19H1323 darwin-x64, locale en-BR) - Dart SDK version: 2.14.0-377.8.beta

## Technologies

- [X] Flutter
- [X] AWS
- [X] Cognito
- [X] RxDart
- [X] AWS API 
- [X] DynamoDB

## Structure

- 1st Layer: UI
- 2nd Layer: BLOC
- 3rd Layer: MODEL
- 4th Layer: RESOURCE
- 5th Layer: AWS BACKEND

## DEBUG

1. Connection failed

    Add to file `DebugProfile.entitlements` under directory `macos/Runner/`

    ```
    <key>com.apple.security.network.client</key>
    <true/>
    ```

    Source: (https://github.com/flutter/flutter/issues/47606)