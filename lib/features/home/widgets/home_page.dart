import 'package:algorithms/features/bubble_sort/widgets/bubble_sort_widget.dart';
import 'package:algorithms/features/quick_sort/widgets/quick_sort_widget.dart';
import 'package:algorithms/features/tree/widgets/tree_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SizedBox(
            height: _deviceHeight * 0.1,
            child: Card(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Image.asset('assets/sort.png'),
                  title: const Text('Bubble sort'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BubbleSortWidget()
                      )
                    );
                  },
                ),
              ),            
            ),
          ),
          SizedBox(
            height: _deviceHeight * 0.1,
            child: Card(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Image.asset('assets/sort.png'),
                  title: const Text('Quick sort'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuickSortWidget()
                      )
                    );
                  },
                ),
              ),            
            ),
          ),
          SizedBox(
            height: _deviceHeight * 0.1,
            child: Card(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Image.asset('assets/binary_tree.png'),
                  title: const Text('Binary tree operations'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TreeWidget()
                      )
                    );
                  },
                ),
              ),            
            ),
          )
        ],
      ),
    );
  }
}