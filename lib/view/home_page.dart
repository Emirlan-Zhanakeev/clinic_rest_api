import 'dart:convert';

import 'package:clinic_rest/view/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        centerTitle: true,
        title: const Text(
          'List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToListPage, label: const Text('Add')),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetch,
          child: Visibility(
            visible: doctors.isNotEmpty,
            replacement: Center(
              child: Text('List is Empty', style: Theme.of(context).textTheme.headlineLarge,),
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
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      subtitle: Text(docs['birthday'].toString()),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            navigateToEditPage(docs);

                            ///open edit page
                          } else if (value == 'delete') {
                            ///delete doc
                            deleteById(id);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
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
    final url = 'http://10.0.2.2:8080/clinic/api/doctor/delete/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      ///Remove doc from the List
      final filtered = doctors.where((element) => element['id'] != id).toList();
      setState(() {
        doctors = filtered;
      });
      // showSuccessMessage('Deletion Success');
    } else {
      ///Show error
      showErrorMessage('Deletion Filed');
    }
  }

  Future<void> fetch() async {
    const url = 'http://10.0.2.2:8080/clinic/api/doctor/all';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        doctors = json;
      });
    }

    setState(() {
      isLoading = false;
    });
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
