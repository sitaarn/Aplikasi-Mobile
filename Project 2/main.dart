import 'package:flutter/material.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 219, 151, 173),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100,
                color: Colors.white,
                child: Text("Container 1"),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                height: 100,
                color: Colors.blue,
                child: Text("Container 2"),               
              ),
              Container(
                height: 100,
                color: Colors.green,
                child: Text("Container 3"),                         
              ),
            ],
          )
        ),
      ),
    ); 
  }
}