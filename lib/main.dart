import 'package:algorithms/auto_control_panel.dart';
import 'package:algorithms/step_by_step_control_panel.dart';
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
      debugShowCheckedModeBanner: false,
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

  bool _isStopped = false;
  bool _stepByStepMode = false;
  bool _isLoading = false;
  
  Duration _duration = const Duration(milliseconds: 0);
  
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
      appBar: AppBar(
        title: const Text('Algorithms'),
        actions: (!_isLoading) 
          ? [
              PopupMenuButton(
                icon: const Icon(Icons.edit),
                itemBuilder: (_) {
                  return [
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.add),
                        title: Text('Add number'),
                      ),
                      onTap: () {
                      },
                    ),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.numbers),
                        title: Text('Random numbers'),
                      ),
                      onTap: () {
                      },
                    )
                  ];
                }
              ),
              PopupMenuButton(
                itemBuilder: (_) {
                  return [
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('Auto mode'),
                      ),
                      onTap: () {
                        setState(() {
                          _stepByStepMode = false;
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.front_hand),
                        title: Text('Step by step mode'),
                      ),
                      onTap: () async {
                        _isLoading = true;                      
                        setState(() {
                          
                        });
                        _stepByStepMode = true;
                        _duration = const Duration(milliseconds: 0);
                        list = await _bubbleSort(list);
                        setState(() {
                          _isLoading = false;
                        });
                      },
                    )
                  ];
                }
              )
            ]
        : [],        
      ),
      body: (!_isLoading) 
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: _deviceHeight * 0.75,
                child: Center(
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
              ),
              (!_stepByStepMode) 
                ? AutoControlPanel(
                    onPlay: () async {
                      list = await _bubbleSort(list);
                    },
                    onStop: () {
                      setState(() {
                        _isStopped = true;
                      });
                    },
                    onDurationChange: (value) {
                      setState(() {
                        _duration = Duration(milliseconds: value);
                      });
                    },
                  )
                : StepByStepControlPanel(
                    onStepForward: () {

                    },
                    onStepBack: () {

                    }
                  )
            ],
          )
        : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<List<ArrayItem>> _bubbleSort(List<ArrayItem> list) async {
    var oldList = list.map((item) => ArrayItem.clone(item)).toList();
    for(int i = 0; i < list.length - 1; i++) {
      var isNormalOrder = true;
      for(int j = 0; j < list.length - 1; j++) {
        if (_isStopped) {
          _isStopped = false;
          _changeState(BubbleSortItemState(state: BubbleSortState.None));
          return oldList;
        }
        if (list[j].value > list[j+1].value) {
          isNormalOrder = false;
          _changeState(BubbleSortItemState(state: BubbleSortState.Swap, index: j));
          await Future.delayed(_duration);

          await _onSwap(j, _duration);       

          var tmp = list[j].value;
          list[j].value = list[j+1].value;
          list[j+1].value = tmp;

          _changeState(BubbleSortItemState(state: BubbleSortState.Swap, index: j));
          
        } else {
          _changeState(BubbleSortItemState(state: BubbleSortState.Normal, index: j));
          await Future.delayed(_duration);
        } 
      }
      if (isNormalOrder) break;
    }  
    _changeState(BubbleSortItemState(state: BubbleSortState.None));
    return (!_stepByStepMode) ? list : oldList;
  }

  void _changeState(BubbleSortItemState newState) {
    if (!_stepByStepMode) {
      setState(() {
        state = newState;
      });
    }
  }

  Future<void> _onSwap(int j, Duration duration) async {
    Offset offsetForLeft = ((j + 1) % 5 == 0) ? const Offset(-4.6, 1.15) : const Offset(1.15, 0) ;
    Offset offsetForRight = ((j + 1) % 5 == 0) ? const Offset(4.6, -1.15) : const Offset(-1.15, 0);
    
    _switchTweens[j].end = offsetForLeft;
    _switchAnimationControllers[j].duration = duration;
    _switchAnimationControllers[j].forward();

    _switchTweens[j + 1].end = offsetForRight;
    _switchAnimationControllers[j + 1].duration = duration;
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

  factory ArrayItem.clone(ArrayItem item) {
    return ArrayItem(value: item.value, index: item.index);
  }
}

class BubbleSortItemState {
  final BubbleSortState state;
  int? index;

  BubbleSortItemState({required this.state, this.index});
}

enum BubbleSortState {
  None, Normal, Swap
}