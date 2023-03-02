import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore_for_file: avoid_print
import '../utils/snackbar_helper.dart';

class AddRecord extends StatefulWidget {
  final Map? todo;

  const AddRecord({Key? key, this.todo}) : super(key: key);

  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  TextEditingController doctorIdController = TextEditingController();
  TextEditingController patientIdController = TextEditingController();
  TextEditingController appointmentTimeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController conclusionController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  bool isEdit = false;
  List records = [];
  String? recValue;

  ///GET
  Future<void> fetchRecords() async {
    const url = 'http://10.0.2.2:8080/clinic/api/record/all';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      records = json;
      // print(response.body);
    } else {
      showErrorMessage(context, message: 'Something wrong');
      print(response.statusCode);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecords();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final patient = todo['patient_id'].toString();
      final doctor = todo['doctorId'].toString();
      final appointmentTime = todo['appointmentTime'];
      final description = todo['description'];
      final conclusion = todo['conclusion'];
      final status = todo['status'];


      patientIdController.text = patient;
      doctorIdController.text = doctor;
      appointmentTimeController.text = appointmentTime;
      descriptionController.text = description;
      conclusionController.text = conclusion;
      statusController.text = status;

    }
  }

  Future<void> submitRecord() async {
    final patientId = patientIdController.text;
    final doctorId = doctorIdController.text;
    final appointmentTime = appointmentTimeController.text;
    final description = descriptionController.text;
    final conclusion = conclusionController.text;
    final status = statusController.text;

    final body = {
      "patient_id": patientId,
      "doctorId": doctorId,
      "appointmentTime": "2023-02-24T09:26:19.695Z",
      "description": description,
      "conclusion": conclusion,
      "status": status
    };

    final url = 'http://10.0.2.2:8080/clinic/api/record/save';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print('Success');
      showSuccessMessage(context, message: 'Creation Success');
      Navigator.pop(context);
    } else {
      showErrorMessage(context, message: 'Creation Failed');
    }
  }

  Future<void> updateRecord() async {

    final todo = widget.todo;
    if(todo == null) {
      print('you can call update without todo data');
      return;
    }
    final id = todo['id'];
    final patientId = patientIdController.text;
    final doctorId = doctorIdController.text;
    final appointmentTime = appointmentTimeController.text;
    final description = descriptionController.text;
    final conclusion = conclusionController.text;
    final status = statusController.text;

    final body = {
      "patient_id": patientId,
      "doctorId": doctorId,
      "appointmentTime": "2023-02-24T09:26:19.695Z",
      "description": description,
      "conclusion": conclusion,
      "status": status
    };


    final url = 'http://10.0.2.2:8080/clinic/api/record/update/4';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print('Success');
      showSuccessMessage(context, message: 'Updation Success');
      Navigator.pop(context);
    } else {
      showErrorMessage(context, message: 'Updation Failed');
    }
fetchRecords();
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit Record' : 'Add Record',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: [
              TextField(
                controller: patientIdController,
                decoration: const InputDecoration(
                  hintText: 'patient id',
                ),
                // keyboardType: TextInputType.number,
              ),
              TextField(
                controller: doctorIdController,
                decoration: const InputDecoration(
                  hintText: 'doctor id',
                ),
                // keyboardType: TextInputType.number,
              ),
              TextField(
                controller: appointmentTimeController,
                decoration: const InputDecoration(
                  hintText: 'appointment time',
                  icon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2025));
                  if (pickedDate != null) {
                    setState(() {
                      appointmentTimeController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'description',
                ),
              ),
              TextField(
                controller: conclusionController,
                decoration: const InputDecoration(
                  hintText: 'conclusion',
                ),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(
                  hintText: 'status',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isEdit ? updateRecord : submitRecord,
                child: Text(
                  isEdit ? 'Update Data' : 'Submit data',
                ),
              )
            ],
          ),
        ),
      );
    }
  }
