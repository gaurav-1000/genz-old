import 'package:get/get.dart';

import '../models/user_model.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/otpcode/bindings/otpcode_binding.dart';
import '../modules/auth/otpcode/views/otpcode_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/loading/bindings/loading_binding.dart';
import '../modules/loading/views/loading_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/setup_account/bindings/setup_account_binding.dart';
import '../modules/setup_account/bindings/zodiac_binding.dart';
import '../modules/setup_account/views/setup_account_view.dart';
import '../modules/setup_account/views/zodiac_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/winkUI/bindings/wink_u_i_binding.dart';
import '../modules/winkUI/views/wink_u_i_view.dart';
import '../settings/bindings/edit_name_binding.dart';
import '../settings/views/edit_name_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // static final INITIAL = auth.currentUser == null ? Routes.WELCOME : Routes.LOADING;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.SETUP_ACCOUNT,
      page: () => const SetupAccountView(),
      binding: SetupAccountBinding(),
      children: [
        GetPage(
          name: _Paths.ZODIAC,
          page: () => const ZodiacView(),
          binding: ZodiacBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_NAME,
      page: () => const EditNameView(),
      binding: EditNameBinding(),
    ),
    GetPage(
      name: _Paths.OTPCODE,
      page: () => const OtpcodeView(),
      binding: OtpcodeBinding(),
    ),
    GetPage(
      name: _Paths.WINK_U_I,
      page: () => WinkUIView(user: UserModel(id: "")),
      binding: WinkUIBinding(),
    ),
    GetPage(
      name: _Paths.LOADING,
      page: () => const LoadingView(),
      binding: LoadingBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
  ];
}
