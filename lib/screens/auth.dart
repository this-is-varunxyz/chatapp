import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() {
    return _AuthState();
  }
}

class _AuthState extends State<Auth> {
  var _isLogin = true;
  var enteredEmail = '';
  var enteredPassword = '';

  final _formkey = GlobalKey<FormState>();
  void _submit() {
    final isValid = _formkey.currentState!.validate();
    if (!isValid) {}
    _formkey.currentState!.save();
    if (_isLogin) {
      try {
        final userCredential = _firebase.signInWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //...
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "authentication falied")),
        );
      }
    } else {
      try {
        final userCredential = _firebase.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //...
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "authentication falied")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 20,
                ),
              ),
              Text("CHat App"),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            label: Text("INPUT EMAIL"),
                          ),
                          onSaved: (newValue) {
                            enteredEmail = newValue!;
                          },
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },

                          textCapitalization: TextCapitalization.none,
                        ),
                        TextFormField(
                          decoration: InputDecoration(label: Text("Password")),
                          obscureText: true,
                          onSaved: (newValue) {
                            enteredPassword = newValue!;
                          },
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "password must be atleast 6 character long";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? "Login" : "Signup"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? "Create an account"
                                : "already have an account",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
