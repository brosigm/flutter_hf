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

  //TODO: Fetch user list from model
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
        title: const Text('List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            return ListView.builder(
              itemCount: listModel.users.length,
              itemBuilder: (context, index) {
                UserItem user = listModel.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Text(user.name),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _handleLogout() {
    final prefs = GetIt.I<SharedPreferences>();
    prefs.remove('token');
    prefs.remove('sessionToken');
    Navigator.pushReplacementNamed(context, '/');
  }
}
