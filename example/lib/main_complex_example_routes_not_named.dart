import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

/// The first screen has a button which opens a second screen.
/// The second screen has 3 red squares. By tapping the Android back-button (or the "pop" button)
/// each square turns blue, one by one. Only when all squares are blue, tapping the back-button
/// once more will return to the previous screen.
///
/// Please see tests at: back_button_interceptor/test/complex_example/main_test.dart
///
void main() => runApp(AnotherExample());

////////////////////////////////////////////////////////////////////////////////////////////////////

class AnotherExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // This is removed:
      // routes: _createRoutes(),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) => PageRouteBuilder<dynamic>(
        barrierDismissible: true,
        opaque: false,
        pageBuilder: (context, _, __) => Home(),
      ),
    );
  }

// This is removed:
// Map<String, WidgetBuilder> _createRoutes() {
//   return {
//     RoutePaths.main: (_) => Home(),
//     RoutePaths.newScreen: (_) => NewScreen(),
//   };
// }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class RoutePaths {
  RoutePaths._();

// This is removed:
// static const main = '/';
// static const newScreen = '/new-screen';
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Same example,\nbut routes are not named.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            RaisedButton(
              onPressed: () => openNewScreen(context),
              child: const Text('Open new screen'),
            ),
          ],
        ),
      ),
    );
  }

  // void openNewScreen(BuildContext context) => Navigator.pushNamed(context, RoutePaths.newScreen);
  void openNewScreen(BuildContext context) => Navigator.push<dynamic>(
        context,
        PageRouteBuilder<dynamic>(
          barrierDismissible: true,
          opaque: false,
          pageBuilder: (context, _, __) => NewScreen(),
        ),
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class NewScreen extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ContainerWithInterceptor("first"),
                SizedBox(width: 20),
                ContainerWithInterceptor("second"),
                SizedBox(width: 20),
                ContainerWithInterceptor("third"),
              ],
            ),
            const SizedBox(height: 40),
            const RaisedButton(
              onPressed: BackButtonInterceptor.popRoute,
              child: Text('Pop'),
            ),
            RaisedButton(
              onPressed: () => _openDialog(context),
              child: const  Text('Open Dialog'),
            ),
          ],
        ),
      ),
    );
  }

  void _openDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("My Dialog"),
        content: Text("Click outside to close it, or use the back-button."),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class ContainerWithInterceptor extends StatefulWidget {
  //
  final String name;

  const ContainerWithInterceptor(this.name);

  @override
  State createState() => _ContainerWithInterceptorState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _ContainerWithInterceptorState extends State<ContainerWithInterceptor> {
  bool ifPop;

  void pop() => setState(() => ifPop = true);

  @override
  void initState() {
    super.initState();
    ifPop = false;
    BackButtonInterceptor.add(myInterceptor, name: widget.name, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ifPop ? Colors.blue : Colors.red),
      height: 50,
      width: 70,
    );
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return false;

    // If a dialog (or any other route) is open, don't run the interceptor.
    if (info.ifRouteChanged(context)) return false;

    if (ifPop)
      return false;
    else {
      pop();
      return true;
    }
  }
}
