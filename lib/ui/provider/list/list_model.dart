import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_homework/network/user_item.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListException extends Equatable implements Exception {
  final String message;

  const ListException(this.message);

  @override
  List<Object?> get props => [message];
}

class ListModel extends ChangeNotifier{
  var isLoading = false;
  var users = <UserItem>[];

  Future loadUsers() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      final SharedPreferences prefs = GetIt.I<SharedPreferences>();
      final String? token = prefs.getString('token');

      Dio dio = GetIt.I<Dio>();

      Map data = {
        'Authorization': 'Bearer $token'
      };
      Response response = await dio.get('/users',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

        users = (response.data as List)
            .map((userJson) => UserItem(userJson['name'], userJson['avatarUrl']))
            .toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          throw ListException(e.response!.data['message']);
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}