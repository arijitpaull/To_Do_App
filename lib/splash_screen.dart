import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 1, 1, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("GIOW",
              style: GoogleFonts.sixCaps(
                color: const Color.fromARGB(255, 255, 155, 255),
                fontWeight: FontWeight.w900,
                fontSize:80
              ),
            ),
            Text("Get It Over With",
              style: GoogleFonts.dmSerifText(
                color: Color.fromARGB(255, 255, 155, 255),
                fontWeight: FontWeight.bold,
                fontSize: 13
              ),
            ),
          ],
        ),
      ),
    );
  }
}