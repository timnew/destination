import 'package:flutter/foundation.dart';

import 'bad_destination.dart';
import 'route_path_visitor.dart';

/// The type to describe the navigation destination
///
/// Adopter type should be value type.
mixin Destination {
  /// The name of the destination
  ///
  /// The same type of destination should have the same name.
  String get name;

  /// The key to identify the page
  LocalKey get pageKey => ValueKey(this);

  /// the restoration id of the page
  String? get restorationId => null;

  /// convert the destination to location parts, which is later joined into the location string
  ///
  /// The default implementation is to return the name of the destination.
  Iterable<String> toLocationParts() => [name];

  /// Try to build the destination chain from a certain location
  ///
  /// Return `null` if current destination can't be pushed onto [current] destination
  Iterable<Destination>? tryNavigateFrom(Destination current) => null;

  /// Try to build the desination from root
  ///
  /// Return `null` if current destion can't be a root destination
  Iterable<Destination>? tryBuildRootStack() => null;

  /// Parse child path provided by visitor.
  ///
  /// A typical implementation would be like
  /// ```dart
  /// Destination parseChildPath(RoutePathVisitor visitor)
  ///   switch(visitor.consume()) {
  ///     case "search": // Parsing /search/:query
  ///       return SearchDestination(query: vistor.consume());
  ///     case "address": // Parsing /address/street/:street/city/:city/post/:post_code/country/:country
  ///       return AddressDestination(
  ///         street: visitor.check("street").consume(),
  ///         city: visitor.check("city").consume(),
  ///         postCode: visitor.check("post_code").consume(),
  ///         country: visitor.check("country").consume(),
  ///       );
  ///     default:
  ///       return BadDestination.from(visitor);
  ///   }
  /// }
  /// ```
  ///
  /// Return [BadDestination] if location is invalid, and call [visitor.badLocation] to notify visitor location is invalid.
  /// Call [BadLocation.from] with [visitor] will do both task automatically.
  Destination parseChildPath(RoutePathVisitor visitor) =>
      BadDestination.from(visitor);
}
