import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ApiResponse {
  fromJson(Map<String, dynamic> json);
  withError(String errorMessage);
}

class HttpX {
  HttpX._privateConstructor();
  static final HttpX instance = HttpX._privateConstructor();
  late String baseUrl;
  late Function token;
}

extension Http on String {
  Future<T> httpGet<T>() async{
    var url = Uri.parse("${HttpX.instance.baseUrl}/$this");
    try{
      http.Response response = await http.get(url, headers: {
        "Authorization": "Bearer "+ await HttpX.instance.token(),
        "content-type": "application/json"
      });
      if(response.statusCode == 200){
        print("response: "+response.body);
        return (T as ApiResponse).fromJson(jsonDecode(response.body));
      }else{
        print("error"+response.body);
        return (T as ApiResponse).withError(response.body);
      }
    }catch (error) {
      print("error"+error.toString());
      return (T as ApiResponse).withError(error.toString());
    }
  }

  Future<T> httpPost<T>({body}) async{
    var url = Uri.parse(this);
    try{
      http.Response response = await http.post(url,body: jsonEncode(body), headers: {
        "Authorization": "Bearer "+ await HttpX.instance.token(),
        "content-type": "application/json"
      });
      if(response.statusCode == 200){
        print("response: "+response.body);
        return (T as ApiResponse).fromJson(jsonDecode(response.body));
      }else {
        print("error"+response.body);
        return (T as ApiResponse).withError(response.body);
      }
    }catch (error) {
      print("error"+error.toString());
      return (T as ApiResponse).withError(error.toString());
    }
  }
 Future<T> httpPut<T>({body}) async{
    var url = Uri.parse(this);
    try{
      http.Response response = await http.put(url,body: jsonEncode(body), headers: {
        "Authorization": "Bearer "+ await HttpX.instance.token(),
        "content-type": "application/json"
      });
      if(response.statusCode == 200){
        print("response: "+response.body);
        return (T as ApiResponse).fromJson(jsonDecode(response.body));
      }else {
        print("error"+response.body);
        return (T as ApiResponse).withError(response.body);
      }
    }catch (error) {
      print("error"+error.toString());
      return (T as ApiResponse).withError(error.toString());
    }
  }

}