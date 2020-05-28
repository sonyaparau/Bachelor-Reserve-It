import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';

/*
* Loading screen for actions that
* take a while to complete (like
* Authentication).
* */
class Loading extends StatelessWidget {
  CustomWidgets _customWidgets = CustomWidgets();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        color: Colors.white,
        child: Center(
          child: new Column(
            children: [
              _customWidgets.getHeightSizedBox(250.0),
              buildSpinKitLoading(),
              _customWidgets.getHeightSizedBox(25.0),
              buildTextLoading(),
              _customWidgets.getHeightSizedBox(140.0),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child:  buildPhoto(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /*
  * @return the text for the loading screen
  * */
  Text buildTextLoading() {
    return Text('  Hello 😃',
        style: TextStyle(
          fontSize: 30.0,
          color: Colors.grey,
        ));
  }

  /*
  * @return the spin kit for loading
  * */
  SpinKitFadingCircle buildSpinKitLoading() {
    return SpinKitFadingCircle(
      color: Colors.deepPurple,
      size: 100.0,
    );
  }

  /*
  * @return the AppBar for the loading screen
  * */
  AppBar buildAppBar() {
    return AppBar(
        title: Row(
      children: <Widget>[
        buildImageLogo(32.0),
        buildContainerTitle(),
      ],
    ));
  }

  /*
  * @return the text for the app bar
  * */
  Container buildContainerTitle() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Loading',
      ),
    );
  }

  /*
  * @return the logo of the application
  * */
  Image buildImageLogo(double height) {
    return Image.asset(
      'assets/app_logo.png',
      fit: BoxFit.contain,
      height: height,
      color: Colors.grey,
    );
  }

  /*
  * Creates the bottom of the loading screen containing
  * the app's logo and name.
  * */
  buildPhoto() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildImageLogo(48.0),
        _customWidgets.getWidthSizedBox(2.0),
        Text('ReserveIt', style: TextStyle(color: Colors.black54))
      ],
    );
  }
}