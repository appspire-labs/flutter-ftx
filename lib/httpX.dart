import 'dart:convert';
import 'dart:io';
import 'package:flutter_uploader/flutter_uploader.dart';
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
  late String headerName;
}

extension Http on String {

  Future<ApiResponse<T>> httpGet<T>(
      {required Function converter, bool isAuth = true, Map<String, dynamic>? queryParams, bool isContentTypeHeader = false}) async {
    var url = createUri("${HttpX.instance.baseUrl}$this",queryParams);
    try {
      http.Response response = await http.get(url, headers: {
        if (isAuth) HttpX.instance.headerName: await HttpX.instance.token(),
        if(isContentTypeHeader)"content-type": "application/json"
      });
      print("response: " + response.body);
      var encodedData = jsonEncode(response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: converter(jsonDecode(encodedData)),
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
      {body, required Function converter, bool isAuth = true, Map<String, dynamic>? queryParams, bool isContentTypeHeader = false}) async {
    var url = createUri("${HttpX.instance.baseUrl}$this",queryParams);
    try {
      http.Response response =
      await http.post(url, body: jsonEncode(body), headers: {
        if (isAuth) HttpX.instance.headerName: await HttpX.instance.token(),
        if(isContentTypeHeader)"content-type": "application/json"
      });
      print("response: " + response.body);
      var encodedData = jsonEncode(response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: converter(jsonDecode(encodedData)),
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
      {required Function converter,List<http.MultipartFile>? files,Map<String,String>? fields, bool isAuth = true, String method = "POST"}) async {
    var url = createUri("${HttpX.instance.baseUrl}$this");
    var request = http.MultipartRequest((method == "PUT") ? "PUT" : "POST", url)
      ..headers.addAll({
        if (isAuth) HttpX.instance.headerName:  await HttpX.instance.token(),
        "content-type": "multipart/form-data"
      });
    if(files!=null)request.files.addAll(files);
    if(fields!=null)request.fields.addAll(fields);

    try {
      http.Response response = await http.Response.fromStream(await request.send());
      var encodedData = jsonEncode(response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: converter(jsonDecode(encodedData)),
          error: null);
    } catch (error) {
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

  Future<ApiResponse<T>> httpMultiPartWithProgress<T>(
      {required Function converter,List<FileItem>? files,Map<String,String>? fields, bool isAuth = true, String method = "POST"}) async {
    var url = "${HttpX.instance.baseUrl}$this";
    try {
      final taskId = await FlutterUploader().enqueue(
        MultipartFormDataUpload(
          url: url,
          files: files,
          data: fields,
          method: (method == "PUT") ? UploadMethod.PUT : UploadMethod.POST,
          headers: {
            if (isAuth) HttpX.instance.headerName:  await HttpX.instance.token(),
            "content-type": "multipart/form-data"
          },
          tag: 'upload tag',
        ),
      );
      return ApiResponse<T>(
          code: HttpStatus.ok,
          data: converter(jsonDecode(taskId)),
          error: null);
    } catch (error) {
      return ApiResponse<T>(
          code: HttpStatus.internalServerError,
          data: null,
          error: error.toString());
    }
  }

  Future<ApiResponse<T>> httpPut<T>(
      {body, required Function converter, bool isAuth = true, Map<String, dynamic>? queryParams, bool isContentTypeHeader = false}) async {
    var url = createUri("${HttpX.instance.baseUrl}$this",queryParams);
    try {
      http.Response response =
      await http.put(url, body: jsonEncode(body), headers: {
        if (isAuth) HttpX.instance.headerName: await HttpX.instance.token(),
        if(isContentTypeHeader)"content-type": "application/json"
      });
      print("response: " + response.body);
      var encodedData = jsonEncode(response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: converter(jsonDecode(encodedData)),
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
      {body, required Function converter, bool isAuth = true, Map<String, dynamic>? queryParams, bool isContentTypeHeader = false}) async {
    var url = createUri("${HttpX.instance.baseUrl}$this",queryParams);
    try {
      http.Response response =
      await http.delete(url, body: jsonEncode(body), headers: {
        if (isAuth) HttpX.instance.headerName: await HttpX.instance.token(),
        if(isContentTypeHeader)"content-type": "application/json"
      });
      print("response: " + response.body);
      var encodedData = jsonEncode(response.body);
      return ApiResponse<T>(
          code: response.statusCode,
          data: converter(jsonDecode(encodedData)),
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


Uri createUri(String url, [Map<String, dynamic>? queryParameters]) {
  var isHttp = false;
  if (url.startsWith('https://') || (isHttp = url.startsWith('http://'))) {
    var authority = url.substring((isHttp ? 'http://' : 'https://').length);
    String path;
    final index = authority.indexOf('/');

    if (-1 == index) {
      path = '';
    } else {
      path = authority.substring(index);
      authority = authority.substring(0, authority.length - path.length);
    }

    if (isHttp) {
      return Uri.http(authority, path, queryParameters);
    } else {
      return Uri.https(authority, path, queryParameters);
    }
  } else if (url.startsWith('localhost')) {
    return createUri('https://' + url, queryParameters);
  }

  throw Exception('Unsupported scheme');
}