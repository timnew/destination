import 'package:destination/src/bad_destination.dart';

/// A visitor that denote the location string into parts
class RoutePathVisitor {
  /// Full location given
  final String location;

  /// The seperator used by the visitor
  final String seperator;

  /// All parts from [location]
  late List<String> _parts;

  RoutePathVisitor(this.location, {this.seperator = '/'}) {
    reset();
  }

  /// Reset the visitor
  void reset() {
    _parts = location.split(seperator);
    if (location.endsWith(seperator)) {
      _parts.removeLast();
    }
    _parts = _parts.reversed.toList();
  }

  /// Call by the parser to indicate the current location is a bad one
  /// Use by [BadDestination.from]
  String badLocation() {
    _parts.clear(); // Drop all remaining parts

    return location; // Return the full location
  }

  /// Whether the visitor has more parts
  bool get hasNext => _parts.isNotEmpty;

  /// Get next part but not consume it
  String get peek => _parts.last;

  /// Consume the next part
  ///
  /// [skip] can be used to skip the number of parts before consuming it.
  String consume({int skip = 0}) {
    for (int i = 0; i < skip; i++) {
      _parts.removeLast();
    }
    return _parts.removeLast();
  }

  /// Consume the next part and assert its value.
  /// Useful to assert the constant path parts
  RoutePathVisitor check(String value) {
    assert(consume() == value);
    return this;
  }
}
