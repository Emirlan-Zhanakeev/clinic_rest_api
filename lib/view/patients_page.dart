import 'dart:convert';

import 'package:clinic_rest/view/add_patient_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientsPage extends StatefulWidget {
  const PatientsPage({Key? key}) : super(key: key);

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  List patients = [];
  bool isLoading = true;

  @override
  void initState() {
    fetchPatient();
    super.initState();
  }

  ///Get all data
  Future<void> fetchPatient() async {
    const url = 'http://10.0.2.2:8080/clinic/api/patient/all';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        patients = json;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deletePats(id) async {
    ///Delete the doc
    final url = 'http://10.0.2.2:8080/clinic/api/patient/delete/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      ///Remove doc from the List
      final filtered =
      patients.where((element) => element['id'] != id).toList();
      setState(() {
        patients = filtered;
      });
      fetchPatient();
      // showSuccessMessage('Deletion Success');
    } else {
      ///Show error
      showErrorMessage('Deletion Filed');
    }
  }

  Future<void> navigationToPatientEdit(Map pats) async {
    final route =
        MaterialPageRoute(builder: (context) => PatientAddPage(todo: pats));
    await Navigator.push(context, route);

    setState(() {
      isLoading = true;
    });
    fetchPatient();
  }

  Future<void> navigationToPatientAdd() async {
    final route =
        MaterialPageRoute(builder: (context) => const PatientAddPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchPatient();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'List of patients',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigationToPatientAdd();
          },
          label: const Text('Add a Patient')),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchPatient,
          child: ListView.builder(
              itemCount: patients.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final pats = patients[index] as Map;
                final id = pats['id'].toString();
                return Card(
                  child: ListTile(
                    title: Text('${pats['name']}  ${pats['surname']}'),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    subtitle: Text(pats['birthday'].toString()),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          ///open edit page
                          navigationToPatientEdit(pats);
                        } else if (value == 'delete') {
                          ///delete pats
                          showDialog(context: context, builder: (builder) {
                          return ShowAlertDialog(id);
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit patient'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete patient'),
                          )
                        ];
                      },
                    ),
                  ),
                );
              }),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
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

  AlertDialog ShowAlertDialog(id) {
    return AlertDialog(
      title: const Text('Delete?'),
      content: const Text(
          'The content will be deleted forever'),
      actions: [
        ElevatedButton(
          onPressed: ()  {
            deletePats(id);
             Navigator.pop(context);
          },
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
      ],
    );
  }



}
