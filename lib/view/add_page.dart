import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        ));
  }

  void updateData() async {
    ///Get the data from form
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call updated without todo data');
      return;
    }
    final id = todo['id'];
    final name = nameController.text;
    final surname = surnameController.text;
    final birthday = birthdayController.text;
    final speciality = specialityController.text;

    final body = {
      "name": name,
      "surname": surname,
      "birthday": birthday,
      "speciality": speciality
    };
    // http://localhost:8080/clinic/api/doctor/update/45
    final url = 'http://10.0.2.2:8080/clinic/api/doctor/update/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    ///Show success
    if (response.statusCode == 200) {
      nameController.text = '';
      surnameController.text = '';
      birthdayController.text = '';
      specialityController.text = '';
      showSuccessMessage('Updation Success');
    } else {
      showErrorMessage('Updation Failed');
    }


  }

  void submitData() async {
    ///Get the data from form
    final name = nameController.text;
    final surname = surnameController.text;
    final birthday = birthdayController.text;
    final speciality = specialityController.text;

    final body = {
      "name": name,
      "surname": surname,
      "birthday": birthday,
      "speciality": speciality
    };

    ///Submit data to server
    final url = 'http://10.0.2.2:8080/clinic/api/doctor/save';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    ///Show success
    if (response.statusCode == 200) {
      nameController.text = '';
      surnameController.text = '';
      birthdayController.text = '';
      specialityController.text = '';
      showSuccessMessage('Creation Success');
    } else {
      showErrorMessage('Creation Failed');
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
}
