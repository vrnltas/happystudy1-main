import 'package:flutter/material.dart';
import 'package:studytimer/componen/rounded_button.dart';
import 'package:studytimer/screens/login/login_screen.dart';
import 'package:studytimer/screens/login/sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 360,
            left: 15,
            right: 15,
            child: Image.asset(
              "assets/images/2.png",
              width: size.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 90.0,
            left: 50,
            right: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Control Your Study Time Easily',
                  style: GoogleFonts.lato(
                    fontSize: 27.0,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 45, 63, 48),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 17),
                Text(
                  'Take control of your study time and achieve extraordinary achievements',
                  style: GoogleFonts.lato(
                    fontSize: 13.9,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 82, 109, 71),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), 
                    color: const Color.fromARGB(255, 57, 81,
                        57), 
                  ),
                  child: RoundedButton(
                    text: "Get Started",
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const LoginScreen();
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Signin()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
