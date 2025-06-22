import 'package:flutter/material.dart';
import 'authenication/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mrdcygimgskcwotkzztu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yZGN5Z2ltZ3NrY3dvdGt6enR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1Nzg4MjMsImV4cCI6MjA2NjE1NDgyM30.tqcQ7J0BHfYZ9YDoQ_3gB_7iAegOgil46jSr50Flkdo',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Receipt Generator',
      home: RegisterPage(),
    );
  }
}