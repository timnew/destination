import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bad_destination.dart';
import 'navigation_stack.dart';
import 'page_factory.dart';
import 'route_path_visitor.dart';

/// An implementation of [RouteInformationParser] that works with [NavigationStack].
abstract class NavigationStackParser
    extends RouteInformationParser<NavigationStack> {
  const NavigationStackParser();

  @override
  Future<NavigationStack> parseRouteInformation(
          RouteInformation routeInformation) =>
      SynchronousFuture(
        syncParseRouteInformation(routeInformation.location),
      );

  @protected
  NavigationStack syncParseRouteInformation(String? location) {
    if (location == null) {
      return onLocationIsNull();
    }

    if (location.isEmpty) {
      return onLocationIsEmpty();
    }

    final visitor = RoutePathVisitor(location);

    var result = buildRootStack();

    while (visitor.hasNext) {
      result = result.pushPathVisitor(visitor);
    }

    return result;
  }

  /// Overrides in derived classes to handle the case when [location] is `null`.
  ///
  /// By default it invokes [onLocationIsEmpty].
  NavigationStack onLocationIsNull() => onLocationIsEmpty();

  /// Overrides in derived classes to handle the case when [location] is empty.
  ///
  /// By default it returns a stack with [BadDestination.emptyLocation].
  NavigationStack onLocationIsEmpty() =>
      BadDestination.emptyLocation().createStack();

  /// Build the initial stack for given applicaiton.
  /// It should return a stack that what "Home Screen" is like.
  ///
  /// Must override in derived classes.
  NavigationStack buildRootStack();

  /// Build [PageFacttory] for the current app.
  PageFactory buildPageFactory();

  @override
  RouteInformation? restoreRouteInformation(NavigationStack configuration) {
    final location = configuration.buildLocation();

    return RouteInformation(location: location);
  }
}
