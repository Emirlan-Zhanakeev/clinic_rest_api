import 'package:clinic_rest/utils/snackbar_helper.dart';
import 'package:clinic_rest/view/add_record.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore_for_file: avoid_print

class RecordsPage extends StatefulWidget {
  const RecordsPage({Key? key}) : super(key: key);

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List records = [];
  bool isLoading = true;

  ///GET
  Future<void> fetchRecords() async {
    const url = 'http://10.0.2.2:8080/clinic/api/record/all';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      records = json;
    } else {
      showErrorMessage(context, message: 'Something wrong');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> navigateToAddRecordPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddRecord());
    await Navigator.push(context, route);
  }

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddRecordPage,
        label: const Text('Add record'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchRecords,
          child: Visibility(
            visible: records.isNotEmpty,
            replacement: Center(
              child: Text(
                'List is Empty',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            child: ListView.builder(
                itemCount: records.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final record = records[index] as Map;
                  final id = record['id'].toString();
                  return Card(
                    child: ListTile(
                      title: Text(
                          'Patient: ${record['patient']['name']} \nDoctor: ${record['doctor']['name']}'),
                      leading: CircleAvatar(child: Text('${record['id']}')),
                      subtitle: Text(
                        record['appointmentTime'].toString(),
                        style: const TextStyle(fontSize: 15),
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            // navigateToEditPage(docs);

                            ///open edit page
                          } else if (value == 'delete') {
                            ///delete doc
                            // showDialog(
                            //     context: context,
                            //     builder: (builder) {
                            //       return showAlertDialog(id);
                            //     });
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
                            ),
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

/*
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
*/
}
