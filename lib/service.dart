import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
// import 'dart:developer';

import 'package:http/http.dart' as http;

enum RequestType {get, post, put, head, delete, patch}
const List<String> requestMethods = [ 'GET', 'POST', 'PUT', 'HEAD', 'DELETE', 'PATCH'];

enum RequestBodyType {json, text, formData}
const List<String> requestBodyTypes = ['JSON', 'TEXT', 'FORM-DATA'];

enum ResponseType {
  text('TEXT'),
  json('JSON'),
  html('HTML');

  final String name;
  const ResponseType(this.name);
}

const List<Color> colors = [
  Color(0xFFBBFFBB),
  Color(0xFFFFFF88),
  Color(0xFFBBBBFF),
  Color(0xFFAADDFF),
  Color(0xFFFFBBBB),
  Color(0xFFBBBB88)
];

class Service{

  final RequestType reqMethod;
  final String url;
  final Map<String, String>? headers;
  final Map<String, dynamic>? jsonBody;
  final String? textBody;
  final Map<String,String>? files;

  Service({required this.reqMethod, required this.url, this.headers, this.jsonBody, this.textBody, this.files});

  Future<http.Response?> getRequest() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.get(
        Uri.parse(url),
        headers: headers
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > getRequest() >> $e');
    }
    throw Exception(err);
  }

  Future<http.Response?> postRequest() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(jsonBody)
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > postRequest() >> $e');
    }
    throw Exception(err);
  }

  Future<http.Response?> putRequest() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(jsonBody)
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > putRequest() >> $e');
    }
    throw Exception('ERROR: $err');
  }

  Future<http.Response?> headRequest() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.head(
          Uri.parse(url),
          headers: headers
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > headRequest() >> $e');
    }
    throw Exception('ERROR: $err');
  }

  Future<http.Response?> deleteRequest() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(jsonBody)
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > deleteRequest() >> $e');
    }
    throw Exception('ERROR: $err');
  }

  Future<http.Response?> patchRequest() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.patch(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(jsonBody)
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > postRequest() >> $e');
    }
    throw Exception(err);
  }

  //=============================================================================================
  //FORM DATA METHODS

  Future<http.Response?> formDataRequest() async {
    
    http.MultipartRequest request = http.MultipartRequest(requestMethods[reqMethod.index], Uri.parse(url));

    if (jsonBody != null && jsonBody!.isNotEmpty){
      for (MapEntry field in jsonBody!.entries){
        request.fields[field.key]= field.value;
      }
    }

    if (files != null && files!.isNotEmpty) {
      for (MapEntry file in files!.entries){
        request.files.add(
          await http.MultipartFile.fromPath(file.key, file.value,)// filename: file.value.split('/').last)
        );
      }
    }

    if (headers != null){
      request.headers.addAll(headers!);
    }

    http.Response? response;
    
    try {
      await request.send().then((fileUploadResponse) async {
        response = await http.Response.fromStream(fileUploadResponse);
      });
      return response;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  //=======================================================================================================================
  //TEXT BODY METHODS

  Future<http.Response?> postRequestTextBody() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.post(
          Uri.parse(url),
          headers: headers,
          body: textBody
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > postRequest() >> $e');
    }
    throw Exception(err);
  }

  Future<http.Response?> putRequestTextBody() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.put(
          Uri.parse(url),
          headers: headers,
          body: textBody,
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > putRequest() >> $e');
    }
    throw Exception('ERROR: $err');
  }

  Future<http.Response?> deleteRequestTextBody() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.delete(
          Uri.parse(url),
          headers: headers,
          body: textBody,
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > deleteRequest() >> $e');
    }
    throw Exception('ERROR: $err');
  }

  Future<http.Response?> patchRequestTextBody() async {
    http.Response? res;
    String err = '';
    try{
      res = await http.patch(
          Uri.parse(url),
          headers: headers,
          body: textBody,
      );
      return res;
    }
    catch(e){
      err = e.toString();
      // log('Exception at service.dart > postRequest() >> $e');
    }
    throw Exception(err);
  }
}