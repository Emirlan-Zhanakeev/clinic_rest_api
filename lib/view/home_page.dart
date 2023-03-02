import 'dart:convert';
// ignore_for_file: avoid_print

import 'package:clinic_rest/services/doctor_service.dart';
import 'package:clinic_rest/view/add_page.dart';
import 'package:clinic_rest/view/patients_page.dart';
import 'package:clinic_rest/view/records_page.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List doctors = [];

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over_sharp),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecordsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.perm_contact_calendar_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PatientsPage(),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToListPage,
        label: const Text('Add'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetch,
          child: Visibility(
            visible: doctors.isNotEmpty,
            replacement: Center(
              child: Text(
                'List is Empty',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            child: ListView.builder(
                itemCount: doctors.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final docs = doctors[index] as Map;
                  final id = docs['id'].toString();
                  return Card(
                    child: ListTile(
                      title: Text('${docs['name']}  ${docs['surname']}'),
                      leading: CircleAvatar(child: Text('${docs['id']}')),
                      subtitle: Text(docs['birthday'].toString()),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            navigateToEditPage(docs);

                            ///open edit page
                          } else if (value == 'delete') {
                            ///delete doc
                            showDialog(
                                context: context,
                                builder: (builder) {
                                  return showAlertDialog(id);
                                });
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit doctor'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete doctor'),
                            )
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> navigateToEditPage(Map docs) async {
    final route = MaterialPageRoute(builder: (context) => AddPage(todo: docs));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetch();
  }

  Future<void> navigateToListPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetch();
  }

  Future<void> deleteById(String id) async {
    ///Delete the doc
    final isSuccess = await DoctorsService.deleteById(id);
    if (isSuccess) {
      ///Remove doc from the List
      final filtered = doctors.where((element) => element['id'] != id).toList();
      setState(() {
        doctors = filtered;
      });
      fetch();
    } else {
      ///Show error
      showErrorMessage(context, message: 'Something wrong');
    }
  }

  Future<void> fetch() async {
    final response = await DoctorsService.fetchDoctors();

    if (response != null) {
      setState(() {
        doctors = response;
      });
    } else {
      showErrorMessage(context, message: 'Something wrong');
    }

    setState(() {
      isLoading = false;
    });
  }

  AlertDialog showAlertDialog(id) {
    return AlertDialog(
      title: const Text('Delete?'),
      content: const Text('The content will be deleted forever'),
      actions: [
        ElevatedButton(
          onPressed: () {
            deleteById(id);
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
