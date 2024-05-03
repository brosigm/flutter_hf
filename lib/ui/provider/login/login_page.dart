import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart' as validator;

import 'login_model.dart';

class LoginPageProvider extends StatefulWidget {
  const LoginPageProvider({super.key});

  @override
  State<LoginPageProvider> createState() => _LoginPageProviderState();
}

class _LoginPageProviderState extends State<LoginPageProvider> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
  }

  //TODO: Try auto-login on model
  void _initializePage() async {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    final autoLogin = await loginModel.tryAutoLogin();
    if (autoLogin) {
      Navigator.of(context).pushReplacementNamed('/list');
    }
  }

  Future _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    _emailError = (email.isEmpty || !validator.isEmail(email)) ? 'Invalid email' : null;
    _passwordError = (password.isEmpty || password.length < 6) ? 'Invalid password, must be at least 6 characters long' : null;
    setState(() {});

    if (_emailError != null || _passwordError != null) {
      return; // Hibás adatok, ne indítsuk el a bejelentkezést
    }

    final loginModel = Provider.of<LoginModel>(context, listen: false);

    try {
      await loginModel.login(email, password, _rememberMe);

      // Sikeres bejelentkezés esetén navigálás a list oldalra
      Navigator.pushReplacementNamed(context, '/list');
    } catch (e) {
      LoginException loginException = e as LoginException;

      // Hiba kezelése
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginException.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loginModel.isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailError,
                ),
                enabled: !Provider.of<LoginModel>(context).isLoading,
                onChanged: (_) {
                  setState(() {
                    _emailError = null;
                  });
                },
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _passwordError,
                ),
                enabled: !Provider.of<LoginModel>(context).isLoading,
                onChanged: (_) {
                  setState(() {
                    _passwordError = null;
                  });
                },
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _rememberMe,
                    onChanged: !Provider.of<LoginModel>(context).isLoading
                        ? (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          }
                        : null,
                  ),
                  Text('Remember me'),
                ],
              ),
              ElevatedButton(
                onPressed: !Provider.of<LoginModel>(context).isLoading ? _handleLogin : null,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
