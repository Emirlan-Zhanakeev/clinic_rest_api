import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientAddPage extends StatefulWidget {

final Map? todo;
  const PatientAddPage({Key? key, this.todo}) : super(key: key);

  @override
  State<PatientAddPage> createState() => _PatientAddPageState();
}

class _PatientAddPageState extends State<PatientAddPage> {


  TextEditingController patientNameController = TextEditingController();
  TextEditingController patientSurnameController = TextEditingController();
  TextEditingController patientBirthdayController = TextEditingController();

bool isEditPatient = false;


  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEditPatient = true;
      final name = todo!['name'];
      final surname = todo['surname'];
      final birthday = todo['birthday'];
      patientNameController.text = name;
      patientSurnameController.text = surname;
      patientBirthdayController.text = birthday;
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

///POST data
  void submitPatientData() async {
    ///Get the data from form
    final name = patientNameController.text;
    final surname = patientSurnameController.text;
    final birthday = patientBirthdayController.text;

    final body = {
      "name": name,
      "surname": surname,
      "birthday": birthday,
    };

    ///Submit data to server
    final url = 'http://10.0.2.2:8080/clinic/api/patient/save';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    ///Show success
    if (response.statusCode == 200) {
      patientNameController.text = '';
      patientSurnameController.text = '';
      patientBirthdayController.text = '';
      showSuccessMessage('Creation Success');
    } else {
      showErrorMessage('Creation Failed');
    }
  }

///PUT


  void updatePatientData() async {
    ///Get the data from form
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call updated without todo data');
      return;
    }
    final id = todo['id'];
    final name = patientNameController.text;
    final surname = patientSurnameController.text;
    final birthday = patientBirthdayController.text;

    final body = {
      "name": name,
      "surname": surname,
      "birthday": birthday,
    };
    // http://localhost:8080/clinic/api/doctor/update/45
    final url = 'http://10.0.2.2:8080/clinic/api/patient/update/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    ///Show success
    if (response.statusCode == 200) {
      showSuccessMessage('Updation Success');
    } else {
      showErrorMessage('Updation Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditPatient ? 'Edit Patient' : 'Add',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextField(
              controller: patientNameController,
              decoration: const InputDecoration(
                hintText: 'name',
              ),
            ),
            TextField(
              controller: patientSurnameController,
              decoration: const InputDecoration(
                hintText: 'surname',
              ),
            ),
            TextField(
              controller: patientBirthdayController,
              decoration: const InputDecoration(
                hintText: 'birthday',
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
                    patientBirthdayController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isEditPatient ? updatePatientData : submitPatientData,
              child: Text(
                isEditPatient ? 'Update Data' : 'Submit data',),
            )
          ],
        ),
      ),
    );
  }
}
