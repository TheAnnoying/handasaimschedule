import 'package:handasaimschedule/fetchers/schedule_fetcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ScheduleCard extends StatefulWidget {
  final Lesson entry;
  final List<Lesson> classSchedule;

  const ScheduleCard({super.key, required this.entry, required this.classSchedule});

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

  bool timeIsAfterEntryEnd(String entryHourRange) {
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

  bool timeIsBeforeEntryStart(String entryHourRange) {
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

  bool timeIsBetweenEntryStartAndEnd(String entryHourRange) {
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

  String timeDifference(String start, String end) {
    List<String> startParts = start.split(':');
    List<String> endParts = end.split(':');
    int startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    int diff = endMinutes - startMinutes;
    if (diff < 0) diff += 24 * 60;

    int hours = diff ~/ 60;
    int minutes = diff % 60;

    if (hours == 0) {
      return '$minutes דקות';
    } else if (minutes == 0) {
      return hours == 1 ? 'שעה' : '$hours שעות';
    } else {
      String hourPart = hours == 1 ? 'שעה' : '$hours שעות';
      return '$hourPart ו$minutes דקות';
    }
  }

  double timeProgress(String entryHourRange) {
    final parts = entryHourRange.split('-');
    if (parts.length != 2) return 0.0;

    final start = parts[0].trim();
    final end = parts[1].trim();

    final startParts = start.split(':');
    final endParts = end.split(':');
    if (startParts.length != 2 || endParts.length != 2) return 0.0;

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

    if (_now.isBefore(startTime)) return 0.0;
    if (_now.isAfter(endTime)) return 1.0;

    final totalDuration = endTime.difference(startTime).inSeconds;
    final elapsed = _now.difference(startTime).inSeconds;

    return elapsed / totalDuration;
  }

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

  String getStartHour(String hour) {
    return hour.replaceAll(RegExp(r'[\d: -]{8}$'), '');
  }

  String getEndHour(String hour) {
    return hour.replaceAll(RegExp(r'^[\d: -]{8}'), '');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classSchedule = widget.classSchedule;
    final entry = widget.entry;

    final entryIndex = classSchedule.indexOf(entry);
    final expandForMoreSubjects = entry.teachers.length > 1 && entry.subjects.length > 1 && entry.teachers.length == entry.subjects.length;

    final nextEntry = entryIndex == classSchedule.length - 1 ? null : classSchedule[entryIndex + 1];
    final lastEntry = entryIndex == 0 ? null : classSchedule[entryIndex - 1];

    final isBreakBefore = lastEntry == null
      ? false
      : getEndHour(lastEntry.hours[1]) != getStartHour(entry.hours[1]) && getEndHour(lastEntry.hours[1]) != getEndHour(entry.hours[1]);

    final isBreakAfter = nextEntry == null
      ? false
      : getEndHour(entry.hours[1]) != getStartHour(nextEntry.hours[1]) && getEndHour(entry.hours[1]) != getEndHour(nextEntry.hours[1]);

    final timeIsWithinBreak = nextEntry == null
      ? false
      : timeIsAfterEntryEnd(entry.hours[1]) && timeIsBeforeEntryStart(nextEntry.hours[1]);

    final timeIsCurrentHour = timeIsBetweenEntryStartAndEnd(entry.hours[1]);

    return Column(
      children: [
        Card(
          elevation: 0,
          color: timeIsCurrentHour ? Theme.of(context).splashColor.withAlpha(55) : Theme.of(context).splashColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: classSchedule.indexOf(entry) == 0 || (expandForMoreSubjects && expandState) || isBreakBefore
                ? const Radius.circular(16)
                : Radius.circular(5),
              bottom: classSchedule.indexOf(entry) == classSchedule.length - 1 || (expandForMoreSubjects && expandState) || isBreakAfter
                ? const Radius.circular(16)
                : Radius.circular(5)
            ),
          ),
          margin: EdgeInsets.only(
            right: 12,
            left: 12,
            top: 2,
            bottom: classSchedule.indexOf(entry) == classSchedule.length - 1 ? 100 : 0
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
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: timeIsCurrentHour ? 15 : 20,
                          backgroundColor: leadingColors[entryIndex].shade100,
                          child: Text(
                            textAlign: TextAlign.center,
                            entry.hours[0],
                            style: GoogleFonts.kronaOne(color: leadingColors[entryIndex].shade900, fontWeight: FontWeight.w500)
                          ),
                        ),
                        if(timeIsCurrentHour) TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: timeProgress(entry.hours[1])),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOutExpo,
                          builder: (_, value, _) => CircularProgressIndicator(color: leadingColors[entryIndex].shade300, strokeCap: StrokeCap.round, strokeAlign: 1, value: value)
                        ),
                      ],
                    ),
                    trailing: Row(
                      spacing: 15,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(expandForMoreSubjects) AnimatedRotation(turns: expandState ? 0.5 : 0, curve: Curves.easeOutExpo, duration: Duration(milliseconds: 350), child: Icon(size: 20, Icons.keyboard_arrow_down)),
                        Text(entry.hours[1].replaceAll(' - ', '\n'), style: GoogleFonts.sanchez(fontSize: 13)),
                      ],
                    ),
                    title: expandForMoreSubjects ? Text("${entry.subjects[0]}ועוד...") : Text(entry.subjects.isNotEmpty ? entry.subjects.join(', ') : "לא ידוע", style: TextStyle(letterSpacing: 0.1)),
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
        if(isBreakAfter)
          Padding(
            padding: EdgeInsets.only(right: 24, left: 24, top: 5, bottom: 5),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Text("${timeDifference(getEndHour(entry.hours[1]), getStartHour(nextEntry.hours[1]))} ${timeIsWithinBreak ? ' - כעת' : ''}", style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),),
                ),
                Expanded(child: Divider())
              ]
            ).animate().fade()
          ),
      ],
    );
  }
}