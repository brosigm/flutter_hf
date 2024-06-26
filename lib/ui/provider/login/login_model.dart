import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginException extends Equatable implements Exception {
  final String message;

  const LoginException(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginModel extends ChangeNotifier {
  var isLoading = false;

  Future login(String email, String password, bool rememberMe) async {
    if (isLoading) {
      return;
    }
    Dio dio = GetIt.I<Dio>();
    try {
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
      };

      isLoading = true;

      Response response = await dio.post('/login', data: data);

      if (rememberMe) {
        final SharedPreferences prefs = GetIt.I<SharedPreferences>();
        await prefs.setString('token', response.data['token']);
      }
      dio.options.headers['Authorization'] = 'Bearer ${response.data['token']}';
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          throw LoginException(e.response!.data['message']);
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final SharedPreferences prefs = GetIt.I<SharedPreferences>();
      final String? token = prefs.getString('token');
      Dio dio = GetIt.I<Dio>();

      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer ${token}';
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw LoginException('Error during auto-login: $e');
    }
  }
}
