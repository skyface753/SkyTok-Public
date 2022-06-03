import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:skytok_flutter/services/read_write_data.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login/Register'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _isLogin ? 0 : 1,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Login',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Register',
            ),
          ],
          onTap: (int index) {
            setState(() {
              _isLogin = index == 0;
            });
          },
        ),
        body: SingleChildScrollView(
            child: _isLogin ? loginForm() : registerForm()));
  }

  Widget registerForm() {
    TextEditingController _firstNameController = TextEditingController();
    TextEditingController _lastNameController = TextEditingController();
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    // Firstname, lastname, username, email, password, confirm password
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Firstname',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Lastname',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm password',
              ),
              onChanged: (text) {
                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  print('Password does not match');
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: RaisedButton(
              child: Text('Register'),
              onPressed: () {
                //TODO register
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget loginForm() {
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    _usernameController.text = "skytok";
    _passwordController.text = "skytok";
    //Username or Email and Password
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username or Email',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: RaisedButton(
              child: Text('Login'),
              onPressed: () async {
                //TODO: Login user
                var responseLogin = await Api().login(context,
                    _usernameController.text, _passwordController.text);
                // print("Response: $responseLogin");
                if (responseLogin == false) {
                  print("Login failed");
                  context.showSuccessBar(content: Text("Login failed"));
                } else {
                  var token = responseLogin['token'];
                  var username = responseLogin['username'];
                  var mail = responseLogin['mail'];
                  var userID = responseLogin['userId'];
                  ReadWriteData().writeData(token, username, mail, userID);
                  // print("Token: $token");
                  Navigator.pushReplacementNamed(context, '/main');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
