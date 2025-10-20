import 'package:handasaimschedule/fetchers/app_storage.dart';
import 'package:flutter/material.dart';

class ThemeDialog extends StatefulWidget {
  const ThemeDialog({super.key});

  @override
  State<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  List<MaterialColor> leadingColors = [
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('בחירת צבע', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      icon: Icon(Icons.book),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () { AppStorage.remove("color-app"); },
                child: Text("איפוס")
              ),
              ...leadingColors.map((color) {
                return InkWell(
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onTap: () { setState(() => {}); AppStorage.set("color-app", color.toARGB32()); },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppStorage.get("color-app") == color.toARGB32() ? Icons.check : Icons.palette_rounded,
                      color: color.shade900
                    )
                  )
                );
            })],
          ),
        ),
      )
    );
  }
}