import 'package:flutter/material.dart';

Widget userInput(TextEditingController userInput, String hintTitle,
    TextInputType keyboardType,
    {readOnly = false, isPassword = false}) {
  return Container(
    height: 55,
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: Colors.blueGrey.shade200,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 15, right: 5),
      child: TextField(
        obscureText: isPassword,
        readOnly: readOnly,
        controller: userInput,
        autocorrect: false,
        enableSuggestions: false,
        autofocus: false,
        decoration: InputDecoration.collapsed(
          hintText: hintTitle,
          hintStyle: const TextStyle(
              fontSize: 18, color: Colors.white70, fontStyle: FontStyle.italic),
        ),
        keyboardType: keyboardType,
      ),
    ),
  );
}
