import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PatientsPage extends StatefulWidget {
  const PatientsPage({Key? key}) : super(key: key);

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {


  List patients = [];


  @override
  void initState() {
    fetch();
    super.initState();
  }

///Get all
  Future<void> fetch() async {
    const url = 'http://10.0.2.2:8080/clinic/api/patient/all';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        patients = json;
      });
      print('Success');
    }
  }

  ///POST

///clinic/api/patient/save





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
          onPressed: (){}, label: const Text('Add a Patient')),
      body: ListView.builder(
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
                    } else if (value == 'delete') {
                      ///delete doc
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


}
