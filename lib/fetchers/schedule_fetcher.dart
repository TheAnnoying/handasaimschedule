import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

final SHEETS_URL = "https://docs.google.com/spreadsheets/d/1KChK1mc1hoO8Okm0uJPuehrWYtetqvq4/export?format=zip";

class Lesson {
  final List<String> subjects;
  final List<String> hours;
  final List<String> teachers;

  Lesson({
    required this.subjects,
    required this.hours,
    required this.teachers,
  });
}

class ClassSchedule {
  final String name;
  final List<Lesson> lessons = [];

  ClassSchedule(this.name);

  void addLesson(Lesson lesson) {
    lessons.add(lesson);
  }
}

class Schedule {
  final List<ClassSchedule> _classes = [];
  String day = "יום לא ידוע";

  void addClass(String name) {
    _classes.add(ClassSchedule(name));
  }

  void addLessonToClass(String className, Lesson lesson) {
    final classSchedule = _classes.firstWhere((c) => c.name == className, orElse: () => throw Exception("Class $className not found"));
    classSchedule.addLesson(lesson);
  }

  ClassSchedule? getClass(String name) {
    return _classes.firstWhere((c) => c.name == name);
  }

  List<String> getClasses() {
    return _classes.map((c) => c.name).toList();
  }

}

class ScheduleRepository {
  Future<String> downloadAndExtractHtml(String url) async {
    final response = await http.get(Uri.parse(url));
    if(response.statusCode != 200) {
      throw Exception('Failed to download spreadsheet');
    }

    final bytes = response.bodyBytes;
    final archive = ZipDecoder().decodeBytes(bytes);
    
    for (final file in archive) {
      if(file.isFile && file.name.endsWith('html')) {
        final content = file.content as List<int>;
        return utf8.decode(content);
      }
    }

    throw Exception('No HTML file found in archive');
  }

  Future<Schedule> fetchSchedule() async {
      final htmlData = await downloadAndExtractHtml(SHEETS_URL);
      final document = html_parser.parse(htmlData);
      final Schedule output = Schedule();

      bool currentDayFound = false;

      document.querySelectorAll('thead, th').forEach((e) => e.remove());
      document.querySelectorAll('tr').forEach((row) {
        final cells = row.children;
        if (cells.isEmpty) return;
        final first = cells.first.text.trim();
        final second = cells.length > 1 ? cells[1].text.trim() : '';
        
        if(first.isNotEmpty && second.isEmpty && !currentDayFound) {
          output.day = first.replaceAll(RegExp(r'[\d\.,]'), '').replaceFirst("חתך כיתות", "מערכת הנדסאים");
          currentDayFound = true;
        }

        if (first.isEmpty && second.isEmpty) {
          row.remove();
        } else if (first.isEmpty && second.isNotEmpty) {
          // remove previous rows
          var prev = row.previousElementSibling;
          while (prev != null) {
            prev.remove();
            prev = row.previousElementSibling;
          }
        }
      });

      final rows = document.querySelectorAll('tr');

      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        final cells = rows[rowIndex].children;
        for (int colIndex = 0; colIndex < cells.length; colIndex++) {
          final cellHtml = cells[colIndex].innerHtml.trim().replaceAll(RegExp(r'^<br>|<br>$'), '');
          if (rowIndex == 0 && cellHtml.isNotEmpty) {
            output.addClass(cellHtml);
          } else {
            final keys = output.getClasses();
            if (colIndex - 1 < 0 || colIndex - 1 >= keys.length) continue;
            final index = keys[colIndex - 1];

            if(index.isNotEmpty && cellHtml.isNotEmpty) {
              final hours = cells.first.innerHtml.trim().split('<br>');
              final parts = cellHtml.split('<br>').toList();
              final teachers = [for (int i = 0; i < parts.length; i += 2) parts[i]];
              final subjects = [for (int i = 1; i < parts.length; i += 2) parts[i]];
              
              output.addLessonToClass(index, Lesson(
                hours: [hours.first, hours.skip(1).join(' - ')],
                subjects: subjects,
                teachers: teachers
              ));
            }
          }
        }
      }

      return output;
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, AsyncValue<Schedule>>(ScheduleNotifier.new);

class ScheduleNotifier extends Notifier<AsyncValue<Schedule>> {
  late ScheduleRepository _repo;
  Timer? _timer;

  @override
  AsyncValue<Schedule> build() {
    _repo = ScheduleRepository();
    _startAutoRefresh();
    _loadInitial();
    return const AsyncValue.loading();
  }

  Future<void> _loadInitial() async {
    try {
      final data = await _repo.fetchSchedule();
      state = AsyncValue.data(data);
    } catch (_) {
      state = const AsyncValue.error('Failed to load data', StackTrace.empty);
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: 10), (_) => _refresh());
    ref.onDispose(() => _timer?.cancel());
  }

  Future<void> _refresh() async {
    try {
      final newData = await _repo.fetchSchedule();
      state = AsyncValue.data(newData);
    } catch (_) {}
  }
}