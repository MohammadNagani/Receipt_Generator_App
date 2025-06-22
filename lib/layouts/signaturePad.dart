import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:flutter/services.dart';

class SignaturePad extends StatefulWidget{
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {

  final SignatureController _signatureController = SignatureController(
    penColor: Colors.black,
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.white,
  );

  Future<void> saveSignature() async {
    if (_signatureController.isNotEmpty) {
      try {
        // convert sign to img
        Uint8List? signatureImage = await _signatureController.toPngBytes();
        if (signatureImage != null) {
          // Get the app's document directory
          final directory = await getApplicationDocumentsDirectory();
          final filePath = "${directory.path}/signature.png";

          //Save img
          File file = File(filePath);
          await file.writeAsBytes(signatureImage);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(" Signature saved at :$filePath")),
          );

          //Return filepath to previous screen
          Navigator.pop(context,file);

        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error saving Signature:$e")));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please draw a Signature first ")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signature Pad"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text("Draw your Signature below:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),

          //Signature Pad Container
          Container(
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Signature(
              controller: _signatureController,
              width: double.infinity,
              height: 250,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(
            height: 20,
          ),

          // Buttons for Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () => _signatureController.clear(),
                  child: Text("Clear")),
              ElevatedButton(
                  onPressed:  saveSignature, child: Text("Save")),
            ],
          )
        ],
      ),
    );
  }
}