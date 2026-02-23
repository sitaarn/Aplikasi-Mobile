import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 142, 149, 241),
        appBar: AppBar(
          title: const Text("My First Project"),
          backgroundColor: const Color.fromARGB(255, 107, 114, 221),
        ),
        body: Opacity(
          opacity: 0.4,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image(
              image: AssetImage('images/lily.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ),
  );
}