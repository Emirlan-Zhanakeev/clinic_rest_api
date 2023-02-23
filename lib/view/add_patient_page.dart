import 'dart:convert';
import 'package:clinic_rest/services/patient_services.dart';
import 'package:clinic_rest/utils/snackbar_helper.dart';
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



///POST data
  void submitPatientData() async {
    ///Get the data from form

    ///Submit data to server

    final isSuccess = await PatientService.createData(body);

    ///Show success
    if (isSuccess) {
      patientNameController.text = '';
      patientSurnameController.text = '';
      patientBirthdayController.text = '';
      showSuccessMessage(context, message: 'Creation Success');
    } else {
      showErrorMessage(context, message: 'Creation Failed');
    }
    Navigator.pop(context);

  }


  void updatePatientData() async {
    ///Get the data from form
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call updated without todo data');
      return;
    }
    final id = todo['id'].toString();

    final isSuccess = await PatientService.updateData(id, body);

    ///Show success
    if (isSuccess) {
      showSuccessMessage(context, message: 'Updation Success');
    } else {
      showErrorMessage(context, message: 'Updation Failed');
    }
    Navigator.pop(context);
  }


  Map get body {
    final name = patientNameController.text;
    final surname = patientSurnameController.text;
    final birthday = patientBirthdayController.text;

    return {
      "name": name,
      "surname": surname,
      "birthday": birthday,
    };
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
