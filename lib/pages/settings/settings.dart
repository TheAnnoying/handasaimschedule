import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:handasaimschedule/fetchers/fetcher.dart';
import 'package:handasaimschedule/pages/settings/components/classdialog.dart';
import 'package:handasaimschedule/pages/settings/components/themedialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          onTap: () => showDialog(context: context, builder: (context) => ClassDialog(classNames: Data.classNames)),
          leading: Icon(Icons.book),
          title: Text("כיתה", style: TextStyle(letterSpacing: 0.1)),
          subtitle: Text("מערכת של איזו כיתה להראות"),
        ),
        ListTile(
          onTap: () => showDialog(context: context, builder: (context) => ThemeDialog()),
          leading: Icon(Icons.palette),
          title: Text("צבע אפליקציה"),
          subtitle: Text("בחירת צבע הנושא של האפליקציה"),
        )
      ],
    ).animate().scale(duration: Duration(milliseconds: 200), begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOutCirc).fade(duration: Duration(milliseconds: 200), begin: 0, end: 1, curve: Curves.easeOutExpo);
  }
}