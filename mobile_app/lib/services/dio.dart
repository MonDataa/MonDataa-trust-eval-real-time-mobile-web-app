import 'package:dio/dio.dart';
Dio dio(){
  Dio dio = new Dio();
  dio.options.baseUrl="http://10.0.2.2:8085";
  dio.options.headers['accept'] = 'Application/Json';
  return dio;
}
