import 'package:handasaimschedule/fetchers/schedule_fetcher.dart';
import 'package:handasaimschedule/fetchers/app_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:handasaimschedule/widgets/card.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final Schedule schedule;
  const SchedulePage({super.key, required this.schedule});

  @override
  State<SchedulePage> createState() => _SchedulePagePageState();
}

class _SchedulePagePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    final List<Lesson> classLessons;
    switch(AppStorage.get("selectedType")) {
      case "teacher":
        classLessons = widget.schedule.getTeacherSchedule(AppStorage.get("selectedName"))!.lessons;
      default:
        classLessons = widget.schedule.getClass(AppStorage.get("selectedName") ?? widget.schedule.getClasses()[0])!.lessons;
        break;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: .only(bottom: 3, right: 8),
            child: Row(
              spacing: 5,
              crossAxisAlignment: .center,
              children: [
                Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
                Text(widget.schedule.day, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
              ],
            ),
          ),
          if(classLessons.isNotEmpty)
            ...classLessons.map((entry) {
              return ScheduleCard(
                entry: entry,
                classSchedule: classLessons
              ).animate().scale(duration: Duration(milliseconds: 200), begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOutCirc).fade(duration: Duration(milliseconds: 200), begin: 0, end: 1, curve: Curves.easeOutExpo);
            }),
          if(classLessons.isEmpty)
            Text("אין שיעורים")
        ],
      ),
    );
  }
}