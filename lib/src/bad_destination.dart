import 'destination.dart';
import 'navigation_stack.dart';
import 'route_path_visitor.dart';

/// Predefined [Destination] that represents navigation errors. Similar to 404 page for web.
class BadDestination with Destination {
  /// Error name for [BadDestination.emptyLocation]
  static const emptyLocationError = "empty_location";

  /// Error name for [BadDestination.unknownLocation]
  static const unknownLocationError = "unknown_location";

  /// Error name for [BadDestination.unreachableLocation]
  static const unreachableLocationError = "unreachable_location";

  /// Name of the destination
  ///
  /// Would be one of the values of [emptyLocationError], [unknownLocationError] or [unreachableLocationError].
  @override
  final String name;

  /// Human friendly messsage describing the error
  final String message;

  /// Detailed information about the error, would be useful for debugging
  final String detail;

  BadDestination._({
    required this.name,
    required this.message,
    required this.detail,
  });

  /// Destination used when location is given or is empty
  factory BadDestination.emptyLocation({
    String message = "Empty Location",
    String detail = "",
  }) =>
      BadDestination._(
        name: emptyLocationError,
        message: message,
        detail: detail,
      );

  /// Destination used when the destionation is unknown
  factory BadDestination.unknownLocation(
    String location, {
    String message = "Unknown Location",
  }) =>
      BadDestination._(
        name: unknownLocationError,
        message: message,
        detail: location,
      );

  /// Create [BadDestination.unknownLocation] from [RoutePathVisitor]
  /// It calls [visitor.badLocation] to retrieve the full location string and also mark the visitor as bad location.
  factory BadDestination.from(RoutePathVisitor visitor) =>
      BadDestination.unknownLocation(visitor.badLocation());

  /// Destination used when the destionation is unreachable
  ///
  /// It indicates there is no possible route from [from] destination to [to] destination.
  factory BadDestination.unreachableLocation({
    required NavigationStack from,
    required Destination to,
    String message = "Unreachable Location",
  }) =>
      BadDestination._(
        name: unreachableLocationError,
        message: message,
        detail: "${from.allNodes.toList(growable: false)} -> $to",
      );

  @override
  Destination parseChildPath(RoutePathVisitor visitor) =>
      BadDestination.from(visitor);

  @override
  Iterable<Destination>? tryBuildRootStack() => [this];

  @override
  Iterable<Destination>? tryNavigateFrom(Destination current) => null;

  @override
  bool operator ==(Object other) =>
      other is BadDestination &&
      (identical(other.name, name) || name == other.name) &&
      (identical(other.message, message) || message == other.message) &&
      (identical(other.detail, detail) || other.detail == detail);

  @override
  int get hashCode => Object.hash(runtimeType, name, message, detail);
}
