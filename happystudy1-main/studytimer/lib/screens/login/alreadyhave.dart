import 'package:flutter/material.dart';

class Alreadyhaveanaccount extends StatelessWidget {
  final bool login;
  final VoidCallback press;
  const Alreadyhaveanaccount({
    Key? key, 
    required this.login, 
    required this.press, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "Don't have an account ?" : "Already have an account ?",
          style: const TextStyle(color: Color.fromARGB(255, 44, 63, 45)),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Create an Account" : "Sign In",
            style: const TextStyle(
              color: Color.fromARGB(255, 44, 63, 45),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}