import 'package:handasaimschedule/fetchers/schedule_fetcher.dart';
import 'package:handasaimschedule/fetchers/app_storage.dart';
import 'package:handasaimschedule/theme/dynamic_theme.dart';
import 'package:handasaimschedule/widgets/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();

  runApp(ProviderScope(child: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _selectedClassName = AppStorage.get("className") ?? "ז 1";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            title: "מערכת הנדסאים",
            theme: getThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(AppStorage.get("color-app") ?? (lightDynamic?.primary.toARGB32() ?? Colors.lightBlue.toARGB32())), brightness: Brightness.light)),
            darkTheme: getThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(AppStorage.get("color-app") ?? (darkDynamic?.primary.toARGB32() ?? Colors.lightBlue.toARGB32())), brightness: Brightness.dark)),
            debugShowCheckedModeBanner: false,
            home: Directionality(textDirection: TextDirection.rtl,
              child: Consumer(
                builder: (context, ref, _) {
                  final scheduleState = ref.watch(scheduleProvider);

                  return scheduleState.when(
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    error: (_, _) => const Center(child: Text('שגיאה בטעינת המערכת')),
                    data: (schedule) => Scaffold(
                      appBar: AppBar(
                        centerTitle: false,
                        automaticallyImplyLeading: false,
                        primary: true,
                        forceMaterialTransparency: true,
                        title: Text(schedule.day, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      body: SchedulePage(schedule: schedule),
                      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
                      floatingActionButton: FloatingActionButton.extended(
                        icon: Icon(Icons.edit),
                        tooltip: "החלפת הכיתה המוצגת",
                        label: Text(_selectedClassName),
                        onPressed: () => showDialog(context: context, builder: (context) => AlertDialog(
                        title: Text('בחירת כיתה', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        icon: Icon(Icons.book),
                        contentPadding: EdgeInsets.zero,
                        content:
                          schedule.getClasses().isEmpty
                            ? Center(child: Text('לא נמצאו כיתות.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)))
                            : SingleChildScrollView(
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
                                      ...schedule.getClasses().map((className) {
                                        return ListTile(
                                          title: Text(className.replaceFirst(' ', "'")),
                                          leading: Radio<String>(value: className),
                                        );
                                      })
                                    ]
                                  )
                                ),
                              ),
                            )
                          )
                        )
                      ),
                    )
                  );
                }
              ),
            )
          );
        }
      );
  }
}
