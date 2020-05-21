import 'package:flutter/material.dart';
import 'package:reserve_it_app/screens/screenUtils/user_choice.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: UserChoice.userChoice.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Personal information'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: UserChoice.userChoice.map<Widget>((UserChoice chice) {
              return Tab(text: chice.title, icon: Icon(chice.icon));
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: UserChoice.userChoice.map((UserChoice userChoice)  {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Choice(
                userChoice: userChoice,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Choice extends StatelessWidget {
  final UserChoice userChoice;

  const Choice({Key key, this.userChoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;

    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(userChoice.icon, size: 150.0, color: textStyle.color),
            Text(
              userChoice.title,
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }
}
