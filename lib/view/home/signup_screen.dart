// ignore_for_file: prefer_const_constructors

import 'package:enteward/provider/signInProvider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff313131),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            
          ),
          onPressed: () {
            final provider = Provider.of<GoogleSignInProvider>(context,listen: false);
            provider.googleLogin();
          },
           icon: FaIcon(FontAwesomeIcons.google,color: Colors.red,),
          label: Text('Sign In with Google'),
        ),
      ),
    );
  }
}
