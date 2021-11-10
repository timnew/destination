import 'package:flutter/widgets.dart';

import 'bad_destination.dart';
import 'destination.dart';
import 'route_path_visitor.dart';

/// Check wither destionation satifies the criteria.
typedef DestionPredicate = bool Function(Destination d);

/// Describes the [Destination] and all its ancestors
class NavigationStack {
  /// Ancestors in a stack
  final NavigationStack? _stack;

  /// The current destination.
  final Destination current;

  NavigationStack._(this._stack, this.current);

  /// Create a single destination stack.
  factory NavigationStack.root(Destination destination) =>
      NavigationStack._(null, destination);

  factory NavigationStack._fromNodes(Iterable<Destination> nodes) {
    assert(nodes.isNotEmpty);

    return nodes.fold<NavigationStack?>(
      null,
      (stack, node) => NavigationStack._(stack, node),
    )!;
  }

  /// All the [Destination]s in the stack.
  ///
  /// From root to current, current would be always the last element.
  Iterable<Destination> get allNodes sync* {
    if (_stack != null) {
      yield* _stack!.allNodes;
    }
    yield current;
  }

  /// All the [NavigationStack] in the stack.
  ///
  /// Similar to [allNodes], but returns [NavigationStack] instead of [Destination].
  ///
  /// From root to top, `this` would be always the last element.
  Iterable<NavigationStack> get allStacks sync* {
    if (_stack != null) {
      yield* _stack!.allStacks;
    }
    yield this;
  }

  /// Cast [current] into type [D]. Throws if the cast fails.
  /// Useful when confident about [current]'s type.
  D as<D extends Destination>() => current as D;

  /// Find the closest ancestor with type [D], [current] is checked.
  /// Useful to looking for data hold by parent destination.
  D? find<D extends Destination>() =>
      current is D ? current as D : _stack?.find<D>();

  /// The depth of the stack.
  int get depth => _stack?.depth ?? 0 + 1;

  /// Whether current is the root node.
  bool get isRoot => _stack == null;

  /// Build location string from the stack, which is used by the [RouteInformation.location]
  String buildLocation() =>
      allNodes.expand((d) => d.toLocationParts()).join('/');

  /// Pop the last destination from the stack.
  NavigationStack pop() => _stack != null ? _stack! : this;

  /// Push a destionation onto the stack.
  NavigationStack push(Destination destination) =>
      NavigationStack._(this, destination);

  /// Push all given nodes onto the stack.
  NavigationStack pushAll(Iterable<Destination> nodes) =>
      nodes.fold<NavigationStack>(
        this,
        (stack, node) => NavigationStack._(stack, node),
      );

  /// Pop nodes until the [criteria] is satisfied or [isRoot] is `true`.
  NavigationStack popUntil(DestionPredicate criteria) =>
      isRoot && criteria(current) ? this : _stack!.popUntil(criteria);

  /// Try to intelligently pop and push the stack to ensure [destination] at the top. Or an stack with [BadDestination] will be returned.
  ///
  /// It follows the following rules
  /// * If [current] is [destination], this is returned.
  /// * If [destination] can be pushed onto [current], new nodes returned by [destination.tryNavigateFrom] will be pushed.
  /// * Pop and try again until suceeded or reach the root
  /// * Try to push [destination] as root stack via [destination.tryBuildRootStack].
  /// * [BadDestination.unreachableLocation] will be returned if all above failed.
  NavigationStack navigateTo(Destination destination,
      {NavigationStack? origin}) {
    // Destination reached, nothing to do.
    if (current == destination) {
      return this;
    }

    /// Try to push the destination onto the current stack.
    final newNodes = destination.tryNavigateFrom(current);
    if (newNodes != null) {
      return pushAll(newNodes);
    }

    if (isRoot) {
      // Can't pop any more, try to build as root.
      final rootNodes = destination.tryBuildRootStack();
      if (rootNodes != null) {
        // Build root stack successfully.
        return NavigationStack._fromNodes(rootNodes);
      }

      // Route is not reachable.
      return BadDestination.unreachableLocation(
              from: origin ?? this, to: destination)
          .createStack();
    }

    // Pop then try again recursively.
    return _stack!.navigateTo(destination, origin: origin ?? this);
  }

  /// Push [path] on the current stack
  NavigationStack pushPath(String path) =>
      pushPathVisitor(RoutePathVisitor(path));

  /// Push [visitor] on the current stack
  NavigationStack pushPathVisitor(RoutePathVisitor visitor) {
    final destination = current.parseChildPath(visitor);
    return navigateTo(destination);
  }

  @override
  bool operator ==(Object other) =>
      other is NavigationStack &&
      (identical(other._stack, _stack) || other._stack == _stack) &&
      (identical(other.current, current) || other.current == current);

  @override
  int get hashCode => Object.hash(current, _stack);
}

/// Make [Destination] aware of [NavigationStack]
extension DestinationExtension on Destination {
  /// Create stack with [this] as root
  NavigationStack createStack() => NavigationStack.root(this);
}
