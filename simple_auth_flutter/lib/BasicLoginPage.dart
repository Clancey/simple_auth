import 'package:flutter/material.dart';
import 'package:simple_auth/simple_auth.dart';

class BasicLoginPage extends StatefulWidget {
  static String defaultLogo;
  final BasicAuthAuthenticator authenticator;
  BasicLoginPage(this.authenticator);
  static String tag = 'basic-login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<BasicLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: (BasicLoginPage.defaultLogo?.isEmpty ?? true)
            ? Icon(Icons.supervised_user_circle)
            : Image.asset(BasicLoginPage.defaultLogo),
      ),
    );

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () async {
            try {
              bool success = await widget.authenticator.verifyCredentials(
                  emailController.text, passwordController.text);
              if (success) Navigator.pop(context);
            } catch (ex) {
              var alert =
                  new AlertDialog(content: new Text(ex), actions: <Widget>[
                new FlatButton(
                    child: const Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]);
              showDialog(
                  context: context, builder: (BuildContext context) => alert);
            }
          },
          color: Colors.lightBlueAccent,
          child: Text('Log In', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    return Scaffold(
      appBar: new AppBar(
        title: Text(widget.authenticator.title),
        actions: widget.authenticator.allowsCancel
            ? <Widget>[
                new IconButton(
                  icon: new Icon(Icons.cancel),
                  onPressed: () {
                    widget.authenticator.cancel();
                    Navigator.pop(context);
                  },
                )
              ]
            : null,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.authenticator.cancel();
    super.dispose();
  }
}
