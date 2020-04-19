import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/local.dart';

class LocalDetails extends StatefulWidget {
  Local selectedLocal;

  LocalDetails({Key key, @required this.selectedLocal}) : super(key: key);

  @override
  _LocalDetailsState createState() => _LocalDetailsState(selectedLocal);
}

class _LocalDetailsState extends State<LocalDetails> {
  Local selectedLocal;

  _LocalDetailsState(this.selectedLocal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: Text(selectedLocal.name)),
        body: Center(
            child: Container(
                child: Column(children: [
          Image.network(selectedLocal.mainPhoto),
          SizedBox(
            height: 32,
          ),
          Text(
            selectedLocal.name,
            style: TextStyle(fontSize: 25),
          ),
          Text(
            selectedLocal.type,
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          )
        ]))));
  }
}
