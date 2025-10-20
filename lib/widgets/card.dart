import 'package:handasaimschedule/fetchers/schedule_fetcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ScheduleCard extends StatefulWidget {
  final Lesson entry;
  final List<Lesson> classSchedule;
  final MaterialColor? color;

  const ScheduleCard({super.key, required this.entry, required this.classSchedule, required this.color});

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
    final classSchedule = widget.classSchedule;
    final entry = widget.entry;
    final entryIndex = classSchedule.indexOf(entry);
    final expandForMoreSubjects = entry.teachers.length > 1 && entry.subjects.length > 1 && entry.teachers.length == entry.subjects.length;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: isBetweenEntryStartAndEnd(entry.hours[1]) ? Theme.of(context).splashColor.withAlpha(55) : Theme.of(context).splashColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: classSchedule.indexOf(entry) == 0 || (expandForMoreSubjects && expandState) || isBeforeEntryStart(entry.hours[1]) && isAfterEntryEnd(entryIndex == 0 ? entry.hours[1] : classSchedule[entryIndex - 1].hours[1])
                ? const Radius.circular(16)
                : Radius.circular(5),
              bottom: classSchedule.indexOf(entry) == classSchedule.length - 1 || (expandForMoreSubjects && expandState) || isAfterEntryEnd(entry.hours[1]) && isBeforeEntryStart(entryIndex == classSchedule.length - 1 ? entry.hours[1] : classSchedule[entryIndex + 1].hours[1])
                ? const Radius.circular(16)
                : Radius.circular(5)
            ),
          ),
          margin: EdgeInsets.only(
            left: 24,
            right: 24,
            top: classSchedule.indexOf(entry) == 0 ? 24 : 2,
            bottom: classSchedule.indexOf(entry) + 1 == classSchedule.length ? 24 : 0
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            radius: 500,
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
                        if(expandForMoreSubjects) AnimatedRotation(turns: expandState ? 0.5 : 0, curve: Curves.easeOutExpo, duration: Duration(milliseconds: 350), child: Icon(size: 20, Icons.keyboard_arrow_down)),
                        Text(entry.hours[1].replaceAll(' - ', '\n'), style: GoogleFonts.sanchez(fontSize: 13)),
                      ],
                    ),
                    title: expandForMoreSubjects ? Text("${entry.subjects[0]}ועוד...") : Text(entry.subjects.join(', '), style: TextStyle(letterSpacing: 0.1)),
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
                    )
                ],
              ),
            )
          ),
        ),
        if(isAfterEntryEnd(entry.hours[1]) && isBeforeEntryStart(entryIndex == classSchedule.length - 1 ? entry.hours[1] : classSchedule[entryIndex + 1].hours[1]))
         Card(
          elevation: 0,
          color: Theme.of(context).splashColor.withAlpha(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(0)
            ),
          ),
          margin: EdgeInsets.only(left: 40, right: 40, top: 4, bottom: 0),
          child: Center(
            child: Text('את/ה פה', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),),
          )
        ).animate().fade()
      ],
    );
  }
}