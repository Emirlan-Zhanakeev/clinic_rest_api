import 'dart:convert';

import 'package:clinic_rest/services/doctor_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/snackbar_helper.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;

  const AddPage({Key? key, this.todo}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController specialityController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {

    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final name = todo!['name'];
      final surname = todo['surname'];
      final birthday = todo['birthday'];
      final speciality = todo['speciality'];
      nameController.text = name;
      surnameController.text = surname;
      birthdayController.text = birthday;
      specialityController.text = speciality;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit' : 'Add',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'name',
              ),
            ),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(
                hintText: 'surname',
              ),
            ),
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(
                hintText: 'Birthday',
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
                    birthdayController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: specialityController,
              decoration: const InputDecoration(
                hintText: 'speciality',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              child: Text(
                isEdit ? 'Update' : 'Submit',
              ),
            )
          ],
        ),
      ),
    );
  }

  void updateData() async {
    ///Get the data from form
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call updated without todo data');
      return;
    }
    final id = todo['id'].toString();
    final isSuccess = await DoctorsService.updateData(id, body);

    ///Show success
    if (isSuccess) {
      showSuccessMessage(context, message:'Updation Success');
    } else {
      showErrorMessage(context, message: 'Updation Failed');    }
    Navigator.pop(context);

  }

  void submitData() async {
    ///Submit data to server

    final isSuccess = await DoctorsService.createData(body);

    ///Show success
    if (isSuccess) {
      nameController.text = '';
      surnameController.text = '';
      birthdayController.text = '';
      specialityController.text = '';
      showSuccessMessage(context, message:'Creation Success');
    } else {
      showErrorMessage(context, message: 'Creation Failed');
    }
    Navigator.pop(context);
  }

  Map get body {
    ///Get the data from form
    final name = nameController.text;
    final surname = surnameController.text;
    final birthday = birthdayController.text;
    final speciality = specialityController.text;

    return {
      "name": name,
      "surname": surname,
      "birthday": birthday,
      "speciality": speciality
    };
  }

}
