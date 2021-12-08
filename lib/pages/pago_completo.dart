import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PagoCompletoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pago realizado',
          style: GoogleFonts.nanumGothic(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.star, color: Colors.green, size: 100),
          SizedBox(height: 20),
          Text(
            'Pago realizado correctamente',
            style: GoogleFonts.nanumGothic(
              fontSize: 22,
              color: Colors.black,
            ),
          )
        ],
      )),
    );
  }
}
