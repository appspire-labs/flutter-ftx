import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  late int code;
  late String? error;
  late T? data;
  ApiResponse({required this.code, this.error, this.data});
}

class HttpX {
  HttpX._privateConstructor();
  static final HttpX instance = HttpX._privateConstructor();
  late String baseUrl;
  late Function token;
}

extension Http on String {

  Future<ApiResponse<T>> httpGet<T>(
      {required Function fromJson, bool isAuth = true}) async {
    var url = Uri.parse("${HttpX.instance.baseUrl}/$this");
    try {
      http.Response response = await http.get(url, headers: {
        if (isAuth) "Authorization": "Bearer " + await HttpX.instance.token(),
        "content-type": "application/json"
      });
      return ApiResponse<T>(
          code: response.statusCode,
          data: fromJson(jsonDecode(response.body)),
          error: null);
    } catch (error) {
      print("error" + error.toString());
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

  Future<ApiResponse<T>> httpPost<T>(
      {body, required Function fromJson, bool isAuth = true}) async {
    var url = Uri.parse(this);
    try {
      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: {
        if (isAuth) "Authorization": "Bearer " + await HttpX.instance.token(),
        "content-type": "application/json"
      });
      print("response: " + response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: fromJson(jsonDecode(response.body)),
          error: null);
    } catch (error) {
      print("error" + error.toString());
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

  Future<ApiResponse<T>> httpMultiPart<T>(
      {body, required Function fromJson,List<http.MultipartFile>? files,Map<String,String>? fields, bool isAuth = true}) async {
    var url = Uri.parse(this);
    var request = http.MultipartRequest("POST", url)
      ..headers.addAll({
        if(isAuth) "Authorization": "Bearer " + await HttpX.instance.token(),
        "content-type": "multipart/form-data"
      });
    if(files!=null)request.files.addAll(files);
    if(fields!=null)request.fields.addAll(fields);

    try {
      http.Response response = await http.Response.fromStream(await request.send());
      return ApiResponse<T>(
          code: response.statusCode,
          data: fromJson(jsonDecode(response.body)),
          error: null);
    } catch (error) {
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

  Future<ApiResponse<T>> httpPut<T>(
      {body, required Function fromJson, bool isAuth = true}) async {
    var url = Uri.parse(this);
    try {
      http.Response response =
          await http.put(url, body: jsonEncode(body), headers: {
        if (isAuth) "Authorization": "Bearer " + await HttpX.instance.token(),
        "content-type": "application/json"
      });
      print("response: " + response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: fromJson(jsonDecode(response.body)),
          error: null);
    } catch (error) {
      print("error" + error.toString());
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

  Future<ApiResponse<T>> httpDelete<T>(
      {body, required Function fromJson, bool isAuth = true}) async {
    var url = Uri.parse(this);
    try {
      http.Response response =
          await http.delete(url, body: jsonEncode(body), headers: {
        if (isAuth) "Authorization": "Bearer " + await HttpX.instance.token(),
        "content-type": "application/json"
      });
      print("response: " + response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: fromJson(jsonDecode(response.body)),
          error: null);
    } catch (error) {
      print("error" + error.toString());
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

}
