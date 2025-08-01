// lib/main.dart

import 'package:flutter/material.dart';
import 'package:nhapp/pages/quotation/pages/add_quotation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Quotation',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AddQuotationPage(),
    );
  }
}
