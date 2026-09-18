import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:secure_vault/notes.dart';
import 'package:secure_vault/pages/homepage.dart';
// import 'package:secure_vault/pages/imageviewer.dart';
import 'package:secure_vault/pages/login.dart';
import 'package:secure_vault/pages/newnotes.dart';
import 'package:secure_vault/pages/splash_screen.dart';
import 'package:secure_vault/theme_provider.dart';


Future<void> openEncryptedVault() async{
  const securestorage = FlutterSecureStorage();

  final containsEncryptionkey = await securestorage.containsKey(key: 'vault_cipher_key');
  if (!containsEncryptionkey){
    final key = Hive.generateSecureKey();
    await securestorage.write(key: 'vault_cipher_key', value: base64UrlEncode(key));
  }
  final encryptedkeystring = await securestorage.read(key: 'vault_cipher_key');
  final encryptionkeyunit8list = base64Url.decode(encryptedkeystring!);
  final cipher = HiveAesCipher(encryptionkeyunit8list);

  await Hive.openBox("passwordbox", encryptionCipher: cipher);
  await Hive.openBox<String>("imagebox", encryptionCipher: cipher);
  await Hive.openBox<String>("videobox", encryptionCipher: cipher);
  await Hive.openBox<Notes>("notesbox", encryptionCipher: cipher);  
}

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NotesAdapter());

  await openEncryptedVault();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: Consumer<ThemeProvider>(
      builder: (context, ThemeProvider,child){
        return MaterialApp(debugShowCheckedModeBanner: false,
        themeMode: ThemeProvider.themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.light(
            primary: Color(0xFF6C63FF),
            surface: Colors.white),
            // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color.fromARGB(255, 7, 0, 18),
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: const Color.fromARGB(255, 21, 2, 53)),
            // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        ),
        routes:{
            '/': (context) => SplashScreen(),
            '/login': (context) => Login(),
            '/home': (context) => Homepage(),
            '/newnote': (context) => Newnotes(),
          }
        );
      },
      
    ),
  ));
}
