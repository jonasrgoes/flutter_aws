import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_aws/src/blocs/bloc.dart';
import 'package:flutter_aws/src/models/user.dart';
import 'package:flutter_aws/src/resources/repository.dart';

import 'package:flutter_aws/src/utils/validator.dart';
import 'package:flutter_aws/src/utils/prefs_manager.dart';
import 'package:flutter_aws/src/utils/values/string_constants.dart';

class AuthenticationBloc implements Bloc {
  AuthenticationBloc() {
    _repository.init().then((user) {
      if (user != null) {
        changeUser(user);
      }
    });
  }

  final _repository = Repository();
  final _email = BehaviorSubject<String>();
  final _displayName = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _code = BehaviorSubject<String>();
  final _isSignedIn = BehaviorSubject<bool>();
  final _confirm = BehaviorSubject<bool>();
  final _user = BehaviorSubject<User>();

  Stream<String> get email => _email.stream.transform(_validateEmail);
  Stream<String> get displayName => _displayName.stream.transform(_validateDisplayName);
  Stream<String> get password => _password.stream.transform(_validatePassword);
  Stream<String> get code => _code.stream.transform(_validateCode);
  Stream<bool> get signInStatus => _isSignedIn.stream;
  Stream<bool> get confirm => _confirm.stream;
  Stream<User> get user => _user.stream;

  // Change data
  void Function(String) get changeEmail => _email.sink.add;
  void Function(String) get changeDisplayName => _displayName.sink.add;
  void Function(String) get changePassword => _password.sink.add;
  void Function(String) get changeCode => _code.sink.add;
  void Function(bool) get showProgressBar => _isSignedIn.sink.add;
  void Function(bool) get showConfirm => _confirm.sink.add;
  void Function(User) get changeUser => _user.sink.add;

  bool get isConfirmed => _confirm.value;

  final _validateEmail = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (Validator.validateEmail(email)) {
      sink.add(email);
    } else {
      sink.addError(StringConstants.emailValidateMessage);
    }
  });

  final _validatePassword = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (Validator.validatePassword(password)) {
      sink.add(password);
    } else {
      sink.addError(StringConstants.passwordValidateMessage);
    }
  });

  final _validateCode = StreamTransformer<String, String>.fromHandlers(handleData: (code, sink) {
    if (Validator.validateCode(code)) {
      sink.add(code);
    } else {
      sink.addError(StringConstants.passwordValidateMessage);
    }
  });

  final _validateDisplayName = StreamTransformer<String, String>.fromHandlers(handleData: (displayName, sink) {
    if (displayName.length > 5) {
      sink.add(displayName);
    } else {
      sink.addError(StringConstants.displayNameValidateMessage);
    }
  });

  bool validateEmailAndPassword() {
    if (_email.valueOrNull != null &&
        _email.value.isNotEmpty &&
        _email.value.contains("@") &&
        _password.valueOrNull != null &&
        _password.value.isNotEmpty &&
        _password.value.length > 5) {
      print('validateEmailAndPassword(): TRUE');
      return true;
    }
    print('validateEmailAndPassword(): FALSE');
    return false;
  }

  bool validateConfirmationCode() {
    if (_code.valueOrNull != null && _code.value.isNotEmpty && _code.value.length >= 4) {
      return true;
    }
    return false;
  }

  void saveCurrentUserDisplayName(SharedPreferences prefs) {
    print("SAVED DISPLAYNAME: " + _displayName.value);
    PrefsManager prefsManager = PrefsManager();
    prefsManager.setCurrentUserDisplayName(prefs, _displayName.value);
  }

  bool validateDisplayName() {
    return _displayName.value.isNotEmpty && _displayName.value.length > 5;
  }

  Future<int?> loginUser() async {
    showProgressBar(true);

    var response = await _repository.loginWithEmailAndPassword(_email.value, _password.value);

    if (response == 1) {
      var user = await _repository.getCurrentUser();

      if (user != null) {
        changeUser(user);
      }
    }

    print(response);

    showProgressBar(false);

    return response;
  }

  Future<bool> confirmAccount() async {
    showProgressBar(true);
    var response = await _repository.confirmAccount(_email.value, _code.value);
    showProgressBar(false);
    return response;
  }

  Future<void> resendConfirmationCode() async {
    await _repository.resendConfirmationCode(_email.value);
  }

  Future<User?> registerUser() async {
    showProgressBar(true);
    User? response = await _repository.signUpWithEmailAndPassword(_email.value, _password.value, _displayName.value);
    showProgressBar(false);
    return response;
  }

  @override
  void dispose() async {
    await _email.drain();
    _email.close();
    await _displayName.drain();
    _displayName.close();
    await _password.drain();
    _password.close();
    await _code.drain();
    _code.close();
    await _isSignedIn.drain();
    _isSignedIn.close();
    await _confirm.drain();
    _confirm.close();
    await _user.drain();
    _user.close();
  }
}
