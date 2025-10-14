import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final BACKEND_URL = "http://handasaim.theannoying.dev";

class ScheduleEntry {
  final List<String> hours;
  final List<String> subjects;
  final List<String> teachers;

  const ScheduleEntry({
    required this.hours,
    required this.subjects,
    required this.teachers,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      hours: List<String>.from(json['hours'] as List<dynamic>),
      subjects: List<String>.from(json['subjects'] as List<dynamic>),
      teachers: List<String>.from(json['teachers'] as List<dynamic>),
    );
  }
}

class Schedule {
  final List<ScheduleEntry> entries;

  const Schedule({required this.entries});

  factory Schedule.fromJson(List<dynamic> jsonList) {
    final entries = jsonList
        .map((entryJson) => ScheduleEntry.fromJson(entryJson))
        .toList();
    return Schedule(entries: entries);
  }
}

class Data {
  static Future<Schedule> fetchSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response =
        await http.get(Uri.parse('$BACKEND_URL/api/schedule/${prefs.getString('className') ?? 'ז 1'}'));

    if (response.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(response.body) as List<dynamic>);
    } else {
      throw Exception("Failed to load schedule.");
    }
  }

  static Future<List<String>> fetchClassNames() async {
    final response = await http.get(Uri.parse('$BACKEND_URL/api/classes'));

    if(response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load schedule.");
    }
  }

  static Future<Schedule> get schedule => fetchSchedule();
  static Future<List<String>> get classNames => fetchClassNames();
}