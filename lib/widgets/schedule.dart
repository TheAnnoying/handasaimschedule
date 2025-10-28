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
    final classSchedule = AppStorage.get("selectedType") == "class" ? widget.schedule.getClass(AppStorage.get("selectedName") ?? "ז'1")!.lessons : widget.schedule.getTeacherSchedule(AppStorage.get("selectedName") ?? "לפל לורטה")!.lessons;
    return SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 24, bottom: 5),
              child: Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 16, color: Theme.of(context).colorScheme.onSurface.withAlpha(200)),
                  Text(widget.schedule.day, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(200), fontSize: 14)),
                ],
              ),
            ),
            ...classSchedule.map((entry) {
              return ScheduleCard(
                entry: entry,
                classSchedule: classSchedule
              ).animate().scale(duration: Duration(milliseconds: 200), begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOutCirc).fade(duration: Duration(milliseconds: 200), begin: 0, end: 1, curve: Curves.easeOutExpo);
            })
          ]
        )
      ),
    );
  }
}