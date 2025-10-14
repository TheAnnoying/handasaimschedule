import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:handasaimschedule/fetchers/appstorage.dart';
import 'package:handasaimschedule/fetchers/fetcher.dart';

import 'package:handasaimschedule/pages/schedule/components/card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<Schedule>(
        future: Data.schedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('שגיאה: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));

          final schedule = snapshot.data;

          if (schedule == null || schedule.entries.isEmpty) return Center(child: Text('No schedule found.'));
          return Column(
            children: schedule.entries.map((entry) {
              return ScheduleCard(color: AppStorage.get("color-${entry.subjects.join('-')}"), schedule: schedule, entry: entry);
            }).toList(),
          ).animate().scale(duration: Duration(milliseconds: 200), begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOutCirc).fade(duration: Duration(milliseconds: 200), begin: 0, end: 1, curve: Curves.easeOutExpo);
        },
      )
    );
  }
}