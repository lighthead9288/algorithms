import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/new_array_value_dialog.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:algorithms/core/widgets/random_values_dialog.dart';
import 'package:algorithms/features/quick_sort/models/quick_sort_models.dart';
import 'package:algorithms/features/quick_sort/state/quick_sort_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickSortWidget extends StatefulWidget {
  const QuickSortWidget({ Key? key }) : super(key: key);

  @override
  State<QuickSortWidget> createState() => _QuickSortWidgetState();
}

class _QuickSortWidgetState extends State<QuickSortWidget> with TickerProviderStateMixin
    implements AlgorithmOperations {

  late double _deviceHeight;
  late double _deviceWidth;

  late BuildContext _cubitContext;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (_) =>  QuickSortCubit(
        initialState: QuickSortWidgetStateChanged(
          list: [], 
          stepByStepMode: false, 
          state: QuickSortItemState(
            status: QuickSortStatus.None,
            leftItemIndex: 0, 
            rightItemIndex: 0, 
            pivotItemIndex: 0
          )
        )
      ),
      child: BlocBuilder<QuickSortCubit, QuickSortWidgetStateChanged>(
        builder: ((context, state) {
          _cubitContext = context;
          return PlaygroundWidget(
            operations: this, 
            widget: _quickSortArrayUI(state),
            editOptions: [
                EditDataOption(
                    title: 'Add number',
                    icon: const Icon(Icons.add),
                    onTap: () async {
                      Navigator.pop(context);
                      var result = await showDialog<double>(
                          context: context,
                          builder: (_) => const NewArrayValueDialog());
                      // _cubitContext.read<BubbleSortCubit>().onAddItem(result!);
                    }),
                EditDataOption(
                    title: 'Random numbers',
                    icon: const Icon(Icons.numbers),
                    onTap: () async {
                      Navigator.pop(context);
                      var result = await showDialog<int>(
                          context: context,
                          builder: (_) => const RandomValuesDialog());
                      // _cubitContext
                      //     .read<BubbleSortCubit>()
                      //     .onRandomNumbersGenerate(result!);
                    })
              ]
          );
        })
      )
    );
  }

  Widget _quickSortArrayUI(QuickSortWidgetStateChanged widgetState) {
    return Column(
      children: [
        SizedBox(
          height: _deviceHeight * 0.8,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              width: _deviceWidth * 0.57,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                itemCount: widgetState.list.length,
                itemBuilder: (_, index) {
                  var item = widgetState.list[index];
                  return _quickSortArrayItemUI(widgetState, item, index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickSortArrayItemUI(QuickSortWidgetStateChanged widgetState, double item, int index) {
    bool isPivot = index == widgetState.state.pivotItemIndex;
    bool isLeft = index == widgetState.state.leftItemIndex;
    bool isRight = index == widgetState.state.rightItemIndex;
    return Row(
      children: [         
        SizedBox(
          width: _deviceWidth * 0.1,
          child: Text(
            (isPivot) && (widgetState.state.status != QuickSortStatus.None) ? 'Pivot' : '', 
            style: const TextStyle(color: Colors.brown)
          )
        ), 
        const SizedBox(width: 10),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: _deviceWidth * 0.15,
          height: _deviceWidth * 0.15,
          decoration: BoxDecoration(
            border: Border.all(
                color: (widgetState.state.status != QuickSortStatus.None)
                    ? (isLeft) 
                      ? Colors.blue
                      : (isRight) 
                        ? Colors.orange
                        : Colors.black
                    : Colors.black,
                width: 5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: GestureDetector(
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Colors.black),
                              bottom: BorderSide(color: Colors.black))),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(index.toString(),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10)),
                      ),
                    ),
                    top: 0,
                    left: 0),
                Center(
                  child: Text(item.toString(),
                      style: const TextStyle(color: Colors.black)),
                )
              ],
            ),
            onLongPressUp: (!widgetState.stepByStepMode)
                ? () {
                  // _onLongPressUp(index);
                  }
                : null,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: _deviceWidth * 0.1,
          child: (isLeft && (widgetState.state.status != QuickSortStatus.None)) 
            ? const Text('Left', style: TextStyle(color: Colors.blue))
            : (isRight && (widgetState.state.status != QuickSortStatus.None)) 
              ? const Text('Right', style: TextStyle(color: Colors.orange))
              : const Text('')
        )
      ],
    );
  }

  @override
  void onAutoMode() {
    // TODO: implement onAutoMode
  }

  @override
  void onDurationChange(int value) => _cubitContext.read<QuickSortCubit>().onDurationChange(value);

  @override
  Future<void> onPlay() async {
    return await _cubitContext.read<QuickSortCubit>().onPlay();
  }

  @override
  void onRemoveItem(int index) {
    // TODO: implement onRemoveItem
  }

  @override
  void onStepBack() {
    // TODO: implement onStepBack
  }

  @override
  Future<void> onStepByStepMode() {
    // TODO: implement onStepByStepMode
    throw UnimplementedError();
  }

  @override
  void onStepForward() {
    // TODO: implement onStepForward
  }

  @override
  void onStop() {
    // TODO: implement onStop
  }
}