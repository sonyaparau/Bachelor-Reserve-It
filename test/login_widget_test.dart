import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/current_location.dart';

import 'package:reserve_it_app/screens/login.dart';

void main() {

  Widget createWidgetForTesting({Widget child}){
    return MaterialApp(
      home: child,
    );
  }

  Function ignoreOverflowErrors = (
      FlutterErrorDetails details, {
        bool forceReport = false,
      }) {
    assert(details != null);
    assert(details.exception != null);

    bool ifIsOverflowError = false;

    // Detect overflow error.
    var exception = details.exception;
    if (exception is FlutterError)
      ifIsOverflowError = !exception.diagnostics
          .any((e) => e.value.toString().startsWith("A RenderFlex overflowed by"));

    // Ignore if is overflow error.
    if (!ifIsOverflowError)
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  };

  testWidgets('Login Buttons', (WidgetTester tester) async {

    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      Provider<CurrentUserLocation> (
        create: (BuildContext context) { return CurrentUserLocation();},
        child: createWidgetForTesting(child: LoginPage()),
      )
    );

    var phoneNumberField = find.byType(TextFormField);
    var loginButton = find.text('Verify phone number');
    var googleButton = find.text('Sign in with Google');
    var facebookButton = find.text('Sign in with Facebook');

    expect(phoneNumberField, findsNWidgets(1));
    expect(loginButton, findsOneWidget);
    expect(googleButton, findsOneWidget);
    expect(facebookButton, findsOneWidget);
  });

  testWidgets('Phone number textfield', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
        Provider<CurrentUserLocation> (
          create: (BuildContext context) { return CurrentUserLocation();},
          child: createWidgetForTesting(child: LoginPage()),
        )
    );

    var phoneNumberField = find.byType(TextFormField);
    expect(phoneNumberField, findsNWidgets(1));
  });

  testWidgets('Login with phone number', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
        Provider<CurrentUserLocation> (
          create: (BuildContext context) { return CurrentUserLocation();},
          child: createWidgetForTesting(child: LoginPage()),
        )
    );

    var phoneNumberField = find.byType(TextFormField);
    var loginButton = find.text('Verify phone number');

    expect(find.text('0720885258'), findsNothing);
    await tester.enterText(phoneNumberField, '0720885258');
    expect(find.text('0720885258'), findsOneWidget);

    FlutterError.onError = ignoreOverflowErrors;

    expect(loginButton, findsOneWidget);
    expect(find.text('Login'), findsNothing);
  });


}
