import 'dart:convert';
import 'package:flutter/material.dart';


ImageProvider getImageProvider(String? imageString) {
  

  if (imageString == null || imageString.isEmpty) {
    return const AssetImage('assets/logo.png'); 
  }
  

  if (imageString.startsWith('http')) {
    return NetworkImage(imageString);
  }
  

  try {
    return MemoryImage(base64Decode(imageString));
  } catch (e) {

    return const AssetImage('assets/logo.png');
  }
}