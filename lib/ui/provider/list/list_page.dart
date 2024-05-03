import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_homework/ui/provider/list/list_model.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../network/user_item.dart';

class ListPageProvider extends StatefulWidget {
  const ListPageProvider({Key? key}) : super(key: key);

  @override
  State<ListPageProvider> createState() => _ListPageProviderState();
}

class _ListPageProviderState extends State<ListPageProvider> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
  }

  void _initializePage() async {
    final listModel = Provider.of<ListModel>(context, listen: false);
    try {
      await listModel.loadUsers();
    } catch (e) {
      ListException listException = e as ListException;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(listException.message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List page',
          //white color for text
          style: TextStyle(color: Colors.white),
        ),
        //blue bacground for appbar
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            //white color for icon
            color: Colors.white,
            onPressed: () {
              _handleLogout();
            },
          ),
        ],
      ),
      body: Consumer<ListModel>(
        builder: (context, listModel, child) {
          if (listModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (listModel.users.isNotEmpty) {
              return ListView.builder(
                itemCount: listModel.users.length,
                itemBuilder: (context, index) {
                  UserItem user = listModel.users[index];
                  return ListTile(
                    key: Key('user_$index'),
                    //display avatar image
                    leading: Image(
                      image: NetworkImage(user.avatarUrl),
                      key: Key('avatar_$index'),
                    ),
                    title: Text(user.name, key: Key('name_$index')),
                  );
                },
              );
            } else {
              return Center(
                child: Text('No users found.'),
              );
            }
          }
        },
      ),
    );
  }

  void _handleLogout() {
    final prefs = GetIt.I<SharedPreferences>();
    prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/');
  }
}
