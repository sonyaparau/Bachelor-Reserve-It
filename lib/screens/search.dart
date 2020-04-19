import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/utils/custom_widgets.dart';

class LocalSearch extends SearchDelegate<String> {
  //list with all the names of the found locals
  List<String> _suggestions = [];

  //list with all found locals
  List<Local> _foundLocals = [];

  //index of the tapped local in the search scree
  int tappedIndex = 0;

  //user's location is enabled or not
  bool _locationEnabled;

  CustomWidgets customWidgets = CustomWidgets();

  LocalSearch(
      bool locationEnabled, List<String> locals, List<Local> foundLocals) {
    _suggestions = locals;
    this._locationEnabled = locationEnabled;
    this._foundLocals = foundLocals;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.deepPurple,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      textSelectionColor: Colors.white,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for app bar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show result based on selection
    return customWidgets.buildLocalCard(
        context, _foundLocals[tappedIndex], _locationEnabled);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when user searches for something
    final options = _suggestions
        .where((element) => element.trim().startsWith(query))
        .toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              leading: Icon(Icons.local_dining, color: Colors.grey),
              title: RichText(
                  text: TextSpan(
                      text: options[index].substring(0, query.length),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      children: [
                    TextSpan(
                        text: options[index].substring(query.length),
                        style: TextStyle(color: Colors.grey, fontSize: 20))
                  ])),
              onTap: () {
                tappedIndex = _suggestions.indexOf(options[index]);
                showResults(context);
              },
            ),
        itemCount: options.length);
  }
}
