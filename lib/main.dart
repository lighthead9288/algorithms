import 'package:algorithms/features/bubble_sort/widgets/bubble_sort_widget.dart';
import 'package:algorithms/features/quick_sort/widgets/quick_sort_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuickSortWidget(),
    );
  }
}





