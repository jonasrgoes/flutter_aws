import 'dart:async';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_aws/src/models/user.dart';
import 'package:flutter_aws/src/resources/local_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CognitoResources {
  String? cognitoUserPoolId;
  String? cognitoClientId;
  String? cognitoIdentityPoolId;
  String? awsRegion;

  late CognitoUserPool _userPool;

  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  CognitoCredentials? credentials;
  String? _sessionToken;
  String? _jwtToken;

  String? get sessionToken => _sessionToken;
  String? get jwtToken => _jwtToken;

  CognitoResources() {
    cognitoUserPoolId = dotenv.get('COGNITO_USER_POOL_ID', fallback: 'FALSE');
    cognitoClientId = dotenv.get('COGNITO_CLIENT_ID', fallback: 'FALSE');
    cognitoIdentityPoolId = dotenv.get('COGNITO_IDENTY_POOL_ID', fallback: 'FALSE');
    awsRegion = dotenv.get('AWS_REGION', fallback: 'FALSE');

    // print('cognitoUserPoolId: $cognitoUserPoolId');
    // print('cognitoClientId: $cognitoClientId');
    // print('cognitoIdentityPoolId: $cognitoIdentityPoolId');
    // print('awsRegion: $awsRegion');

    assert(cognitoUserPoolId != null && !cognitoUserPoolId!.contains('FALSE'));
    assert(cognitoClientId != null && !cognitoClientId!.contains('FALSE'));
    assert(cognitoIdentityPoolId != null && !cognitoIdentityPoolId!.contains('FALSE'));
    assert(awsRegion != null && !awsRegion!.contains('FALSE'));

    _userPool = CognitoUserPool(cognitoUserPoolId!, cognitoClientId!);
  }

  /// Initiate user session from local storage if present
  Future<User?> init() async {
    print('COGNITO INIT CALLED');

    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    // final storage = CognitoMemoryStorage();
    _userPool.storage = storage;
    print('_userPool.storage: ${_userPool.storage.toString()}');

    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      print('_cognitoUser IS NULL');
      return null;
    }
    _session = await _cognitoUser!.getSession();

    if (_session == null) {
      print('SESSION IS NULL');
      return null;
    }

    // Session After Login
    print('_session: $_session');
    print('_session!.isValid(): ${_session!.isValid()}');

    return _session!.isValid() ? await getCurrentUser() : null;
  }

  /// Get existing user from session with his/her attributes
  Future<User?> getCurrentUser() async {
    if (_cognitoUser == null || _session == null) {
      print('getCurrentUser(): _cognitoUser == null || _session == null');
      return null;
    }

    if (!_session!.isValid()) {
      print('getCurrentUser(): !_session!.isValid()');
      return null;
    }

    final attributes = await _cognitoUser?.getUserAttributes();

    if (attributes == null) {
      print('getCurrentUser(): attributes == null');
      return null;
    }

    final user = User.fromUserAttributes(attributes);

    user.hasAccess = true;

    return user;
  }

  Future<String?> getUserUID() async {
    print('getUserUID()');

    final user = await getCurrentUser();

    if (user != null) {
      print('getUserUID(): ${user.email}');
      return user.email;
    } else {
      print('getUserUID(): NULL');
      return null;
    }
  }

  /// Retrieve user credentials -- for use with other AWS services
  Future<CognitoCredentials?> getCredentials() async {
    if (_cognitoUser == null || _session == null) {
      return null;
    }

    credentials = CognitoCredentials(cognitoIdentityPoolId!, _userPool);
    await credentials!.getAwsCredentials(_session?.getIdToken().getJwtToken());
    _sessionToken = credentials!.sessionToken;
    _jwtToken = _session!.idToken.jwtToken;
    return credentials!;
  }

  /// Login user
  Future<int?> loginWithEmailAndPassword(String email, String password) async {
    _cognitoUser = CognitoUser(email, _userPool, storage: _userPool.storage);

    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    try {
      _session = await _cognitoUser?.authenticateUser(authDetails);
    } on CognitoUserNewPasswordRequiredException catch (e) {
      // handle New Password challenge
      print(e);
      throw Exception('CognitoUserNewPasswordRequiredException');
    } on CognitoUserMfaRequiredException catch (e) {
      // handle SMS_MFA challenge
      print(e);
      throw Exception('CognitoUserMfaRequiredException');
    } on CognitoUserSelectMfaTypeException catch (e) {
      // handle SELECT_MFA_TYPE challenge
      print(e);
      throw Exception('CognitoUserSelectMfaTypeException');
    } on CognitoUserMfaSetupException catch (e) {
      // handle MFA_SETUP challenge
      print(e);
      throw Exception('CognitoUserMfaSetupException');
    } on CognitoUserTotpRequiredException catch (e) {
      // handle SOFTWARE_TOKEN_MFA challenge
      print(e);
      throw Exception('CognitoUserTotpRequiredException');
    } on CognitoUserCustomChallengeException catch (e) {
      // handle CUSTOM_CHALLENGE challenge
      print(e);
      throw Exception('CognitoUserCustomChallengeException');
    } on CognitoUserConfirmationNecessaryException catch (e) {
      // handle User Confirmation Necessary
      print(e);
      throw Exception('CognitoUserConfirmationNecessaryException');
    } on CognitoClientException catch (e) {
      print(e);
      if (e.code == 'UserNotConfirmedException') {
        print('UserNotConfirmedException');
        return -2;
      } else if (e.code == 'NotAuthorizedException') {
        print('NotAuthorizedException');
        return -1;
      } else {
        print('RETHROW');
        rethrow;
      }
    } catch (e) {
      print(e);
      rethrow;
    }

    if (_session == null || !_session!.isValid()) {
      //  User is not authenticated
      return null;
    }

    // If User is authenticated
    final List<CognitoUserAttribute>? attributes = await _cognitoUser?.getUserAttributes();
    if (attributes != null) {
      print('SESSION JWT TOKEN: ${_session!.getAccessToken().getJwtToken()}');
      for (var attribute in attributes) {
        print('attribute ${attribute.getName()} has value ${attribute.getValue()}');
      }
      getCredentials();
      return 1;
    } else {
      throw Exception('attributesEmpty');
    }
  }

  /// Confirm user's account with confirmation code sent to email
  Future<bool> confirmAccount(String email, String confirmationCode) async {
    _cognitoUser = CognitoUser(email, _userPool, storage: _userPool.storage);

    try {
      return await _cognitoUser?.confirmRegistration(confirmationCode) ?? false;
    } on CognitoClientException catch (e) {
      if (e.code == 'ExpiredCodeException') {
        print('ExpiredCodeException');
        await resendConfirmationCode(email);
        return false;
      } else {
        print('RETHROW');
        rethrow;
      }
    }
  }

  Future<bool> changePassword(oldPassword, newPassword) async {
    bool passwordChanged = false;
    try {
      passwordChanged = await _cognitoUser!.changePassword(
        oldPassword,
        newPassword,
      );
    } catch (e) {
      print(e);
      return false;
    }
    print('passwordChanged: $passwordChanged');
    return true;
  }

  Future<bool> forgotPasswordStep1() async {
    var data;
    try {
      data = await _cognitoUser!.forgotPassword();
    } catch (e) {
      print(e);
      return false;
    }
    print('Code sent to $data');
    return true;
  }

  Future<bool> forgotPasswordStep2(code, newPassword) async {
    bool passwordConfirmed = false;
    try {
      passwordConfirmed = await _cognitoUser!.confirmPassword(code, newPassword);
    } catch (e) {
      print(e);
      return false;
    }
    print(passwordConfirmed);
    return true;
  }

  /// Resend confirmation code to user's email
  Future<void> resendConfirmationCode(String email) async {
    _cognitoUser = CognitoUser(email, _userPool, storage: _userPool.storage);
    await _cognitoUser?.resendConfirmationCode();
  }

  /// Sign up user
  Future<User> signUpWithEmailAndPassword(String email, String password, String name) async {
    CognitoUserPoolData data;
    final userAttributes = [
      AttributeArg(name: 'name', value: name),
      AttributeArg(name: 'email', value: email),
    ];
    data = await _userPool.signUp(email, password, userAttributes: userAttributes);

    final user = User();
    user.email = email;
    user.name = name;
    user.confirmed = data.userConfirmed ?? false;

    return user;
  }

  Future<void> signOut() async {
    if (credentials != null) {
      await credentials!.resetAwsCredentials();
    }
    if (_cognitoUser != null) {
      // Use case 14. Signing out from the application.
      return await _cognitoUser!.signOut();
      // Use case 15. Global signout for authenticated users (invalidates all issued tokens).
      // return await _cognitoUser!.globalSignOut();
    }
  }
}
