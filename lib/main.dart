import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Timetable',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TimetableScreen(),
    );
  }
}


class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<dynamic> rooms = [];
  List<dynamic> teachers = [];
  List<dynamic> subjects = [];
  List<dynamic> sessions = [];

  // Variables pour le formulaire
  String? selectedSubject;
  String? selectedTeacher;
  String? selectedRoom;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    loadTimetableData();
  }

  Future<void> loadTimetableData() async {
    final String response = await rootBundle.loadString('assets/timetable.json');
    final data = await json.decode(response);

    setState(() {
      rooms = data['rooms'];
      teachers = data['teachers'];
      subjects = data['subjects'];
      sessions = data['sessions'];
    });
  }

  void addSession() {
    if (selectedSubject != null && selectedTeacher != null && selectedRoom != null && startTime != null && endTime != null) {
      setState(() {
        sessions.add({
          'session_id': 'SS${sessions.length + 1}', // Génération d'un ID unique
          'subject_id': selectedSubject,
          'teacher_id': selectedTeacher,
          'room_id': selectedRoom,
          'session_date': DateTime.now().toIso8601String().split('T')[0], // Date actuelle au format YYYY-MM-DD
          'start_time': startTime!.format(context),
          'end_time': endTime!.format(context),
        });
      });
      Navigator.pop(context); // Ferme le formulaire
    }
  }

  // Affichage du formulaire
  void showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  hint: Text('Sélectionnez une matière'),
                  value: selectedSubject,
                  onChanged: (newValue) {
                    setState(() {
                      selectedSubject = newValue;
                    });
                  },
                  items: subjects.map<DropdownMenuItem<String>>((subject) {
                    return DropdownMenuItem<String>(
                      value: subject['subject_id'],
                      child: Text(subject['subject_name']),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: Text('Sélectionnez un enseignant'),
                  value: selectedTeacher,
                  onChanged: (newValue) {
                    setState(() {
                      selectedTeacher = newValue;
                    });
                  },
                  items: teachers.map<DropdownMenuItem<String>>((teacher) {
                    return DropdownMenuItem<String>(
                      value: teacher['teacher_id'],
                      child: Text('${teacher['first_name']} ${teacher['last_name']}'),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: Text('Sélectionnez une salle'),
                  value: selectedRoom,
                  onChanged: (newValue) {
                    setState(() {
                      selectedRoom = newValue;
                    });
                  },
                  items: rooms.map<DropdownMenuItem<String>>((room) {
                    return DropdownMenuItem<String>(
                      value: room['room_id'],
                      child: Text(room['room_name']),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () async {
                    startTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  },
                  child: Text('Choisir Heure de Début'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    endTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  },
                  child: Text('Choisir Heure de Fin'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: addSession,
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('School Timetable'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddSessionDialog, // Ouvrir le formulaire
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Matière')),
                  DataColumn(label: Text('Enseignant')),
                  DataColumn(label: Text('Salle')),
                  DataColumn(label: Text('Heure')),
                ],
                rows: sessions.map((session) {
                  return DataRow(cells: [
                    DataCell(Text(subjects.firstWhere((subject) => subject['subject_id'] == session['subject_id'])['subject_name'])),
                    DataCell(Text(teachers.firstWhere((teacher) => teacher['teacher_id'] == session['teacher_id'])['first_name'] + ' ' + teachers.firstWhere((teacher) => teacher['teacher_id'] == session['teacher_id'])['last_name'])),
                    DataCell(Text(rooms.firstWhere((room) => room['room_id'] == session['room_id'])['room_name'])),
                    DataCell(Text('${session['start_time']} - ${session['end_time']}')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}