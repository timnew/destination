import 'package:flutter/material.dart';

import 'destination.dart';
import 'navigation_stack.dart';

/// A function that produces a [Page] out of [stack]
typedef PageBuilder = Page Function(
  BuildContext context,
  NavigationStack stack,
);

/// A function that produces the root widget of the [Page] associated with [stack]
typedef ScreenWidgetBuilder = Widget Function(
  BuildContext context,
  NavigationStack stack,
);

/// A class that builds [Page] from [NavigationStack].
/// It is the only way to assocaited [NavigationStack] with UI.
class PageFactory {
  final List<_BuilderItem> _builders = [];

  /// Create a [PageFactory].
  PageFactory();

  /// Register a [PageBuilder] that handles destination of type [D].
  void page<D extends Destination>(PageBuilder pageFactory) {
    _builders.add(_BuilderItem<D>.page(pageFactory));
  }

  /// Register a [ScreenWidgetBuilder] that handles destination of type [D].
  /// The [Widget] returned by it will be used as [MaterialPage.child]
  void screen<D extends Destination>(
    ScreenWidgetBuilder screenWidgetFactory,
  ) {
    _builders.add(_BuilderItem<D>.screen(screenWidgetFactory));
  }

  /// Build a [Page] from [NavigationStack].
  Page buildPage(BuildContext context, NavigationStack stack) {
    final factory = _builders.firstWhere(
      (f) => f.canBuild(stack.current),
      orElse: () => throw ArgumentError(
        "No factory registered for ${stack.current}",
      ),
    );

    return factory.build(context, stack);
  }
}

class _BuilderItem<D extends Destination> {
  final PageBuilder build;

  _BuilderItem.page(this.build);

  factory _BuilderItem.screen(ScreenWidgetBuilder screenWidgetBuilder) =>
      _BuilderItem.page(
        (c, s) => MaterialPage(
          key: s.current.pageKey,
          restorationId: s.current.restorationId,
          child: screenWidgetBuilder(c, s),
        ),
      );

  bool canBuild(Destination destination) => destination is D;
}
