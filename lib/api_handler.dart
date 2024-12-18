import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/model.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as httpimp;

class ApiHandler{

  late String baseUri = "";
  final ioc = HttpClient();

  Future<List<User>> getUserData() async{
    
    checkPlatform();
    List<User> data = [];
    final uri = Uri.parse(baseUri);
    final http = IOClient(ioc);

    try{          
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type' : 'application/json; charset=UTF-8'
        },
      );
      if(response.statusCode >= 200 && response.statusCode <= 299){
        final List<dynamic> jsonData = json.decode(response.body);
        data = jsonData.map((json) => User.fromJson(json)).toList();
      }
    }catch(e){
      return data;
    }
    return data;
  }

  Future<httpimp.Response> updateUser({required int id, required User user}) async {
    
    checkPlatform();    
    final uri = Uri.parse("$baseUri/$id");
    final http = IOClient(ioc);
    late httpimp.Response response;

    try{
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(user),
      );
    }catch(e){
      return response;
    }
    return response;
  }

  Future<httpimp.Response> addUser({required User user}) async {
    
    checkPlatform(); 
    final uri = Uri.parse(baseUri);
    final http = IOClient(ioc);
    late httpimp.Response response;

    try{
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(user),
      );
    }catch(e){
      print(e);
    }
    return response;
  }

  Future<httpimp.Response> deleteUser({required int id}) async {
    
    checkPlatform();
    final uri = Uri.parse("$baseUri/$id");
    final http = IOClient(ioc);
    late httpimp.Response response;

    try{
      response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );
    }catch(e){
      return response;
    }
    return response;
  }

  Future<User> getUserbyId({required int id}) async {
    
    checkPlatform();
    final uri = Uri.parse("$baseUri/$id");
    final http = IOClient(ioc);
    User? user;
    
    try{
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type' : 'application/json; charset=UTF-8',
        },
      );
      if(response.statusCode >= 200 && response.statusCode <= 299){
        final Map<String, dynamic> jsonData = json.decode(response.body);
        user = User.fromJson(jsonData);
      }}catch(e){
        return user!;
      }    
      return user!;
  }

  Future<bool> userExists({required int id}) async {

    checkPlatform();
    final uri = Uri.parse("$baseUri/$id");
    final http = IOClient(ioc);
    
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-type' : 'application/json; charset=UTF-8',
      },
    );
    if(response.statusCode >= 200 && response.statusCode <= 299){
      return true;
    }else{
      return false;
    }
  }

  void checkPlatform(){
    if(Platform.isAndroid){
      baseUri = "https://192.168.1.47:5001/api/Users";
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    }else if(Platform.isWindows){
      baseUri = "https://localhost:5001/api/Users";
    }
  }
}