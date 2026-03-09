import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 219, 151, 173),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    "images/profile.png"
                  ),
                ),
                Text("Sita Maheswari", 
                    style: GoogleFonts.pacifico(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                  )),
                Text(
                  "ANDROID DEVELOPER", 
                    style: GoogleFonts.sourceSans3(
                      fontSize: 20,
                      color: const Color.fromARGB(255, 238, 183, 201),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    )
                ),
                SizedBox(
                  height: 20,
                  width: 150,
                  child: Divider(
                    color: const Color.fromARGB(255, 252, 190, 211)
                  ),
                ),
                Container(
                  padding:EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: const Color.fromARGB(255, 248, 209, 222),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "08123456789", 
                        style: GoogleFonts.sourceSans3(
                          fontSize: 20, color:const Color.fromARGB(255, 234, 174, 194)
                        ),
                      ),

                    ],
                  ),
                ),    
                Container(
                  padding:EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: const Color.fromARGB(255, 248, 209, 222),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "sitamaheswari@mail.com",
                        style: GoogleFonts.sourceSans3(
                          fontSize: 20, color: const Color.fromARGB(255, 234, 174, 194)
                        ),
                      ),

                    ],
                  ),                  
                )
              ],

            )
          )
        ),
      ); 
  }
}