import 'package:handasaimschedule/fetchers/schedule_fetcher.dart';
import 'package:handasaimschedule/widgets/segmented_buttons.dart';
import 'package:handasaimschedule/fetchers/app_storage.dart';
import 'package:handasaimschedule/theme/dynamic_theme.dart';
import 'package:handasaimschedule/widgets/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();

  runApp(ProviderScope(child: App()));
}

class Destination {
  const Destination(this.selectedIcon, this.icon, this.label);
  final IconData selectedIcon;
  final IconData icon;
  final String label;
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Destination> destinations = <Destination>[
    Destination(Icons.home, Icons.home_outlined, "מערכת"),
    Destination(Icons.settings, Icons.settings_outlined, "הגדרות")
  ];

  String _selectedName = AppStorage.get("selectedName") ?? "ז'1";
  String _selectedType = AppStorage.get("selectedType") ?? "class";
  List<String> _selectedOptions = [];

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void updateSelectionOptions(Schedule schedule){
    if(_selectedType == "teacher") {
      _selectedOptions = schedule.teacherList.toList()..sort();
    } else {
      _selectedOptions = schedule.getClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: "מערכת הנדסאים",
          theme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: .tonalSpot, seedColor: lightDynamic?.primary ?? Colors.purple, brightness: .light)),
          darkTheme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: .tonalSpot, seedColor: darkDynamic?.primary ?? Colors.purple, brightness: .dark)),
          debugShowCheckedModeBanner: false,
          home: Directionality(
            textDirection: .rtl,
            child: Consumer(
              builder: (context, ref, _) {
                final scheduleState = ref.watch(scheduleProvider);

                return scheduleState.when(
                  loading: () => Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Scaffold(
                    body: Center(child: Text('שגיאה בטעינת המערכת')),
                  ),
                  data: (schedule) {
                    updateSelectionOptions(schedule);
                    return Scaffold(
                      bottomNavigationBar: LayoutBuilder(
                        builder: (context, constraints) {
                          if(constraints.maxWidth < 600) {
                            return NavigationBar(
                              onDestinationSelected: (int index) {
                                setState(() {
                                  currentPageIndex = index;                          
                                });
                              },
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                              selectedIndex: currentPageIndex,
                              destinations: destinations.map((d) => NavigationDestination(
                                icon: Icon(d.icon),
                                label: d.label,
                              )).toList()
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                      ),
                      body: LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            children: [
                              if(constraints.maxWidth >= 600)
                                NavigationRail(
                                  onDestinationSelected: (int index) {
                                    setState(() {
                                      currentPageIndex = index;
                                    });
                                  },
                                  selectedIndex: currentPageIndex,
                                  labelType: .all,
                                  elevation: 2,
                                  destinations: destinations.map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label))).toList()
                                ),
                              Expanded(
                                child: Padding(
                                  padding: .only(right: 24, left: 24, top: 48),
                                  child: Align(
                                    alignment: .topCenter,
                                    child: SizedBox(width: 500, child: appPages(schedule, context))
                                  )
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    );
                  }
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget appPages(Schedule schedule, BuildContext context) {
    return [
      SchedulePage(schedule: schedule),
      Column(
        children: [
          SegmentedButtons(
            items: [
              SegmentItem(
                value: "class",
                label: "אני תלמיד",
                icon: Icons.school,
              ),
              SegmentItem(
                value: "teacher",
                label: "אני מורה",
                icon: Icons.person,
              )
            ],
            value: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
                updateSelectionOptions(schedule);
                _selectedName = _selectedOptions.first;
              });
                  
              AppStorage.set("selectedType", _selectedType);
              AppStorage.set("selectedName", _selectedName);
            },
          ),
          if (_selectedType == "teacher")
            Padding(
              padding: .only(top: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: .all(.circular(8))),
                tileColor: Theme.of(context).splashColor,
                contentPadding: .all(16),
                leading: Icon(Icons.warning),
                subtitle: Text('רשימת המורים בנויה מהמורים שיש להם שעות היום.\nבתור מורה יש מצב שלא תימצא ברשימה הזו.'),
              ).animate().scale(duration: Duration(milliseconds: 200), begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOutCirc).fade(duration: Duration(milliseconds: 200), begin: 0, end: 1, curve: Curves.easeOutExpo),
            ),
          Padding(
            padding: .only(top: 8),
            child: DropdownMenu<String>(
              initialSelection: _selectedName,
              requestFocusOnTap: true,
              enableSearch: true,
              menuHeight: 600,
              menuStyle: MenuStyle(
                backgroundColor: .all(Theme.of(context).colorScheme.surfaceBright),
                shape: .all(RoundedRectangleBorder(borderRadius: .circular(20))),
                padding: .all(.all(8)),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                contentPadding: .symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: .circular(999),
                  borderSide: .none,
                ),
              ),
              onSelected: (String? value) {
                setState(() {
                  _selectedName = value ?? _selectedOptions.first;
                });
                AppStorage.set("selectedName", value);
              },
              dropdownMenuEntries: _selectedOptions.map((name) => 
                DropdownMenuEntry<String>(
                  value: name,
                  label: name,
                  style: MenuItemButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(16)
                    )
                  )
                )
              ).toList(),
            ),
          ),
        ],
      )
    ][currentPageIndex];
  }
}