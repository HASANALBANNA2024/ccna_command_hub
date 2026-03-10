import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // color plate
  static const Color primaryBlue = Color(0xFF005073);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  
  // light theme
static ThemeData lightTheme = ThemeData(
  brightness:  Brightness.light,
  primaryColor:  primaryBlue,
  scaffoldBackgroundColor: Color(0xFFF5F7FA),
  
  // card theme
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
  )
);


// Dark Theme
static ThemeData dartTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor:  primaryBlue,
  scaffoldBackgroundColor: darkBackground,
  cardTheme: CardThemeData(
    color: darkCard,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    foregroundColor: Colors.white,
  ),

);
}