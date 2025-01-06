import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CupertinoPageScaffold(
        child: PageViewExample(),
      ),
    );
  }
}

class PageViewExample extends StatefulWidget {
  const PageViewExample({super.key});

  @override
  State<PageViewExample> createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children: <Widget>[
            PageWidget(page: 0),
            PageWidget(page: 1),
            PageWidget(page: 2),
            PageWidget(page: 3),
            PageWidget(page: 4),
            PageWidget(page: 5),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 42.0),
            child: CupertinoButton(
              onPressed: () {
                Get.toNamed(Routes.LOGIN);
              },
              child: Text('skip_intro'.tr),
            ),
          ),
        ),
        PageIndicator(
          tabController: _tabController,
          currentPageIndex: _currentPageIndex,
          onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        ),
      ],
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class PageWidget extends StatelessWidget {
  final int page;

  const PageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26.0, right: 26.0, bottom: 32.0),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getPageEmoji(page),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              _getPageTitle(page),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 26.0),
            Text(
              _getPageSubtitle(page),
            ),
            SizedBox(height: 16.0),
            Text(
              _getBullet1(page),
            ),
            SizedBox(height: 16.0),
            Text(
              _getBullet2(page),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageEmoji(int page) {
    switch (page) {
      case 0:
        return 'onboarding_page_1_emoji'.tr;
      case 1:
        return 'onboarding_page_2_emoji'.tr;
      case 2:
        return 'onboarding_page_3_emoji'.tr;
      case 3:
        return 'onboarding_page_4_emoji'.tr;
      case 4:
        return 'onboarding_page_5_emoji'.tr;
      case 5:
        return 'onboarding_page_6_emoji'.tr;
      default:
        return '';
    }
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0:
        return 'onboarding_page_1'.tr;
      case 1:
        return 'onboarding_page_2'.tr;
      case 2:
        return 'onboarding_page_3'.tr;
      case 3:
        return 'onboarding_page_4'.tr;
      case 4:
        return 'onboarding_page_5'.tr;
      case 5:
        return 'onboarding_page_6'.tr;
      default:
        return '';
    }
  }

  String _getPageSubtitle(int page) {
    switch (page) {
      case 0:
        return 'onboarding_page_1_subtitle'.tr;
      case 1:
        return 'onboarding_page_2_subtitle'.tr;
      case 2:
        return 'onboarding_page_3_subtitle'.tr;
      case 3:
        return 'onboarding_page_4_subtitle'.tr;
      case 4:
        return 'onboarding_page_4_subtitle'.tr;
      case 5:
        return 'onboarding_page_6_subtitle'.tr;
      default:
        return '';
    }
  }

  String _getBullet1(int page) {
    switch (page) {
      case 0:
        return 'onboarding_page_1_point_1'.tr;
      case 1:
        return 'onboarding_page_2_point_1'.tr;
      case 2:
        return 'onboarding_page_3_point_1'.tr;
      case 3:
        return 'onboarding_page_4_point_1'.tr;
      case 4:
        return 'onboarding_page_5_point_1'.tr;
      case 5:
        return 'onboarding_page_6_point_1'.tr;
      default:
        return '';
    }
  }

  String _getBullet2(int page) {
    switch (page) {
      case 0:
        return 'onboarding_page_1_point_2'.tr;
      case 1:
        return 'onboarding_page_2_point_2'.tr;
      case 2:
        return 'onboarding_page_3_point_2'.tr;
      case 3:
        return 'onboarding_page_4_point_2'.tr;
      case 4:
        return 'onboarding_page_5_point_2'.tr;
      case 5:
        return 'onboarding_page_6_point_2'.tr;
      default:
        return '';
    }
  }
}

/// Page indicator for desktop and web platforms.
///
/// On Desktop and Web, drag gesture for horizontal scrolling in a PageView is disabled by default.
/// You can defined a custom scroll behavior to activate drag gestures,
/// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag.
///
/// In this sample, we use a TabPageSelector to navigate between pages,
/// in order to build natural behavior similar to other desktop applications.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32.0,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: CupertinoColors.black,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 5) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
