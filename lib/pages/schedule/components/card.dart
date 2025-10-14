import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handasaimschedule/fetchers/fetcher.dart';

class ScheduleCard extends StatefulWidget {
  final ScheduleEntry entry;
  final Schedule schedule;
  final MaterialColor? color;

  const ScheduleCard({super.key, required this.entry, required this.schedule, required this.color});

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool expandState = false;
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  bool isAfterEntryEnd(String entryHourRange) {
    final parts = entryHourRange.split('-');
    if (parts.length != 2) return false;

    final end = parts[1].trim();
    final endParts = end.split(':');
    if (endParts.length != 2) return false;

    final endTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    return _now.isAfter(endTime);
  }

  bool isBeforeEntryStart(String entryHourRange) {
    final parts = entryHourRange.split('-');
    if (parts.length != 2) return false;

    final start = parts[0].trim();
    final startParts = start.split(':');
    if (startParts.length != 2) return false;

    final startTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    return _now.isBefore(startTime);
  }

  bool isBetweenEntryStartAndEnd(String entryHourRange) {
    final parts = entryHourRange.split('-');
    if (parts.length != 2) return false;

    final start = parts[0].trim();
    final end = parts[1].trim();

    final startParts = start.split(':');
    final endParts = end.split(':');
    if (startParts.length != 2 || endParts.length != 2) return false;

    final startTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    final endTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    return _now.isAfter(startTime) && _now.isBefore(endTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final color = widget.color;
    final schedule = widget.schedule;
    final entry = widget.entry;
    final entryIndex = schedule.entries.indexOf(entry);
    final expandForMoreSubjects = entry.teachers.length > 1 && entry.subjects.length > 1 && entry.teachers.length == entry.subjects.length;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: isBetweenEntryStartAndEnd(entry.hours[1]) ? Theme.of(context).splashColor.withAlpha(55) : Theme.of(context).splashColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: schedule.entries.indexOf(entry) == 0 || (expandForMoreSubjects && expandState)
                ? const Radius.circular(16)
                : Radius.circular(5),
              bottom: schedule.entries.indexOf(entry) == schedule.entries.length - 1 || (expandForMoreSubjects && expandState)
                ? const Radius.circular(16)
                : Radius.circular(5)
            ),
          ),
          margin: EdgeInsets.only(
            left: 24,
            right: 24,
            top: schedule.entries.indexOf(entry) == 0 ? 24 : 2,
            bottom: schedule.entries.indexOf(entry) + 1 == schedule.entries.length ? 24 : 0
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => setState(() => expandState = !expandState),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutExpo,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color?.shade100 ?? Theme.of(context).highlightColor,
                      child: Text(
                        entry.hours[0].replaceAll(RegExp(r'[^0-9]'), ''),
                        style: GoogleFonts.kronaOne(color: color?.shade900 ?? Theme.of(context).hintColor, fontWeight: FontWeight.w500)
                      ),
                    ),
                    trailing: Row(
                      spacing: 15,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(expandForMoreSubjects) AnimatedRotation(turns: expandState ? 0.5 : 0, curve: Curves.easeOutExpo, duration: Duration(milliseconds: 250), child: Icon(size: 20, Icons.arrow_downward)),
                        Text(entry.hours[1].replaceAll(' - ', '\n'), style: GoogleFonts.sanchez(fontSize: 13)),
                      ],
                    ),
                    title: expandForMoreSubjects ? Text(entry.subjects[0] + "ועוד...") : Text(entry.subjects.join(', '), style: TextStyle(letterSpacing: 0.1)),
                    subtitle: expandForMoreSubjects ? (expandState ? Text("לחצו להסתרה") : Text("לחצו להצגה")) : Text(entry.teachers.join(', ')),
                  ),
                  if(expandForMoreSubjects && expandState) for (var index = 0; index < entry.subjects.length; index++)
                    Padding(
                      padding: EdgeInsets.only(right: 8, left: 8, top: index == 0 ? 0 : 1, bottom: index == entry.subjects.length - 1 ? 8 : 1),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: index == 0 ? const Radius.circular(16) : Radius.circular(5), bottom: index == entry.subjects.length - 1 ? const Radius.circular(16) : Radius.circular(5)),),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(entry.subjects[index]),
                        subtitle: Text(entry.teachers[index]),
                        tileColor: Theme.of(context).colorScheme.surface.withAlpha(90)
                      ),
                    ),
                ],
              ),
            )
          ),
        ),
        if(isAfterEntryEnd(entry.hours[1]) && isBeforeEntryStart(entryIndex == schedule.entries.length - 1 ? entry.hours[1] : schedule.entries[entryIndex + 1].hours[1]))
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24),
            child: Row(
              children: <Widget>[
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2, bottom: 2),
                  child: Text('את/ה פה', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),),
                ),
                Expanded(child: Divider())
              ],
            ),
          ).animate().fade()
      ],
    );
  }
}