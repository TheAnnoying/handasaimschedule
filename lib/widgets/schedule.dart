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
    return SingleChildScrollView(
      child: Column(
        children:
          widget.schedule.getClass(AppStorage.get("className") ?? "ז 1")!.lessons.map((entry) {
            return ScheduleCard(
              entry: entry,
              classSchedule: widget.schedule.getClass(AppStorage.get("className") ?? "ז 1")!.lessons,
              color: AppStorage.get("color-${entry.subjects.join('-')}")
            ).animate().scale(duration: Duration(milliseconds: 200), begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOutCirc).fade(duration: Duration(milliseconds: 200), begin: 0, end: 1, curve: Curves.easeOutExpo);
          }).toList()
      )
    );
  }
}