import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<ArrayItem> list = List.generate(10, (index) => ArrayItem(value: double.parse(Random().nextDouble().toStringAsFixed(3)), index: index));

  BubbleSortItemState? state = BubbleSortItemState(state: BubbleSortState.None);

  List<AnimationController> _switchAnimationControllers = [];
  List<Tween<Offset>> _switchTweens = [];
  List<Animation<Offset>> _switchAnimations = [];

  late double _deviceHeight;
  late double _deviceWidth;

  final Duration _duration = const Duration(milliseconds: 300);
  
  @override
  void initState() {
    for(var item in list) {
      _switchAnimationControllers.add(AnimationController(vsync: this, duration: _duration, reverseDuration: const Duration(seconds: 0)));
      _switchTweens.add(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
      _switchAnimations.add(_switchTweens[item.index].animate(_switchAnimationControllers[item.index]));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Algorithms')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: GridView.count(
            crossAxisCount: 5, 
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: list.map((item) => 
            SlideTransition(
              position: _switchAnimations[item.index], 
              child: Container(
                  decoration: BoxDecoration(
                  //  color: Colors.red,
                    border: Border.all(
                      color: (state?.state != BubbleSortState.None) 
                        ? (state?.state == BubbleSortState.Normal) 
                          ? ((item.index == state?.index) || (item.index == (state?.index ?? 0) + 1)) ? Colors.green : Colors.black
                          : ((item.index == state?.index) || (item.index == (state?.index ?? 0) + 1)) ? Colors.red : Colors.black
                        : Colors.black,              
                      width: 5
                    ), 
                    borderRadius: BorderRadius.circular(5), 
                  //  shape: BoxShape.circle
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Colors.black), bottom: BorderSide(color: Colors.black))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(item.index.toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                          ),
                        ),
                        top: 0,
                        left: 0
                      ),
                      Center(
                        child: Text(item.value.toString(), style: const TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
              ),
            ).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          list = await _bubbleSort(list, _duration);
        },
        child: const Icon(Icons.sort),
      ),
    );
  }

  Future<List<ArrayItem>> _bubbleSort(List<ArrayItem> list, Duration duration) async {
    for(int i = 0; i < list.length - 1; i++) {
      var isNormalOrder = true;
      for(int j = 0; j < list.length - 1; j++) {
        if (list[j].value > list[j+1].value) {
          isNormalOrder = false;
          setState(() {
            state = BubbleSortItemState(state: BubbleSortState.Swap, index: j);
          });
          await Future.delayed(duration);

          await _onSwap(j, duration);       

          var tmp = list[j].value;
          list[j].value = list[j+1].value;
          list[j+1].value = tmp;


          setState(() {
            state = BubbleSortItemState(state: BubbleSortState.Swap, index: j);
          });
          
        } else {
          setState(() {
            state = BubbleSortItemState(state: BubbleSortState.Normal, index: j);
          });
          await Future.delayed(duration);
        } 
      }
      if (isNormalOrder) break;
    }
    setState(() {
      state = BubbleSortItemState(state: BubbleSortState.None);
    });
    return list;
  }

  Future<void> _onSwap(int j, Duration duration) async {
    Offset offsetForLeft = ((j + 1) % 5 == 0) ? Offset(-4.6, 1.15) : Offset(1.15, 0) ;
    Offset offsetForRight = ((j + 1) % 5 == 0) ? Offset(4.6, -1.15) : Offset(-1.15, 0);
    
    _switchTweens[j].end = offsetForLeft;
    _switchAnimationControllers[j].forward();

    _switchTweens[j + 1].end = offsetForRight;
    _switchAnimationControllers[j + 1].forward();

    await Future.delayed(duration);

    _switchAnimationControllers[j].reverse();
    _switchAnimationControllers[j + 1].reverse();    
  }
}

class ArrayItem {
  final int index;
  double value;

  ArrayItem({required this.value, required this.index});
}

class BubbleSortItemState {
  final BubbleSortState state;
  int? index;

  BubbleSortItemState({required this.state, this.index});
}

enum BubbleSortState {
  None, Normal, Swap
}