import 'navigation_controller.dart';

/// Signature of function that returns a [NavigationController]
typedef NavigationControllerProvider = NavigationController Function();

late NavigationControllerProvider _provider;

/// Register the [NavigationControllerProvider].
/// It provides [NavigationController] which can be later accessed via [navigationController]
void registerNavigationControllerProvider(
  NavigationControllerProvider provider,
) {
  _provider = provider;
}

/// Signature to provide [NavigationController] instance
///
/// Typically, [NavigationController] instance would be stored in the state of the application
/// And a GlobalKey can be associated with the application widget, so the state can be accessed globally.
///
/// ```dart
///
/// final GlobalKey<AppState> _appStateKey = GlobalKey<AppState>();
///
/// class App extends StatefulWidget {
///   static AppState get state => _appStateKey.currentState!;
///
///   App() : super(key: _appStateKey);
///
///   @override
///   State<App> createState() => AppState();
/// }
///
/// class AppState extends State<App> {
///   late NavigationController _navigationController;
///   late AppDestinationStackParser _locationParser;
///
///   @override
///   void initState() {
///     super.initState();
///
///     _locationParser = const AppDestinationStackParser();
///
///     _navigationController = NavigationController(
///       pageFactory: _locationParser.buildPageFactory(),
///       initialStack: _locationParser.buildRootStack(),
///     );
///
///     registerNavigationControllerProvider(
///       () => _appStateKey.currentState!._navigationController,
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) => MaterialApp.router(
///         title: 'Flutter Router Demo',
///         theme: ThemeData(
///           primarySwatch: Colors.blue,
///         ),
///         routeInformationParser: _locationParser,
///         routerDelegate: _navigationController,
///       );
/// }
/// ```
NavigationController get navigationController => _provider();
