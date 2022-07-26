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
  List<double> list = List.generate(5, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
  BubbleSortItemState? state = BubbleSortItemState(state: BubbleSortState.None);

  List<AnimationController> _switchAnimationControllers = [];
  List<Tween<Offset>> _switchTweens = [];
  List<Animation<Offset>> _switchAnimations = [];

  late double _deviceHeight;
  late double _deviceWidth;

  bool _isStopped = false;
  bool _stepByStepMode = false;
  bool _isLoading = false;
  bool _isEnterArrayItemValue = false;
  bool _isEnterRandomValues = false;
  
  Duration _duration = const Duration(milliseconds: 0);

  List<ArraySortChange> _arraySortSteps = [];
  int _curArraySortStepIndex = 0;
  double _newArrayValue = 0;
  int _newRandomValuesCount = 0;
  
  @override
  void initState() {
    for(int i = 0; i < list.length; i++) {
      _addAnimation(list[i], i);
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
              (!_stepByStepMode) 
                ? PopupMenuButton(
                    icon: const Icon(Icons.edit),
                    itemBuilder: (_) {
                      return [
                        PopupMenuItem(
                          child: const ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Add number'),
                          ),
                          onTap: () {
                            setState(() {
                              _isEnterArrayItemValue = true;
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const ListTile(
                            leading: Icon(Icons.numbers),
                            title: Text('Random numbers'),
                          ),
                          onTap: () {
                            setState(() {
                              _isEnterRandomValues = true;
                            });
                          },
                        )
                      ];
                    }
                  )
                : const SizedBox(),
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
                        await _onStepByStepMode();
                      },
                    )
                  ];
                }
              )
            ]
        : [],        
      ),
      body: (!_isLoading) 
        ? Stack(
            children: [
              _isEnterArrayItemValue 
                ? Container(
                    width: _deviceWidth,
                    height: _deviceHeight * 0.08,
                    decoration: BoxDecoration(color: Colors.brown[50]),
                    child: Row(                  
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 3),
                          width: _deviceWidth * 0.75,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _newArrayValue = double.parse(value);
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _addItem(_newArrayValue);                            
                              _isEnterArrayItemValue = false;
                            });
                          }, 
                          icon: const Icon(Icons.done)
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEnterArrayItemValue = false;
                            });
                          }, 
                          icon: const Icon(Icons.close)
                        )
                      ],
                    )
                  )
                : const SizedBox(),
              _isEnterRandomValues
                ? Container(
                    width: _deviceWidth,
                    height: _deviceHeight * 0.08,
                    decoration: BoxDecoration(color: Colors.orange[100]),
                    child: Row(                  
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 3),
                          width: _deviceWidth * 0.75,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _newRandomValuesCount = int.parse(value);
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            var newItems = List.generate(_newRandomValuesCount, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
                            for(var item in newItems) {
                              _addItem(item);
                            }
                            setState(() {                              
                              _isEnterRandomValues = false;
                            });
                          }, 
                          icon: const Icon(Icons.done)
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEnterRandomValues = false;
                            });
                          }, 
                          icon: const Icon(Icons.close)
                        )
                      ],
                    )
                  )
                : const SizedBox(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: _deviceHeight * 0.75,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10
                          ),
                          padding: const EdgeInsets.all(20),
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (_, index) {
                            var item = list[index];
                            return SlideTransition(
                              position: _switchAnimations[index], 
                              child: Container(
                                  decoration: BoxDecoration(
                                  //  color: Colors.red,
                                    border: Border.all(
                                      color: (state?.state != BubbleSortState.None) 
                                        ? (state?.state == BubbleSortState.Normal) 
                                          ? ((index == state?.index) || (index == (state?.index ?? 0) + 1)) ? Colors.green : Colors.black
                                          : ((index == state?.index) || (index == (state?.index ?? 0) + 1)) ? Colors.red : Colors.black
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
                                            child: Text(index.toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                                          ),
                                        ),
                                        top: 0,
                                        left: 0
                                      ),
                                      Center(
                                        child: Text(item.toString(), style: const TextStyle(color: Colors.black)),
                                      )
                                    ],
                                  ),
                                ),
                            );
                          },
                          
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
                          _onStepForward();
                        },
                        onStepBack: () {
                          _onStepBack();
                        }
                      )
                ],
              )
            ],
          )
        : const Center(child: CircularProgressIndicator()),
        resizeToAvoidBottomInset : false
    );
  }

  void _addItem(double item) {
    list.add(item);
    _addAnimation(item, list.length - 1);
  }

  void _addAnimation(double item, int index) {
    _switchAnimationControllers.add(AnimationController(vsync: this, duration: _duration, reverseDuration: const Duration(seconds: 0)));
    _switchTweens.add(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
    _switchAnimations.add(_switchTweens[index].animate(_switchAnimationControllers[index]));
  }

  Future<List<double>> _bubbleSort(List<double> list) async {
    var oldList = List<double>.from(list);
    _curArraySortStepIndex = 0;
    for(int i = 0; i < list.length - 1; i++) {
      var isNormalOrder = true;
      for(int j = 0; j < list.length - 1; j++) {
        if (_isStopped) {
          // Stop
          _isStopped = false;
          _onStateChange(BubbleSortItemState(state: BubbleSortState.None));
          return oldList;
        }
        if (list[j] > list[j+1]) {
          // Swap
          isNormalOrder = false;
          _onStateChange(BubbleSortItemState(state: BubbleSortState.Swap, index: j));
          await Future.delayed(_duration);

          await _animateSwap(j, j+1, _duration);
          _swapElements(j, j+1);
         
        } else {
          // Normal
          _onStateChange(BubbleSortItemState(state: BubbleSortState.Normal, index: j));
          await Future.delayed(_duration);
        } 
      }
      if (isNormalOrder) break;
    }
    // Finish  
    _onStateChange(BubbleSortItemState(state: BubbleSortState.None));
    return (!_stepByStepMode) ? list : oldList;
  }

  void _swapElements(int prev, int next) {
    var tmp = list[prev];
    list[prev] = list[next];
    list[next] = tmp;
  }

  void _onStateChange(BubbleSortItemState newState) {
    if (!_stepByStepMode) {
      _raiseStateChange(newState);
    } else {
      _arraySortSteps.add(
        ArraySortChange(
          state: newState, 
          swaps: (newState.index != null) 
            ? [ Swap(arraySourceIndex: newState.index!, arrayDestinationIndex: newState.index! + 1) ]
            : []
        )
      );
    }
  }

  void _raiseStateChange(BubbleSortItemState newState) {
    setState(() {
      state = newState;
    });
  }

  Future<void> _animateSwap(int prev, int next, Duration duration) async {
    Offset offsetForLeft = ((next) % 5 == 0) ? const Offset(-4.6, 1.15) : const Offset(1.15, 0) ;
    Offset offsetForRight = ((next) % 5 == 0) ? const Offset(4.6, -1.15) : const Offset(-1.15, 0);
    
    _switchTweens[prev].end = offsetForLeft;
    _switchAnimationControllers[prev].duration = duration;
    _switchAnimationControllers[prev].forward();

    _switchTweens[next].end = offsetForRight;
    _switchAnimationControllers[next].duration = duration;
    _switchAnimationControllers[next].forward();

    await Future.delayed(duration);

    _switchAnimationControllers[prev].reverse();
    _switchAnimationControllers[next].reverse();    
  }

  void _onStepForward() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    _raiseStateChange(curStep.state);
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.state == BubbleSortState.Swap) {            
      for (var swap in curStep.swaps) {
        _animateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arraySourceIndex, swap.arrayDestinationIndex);
      }
      _raiseStateChange(curStep.state);      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == _arraySortSteps.length - 1) ? _arraySortSteps.length - 1 : _curArraySortStepIndex + 1;
  }

  void _onStepBack() async { 
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    _raiseStateChange(curStep.state);
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.state == BubbleSortState.Swap) {            
      for (var swap in curStep.swaps) {
        _animateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arrayDestinationIndex, swap.arraySourceIndex);
      }
      _raiseStateChange(curStep.state);      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == 0) ? 0 : _curArraySortStepIndex - 1;    
  }

  Future<void> _onStepByStepMode() async {
    _isLoading = true;                      
    setState(() {});
    _stepByStepMode = true;
    _duration = const Duration(milliseconds: 0);
    _arraySortSteps.clear();
    _arraySortSteps.add(ArraySortChange(state: BubbleSortItemState(state: BubbleSortState.None)));
    list = await _bubbleSort(list);
    setState(() {
      _isLoading = false;
    });
  }
}

class ArraySortChange {
  final BubbleSortItemState state;
  List<Swap> swaps;

  ArraySortChange({required this.state, this.swaps = const []});
}

class Swap {
  final int arraySourceIndex;
  final int arrayDestinationIndex;

  Swap({required this.arraySourceIndex, required this.arrayDestinationIndex});
}

class BubbleSortItemState {
  final BubbleSortState state;
  int? index;

  BubbleSortItemState({required this.state, this.index});
}

enum BubbleSortState {
  None, Normal, Swap
}