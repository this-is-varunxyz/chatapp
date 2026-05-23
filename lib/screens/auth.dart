import 'package:cloud_firestore/cloud_firestore.dart';
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
  var isLoading = false;
  var username = '';

  final _formkey = GlobalKey<FormState>();
  void _submit() async {
    final isValid = _formkey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formkey.currentState!.save();

    if (_isLogin) {
      setState(() {
        isLoading = true;
      });
      try {
        _firebase.signInWithEmailAndPassword(
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
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      try {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({'username': username, 'email': enteredEmail});
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //...
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "authentication falied")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
      setState(() {
        isLoading = false;
      });
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
                        if(!_isLogin)
                        TextFormField(
                          decoration: InputDecoration(label: Text("Username")),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return "please enter a valid username";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            username = newValue!;
                          },
                        ),
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
                        if (isLoading) const CircularProgressIndicator(),
                        if (!isLoading)
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(_isLogin ? "Login" : "Signup"),
                          ),
                        if (!isLoading)
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
