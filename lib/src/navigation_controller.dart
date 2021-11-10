import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'destination.dart';
import 'navigation_stack.dart';
import 'page_factory.dart';

/// The class controls the navigation, it serves as [RouterDelegate] for the [Router].
/// Also it holds the current [NavigationStack] and provides interface to update it.
class NavigationController extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavigationStack> {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// [PageFactory] helps to build [Page] out of [NavigationStack] and [Destination]s.
  final PageFactory pageFactory;

  NavigationStack _current;

  /// Creates a [NavigationController].
  ///
  /// A [pageFactory] is required to instruct [NavigationController] how to build [Page]s out of [NavigationStack] and [Destination]s.
  NavigationController({
    required this.pageFactory,
    required NavigationStack initial,
  }) : _current = initial;

  /// Set current [NavigationStack] and notify listeners.
  void setCurrent(NavigationStack value) {
    _current = value;
    notifyListeners();
  }

  @override
  NavigationStack get currentConfiguration => _current;

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: buildPages(context),
        onPopPage: onPopPage,
      );

  /// Builds [Page]s out of [NavigationStack] and [Destination]s.
  /// Derived classes can override this method to alter the bulding behaviour.
  @protected
  List<Page> buildPages(BuildContext context) => _current.allStacks
      .map((s) => pageFactory.buildPage(context, s))
      .toList(growable: false);

  /// Behaviour when page pop is requested.
  ///
  /// Derived classes can override this method to alter the behaviour.
  @protected
  bool onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    setCurrent(_current.pop());

    return true;
  }

  @override
  Future<void> setNewRoutePath(NavigationStack configuration) {
    setCurrent(configuration);

    return SynchronousFuture<void>(null);
  }

  /// Navigate to the [destination] automatically by routing rules.
  ///
  /// For direct manipuation on [NavigationStack], use [currentConfiguration] and [setCurrent] instead.
  /// Or use [Navigator] directly.
  void navigateTo(Destination destination) {
    setCurrent(_current.navigateTo(destination));
  }
}
