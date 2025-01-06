// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const WELCOME = _Paths.WELCOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const CHAT = _Paths.CHAT;
  static const SETUP_ACCOUNT = _Paths.SETUP_ACCOUNT;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_NAME = _Paths.SETTINGS + _Paths.EDIT_NAME;
  static const ZODIAC = _Paths.SETUP_ACCOUNT + _Paths.ZODIAC;
  static const OTPCODE = _Paths.OTPCODE;
  static const WINK_U_I = _Paths.WINK_U_I;
  static const LOADING = _Paths.LOADING;
  static const ONBOARDING = _Paths.ONBOARDING;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const WELCOME = '/welcome';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const SETUP_ACCOUNT = '$REGISTER/setup-account';
  static const CHAT = '/chat';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
  static const EDIT_NAME = '/edit-profile';
  static const ZODIAC = '/zodiac';
  static const OTPCODE = '/otpcode';
  static const WINK_U_I = '/wink-u-i';
  static const LOADING = '/loading';
  static const ONBOARDING = '/onboarding';
}
