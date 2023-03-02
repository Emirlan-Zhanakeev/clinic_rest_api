 ///All API call here
 import 'dart:convert';
 // ignore_for_file: avoid_print

import 'package:http/http.dart' as http;

 class DoctorsService {
   static Future<bool> deleteById(String id) async {
     ///Delete the doc
     final url = 'http://10.0.2.2:8080/clinic/api/doctor/delete/$id';
     final uri = Uri.parse(url);
     final response = await http.delete(uri);
     return response.statusCode == 200;
   }

   static Future<List?> fetchDoctors() async {
     const url = 'http://10.0.2.2:8080/clinic/api/doctor/all';
     final uri = Uri.parse(url);
     final response = await http.get(uri);
     if (response.statusCode == 200) {
       final json = jsonDecode(response.body) as List;
       return json;
     } else {
       return null;
     }
    }

   static Future<bool> updateData(String id, Map body) async {
     final url = 'http://10.0.2.2:8080/clinic/api/doctor/update/$id';
     final uri = Uri.parse(url);
     final response = await http.put(
       uri,
       body: jsonEncode(body),
       headers: {'Content-Type': 'application/json'},
     );
   return response.statusCode == 200;
   }

   static Future<bool> createData(Map body) async {
     final url = 'http://10.0.2.2:8080/clinic/api/doctor/save';
     final uri = Uri.parse(url);
     final response = await http.post(
       uri,
       body: jsonEncode(body),
       headers: {'Content-Type': 'application/json'},
     );
     return response.statusCode == 200;

   }

 }





