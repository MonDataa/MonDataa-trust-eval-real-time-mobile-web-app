import 'package:flutter/material.dart';

class drawer_item extends StatelessWidget {
  final String title;
  final Icon itemIcon;
  final Function() handler;
  //final String route;
  const drawer_item(
      {super.key,
      required this.title,
      required this.itemIcon,
      required this.handler
      //,required this.route
      });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: itemIcon,
      trailing: Icon(Icons.arrow_forward),
      title: Text("$title", style: Theme.of(context).textTheme.bodyMedium),
      onTap: handler,
      /*onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, route);
        }*/
    );
  }
}
