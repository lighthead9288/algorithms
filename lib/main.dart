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
 // List<double> list = [1,2,3,4,5,6,7,8,9,10];
//  List<double> list = List.generate(100, (index) => index.toDouble());
  List<ArrayItem> list = List.generate(10, (index) => ArrayItem(value: double.parse(Random().nextDouble().toStringAsFixed(3)), index: index));

  BubbleSortItemState? state = BubbleSortItemState(state: BubbleSortState.None);

  List<AnimationController> _switchAnimationControllers = [];
  List<Tween<ArrayItem>> _switchTweens = [];
  List<Animation<ArrayItem>> _switchAnimations = [];

  // @override
  // void initState() {
  //   for(var item in list) {
  //     _switchAnimationControllers.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 500)));
  //     _switchTweens.add(Tween<ArrayItem>(begin: item, end: item));
  //     _switchAnimations.add(_switchTweens[item.index].animate(_switchAnimationControllers[item.index]));
  //   }

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
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
            // AnimatedBuilder(
            //   animation: _switchAnimationControllers[item.index],
            //   builder: (_, __) => 
              
              Container(
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
             // child: ,
           // ),
            ).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          list = await _bubbleSort(list);
        },
        child: const Icon(Icons.sort),
      ),
    );
  }

  Future<List<ArrayItem>> _bubbleSort(List<ArrayItem> list) async {
    for(int i = 0; i < list.length - 1; i++) {
      var isNormalOrder = true;
      for(int j = 0; j < list.length - 1; j++) {
        if (list[j].value > list[j+1].value) {
          isNormalOrder = false;
          setState(() {
            state = BubbleSortItemState(state: BubbleSortState.Swap, index: j);
          });
          await Future.delayed(const Duration(seconds: 1));
          var tmp = list[j].value;
          list[j].value = list[j+1].value;
          list[j+1].value = tmp;


          setState(() {
            state = BubbleSortItemState(state: BubbleSortState.Swap, index: j);
          });
        //  _onSwap(list[j+1], list[j]);         

          await Future.delayed(const Duration(seconds: 1));
        } else {
          setState(() {
            state = BubbleSortItemState(state: BubbleSortState.Normal, index: j);
          });
          await Future.delayed(const Duration(seconds: 1));
        } 
      }
      if (isNormalOrder) break;
    }
    setState(() {
      state = BubbleSortItemState(state: BubbleSortState.None);
    });
    return list;
  }

  // void _onSwap(ArrayItem left, ArrayItem right) {
  //   _switchTweens[left.index].end = right;
  //   _switchAnimationControllers[left.index].forward();

  //   _switchTweens[right.index].end = left;
  //   _switchAnimationControllers[right.index].forward();
  // }
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


// import 'package:flutter/material.dart';
// import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
// import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final _scrollController = ScrollController();
//   final _gridViewKey = GlobalKey();
//   final _fruits = <String>["apple", "banana", "strawberry", "appl", "banan", "strawberr", "app", "bana", "strawber"];

//   @override
//   Widget build(BuildContext context) {
//     final generatedChildren = List.generate(
//       _fruits.length,
//               (index) => Container(
//         key: Key(_fruits.elementAt(index)),
//         color: Colors.lightBlue,
//         child: Text(
//           _fruits.elementAt(index),
//         ),
//       ),
//     );

//     return MaterialApp(
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//             ),
//             home: Scaffold(
//               body: ReorderableBuilder(
//                 children: generatedChildren,
//                 scrollController: _scrollController,
//                 onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
//                  for (final orderUpdateEntity in orderUpdateEntities) {
//                    print('On reorder');
//                     final fruit = _fruits.removeAt(orderUpdateEntity.oldIndex);
//                     _fruits.insert(orderUpdateEntity.newIndex, fruit);
//                   }
//                 },
//                 builder: (children) {
//                   return GridView(
//                     key: _gridViewKey,
//                     controller: _scrollController,
//                     children: children,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 4,
//                       crossAxisSpacing: 8,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         }

//   }
