import 'package:flutter/material.dart';
import 'package:handasaimschedule/fetchers/appstorage.dart';

class ClassDialog extends StatefulWidget {
  final Future<List<String>> classNames;
  const ClassDialog({super.key, required this.classNames});

  @override
  State<ClassDialog> createState() => _ClassDialogState();
}

class _ClassDialogState extends State<ClassDialog> {
  String _selectedClassName = AppStorage.get("className") ?? "ז 1";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('בחירת כיתה', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      icon: Icon(Icons.book),
      contentPadding: EdgeInsets.zero,
      content:
        FutureBuilder<List<String>>(
          future: widget.classNames,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('שגיאה: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
            }

            final classNames = snapshot.data ?? <String>[];

            if (classNames.isEmpty) {
              return Center(child: Text('לא נמצאו כיתות.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
            }

            return SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: RadioGroup<String>(
                  groupValue: _selectedClassName,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedClassName = value ?? "ז 1";
                    });
                
                    AppStorage.set("className", value ?? "ז 1");
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ...classNames.map((className) {
                        return ListTile(
                          title: Text(className.replaceFirst(' ', "'")),
                          leading: Radio<String>(value: className),
                        );
                      })
                    ]
                  )
                ),
              ),
            );
          },
        ),
    );
  }
}