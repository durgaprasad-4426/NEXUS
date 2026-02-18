import 'package:flutter/material.dart';
import 'package:nexus/Providers/arrays_operations_provider.dart';
import 'package:nexus/widgets/Visualizations/ArraysVisualizations/arrays_visualization.dart';
import 'package:provider/provider.dart';

class ArraysSortingTechniques extends StatefulWidget{
  const ArraysSortingTechniques({super.key});

  @override
  State<ArraysSortingTechniques> createState() => _ArraysSortingTechniquesState();
}

class _ArraysSortingTechniquesState extends State<ArraysSortingTechniques> {
 
  String selectedSort = "Bubble Sort";
  final List<String> algorithms = [
    "Bubble Sort",
    "Selection Sort",
    "Insertion Sort",
    "Merge Sort",
    "Quick Sort"
  ];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(builder: (_, constraints){
      if(constraints.maxWidth < 700){
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 15, 26, 33),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 15, 26, 33),
            title: Text("Sorting", style: Theme.of(context).textTheme.headlineLarge,),),
          body: SingleChildScrollView(
            child: Column(
              children: [
                timeComplexityMethod(context), 
                visualizerMethod(screenWidth),

                errorAndSuggestionMsgMethod(),
            
                algorithmsMethod(screenWidth),
            
                controlsMethod(screenWidth, context)
            
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor:  const Color.fromARGB(255, 15, 26, 33),
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 15, 26, 33),
            title: Text("Sorting", style: Theme.of(context).textTheme.headlineLarge,),),
         body: Column(
          children: [
            timeComplexityMethod(context),
            visualizerMethod(screenWidth),
            errorAndSuggestionMsgMethod(),
            algorithmsMethod(screenWidth*0.5),
            controlsMethod(screenWidth*0.5, context)
          ],
         ),   

      );
    });
  }

  Align timeComplexityMethod(BuildContext context) {
    return Align(
                alignment: Alignment.topLeft,
                child: Consumer<ArraysOperationsProvider>(builder: (_, provider, _){
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(provider.timeComplexity, style: Theme.of(context).textTheme.labelMedium!.copyWith(color:Colors.blue ),),
                  );
                }),
              );
  }

  Container controlsMethod(double screenWidth, BuildContext context) {
    return Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(12),
                width: screenWidth,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 92, 72, 44),
                   borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.sort_rounded, color: Colors.white,),
                      title: Text("Controls", style: Theme.of(context).textTheme.displayMedium,),
                    ),
                    const SizedBox(height: 8,),
                    customBtn(screenWidth, context, Colors.green, "Start Sorting", (){final provider = context.read<ArraysOperationsProvider>();
                            if(selectedSort == "Bubble Sort")provider.bubbleSort();
                            if(selectedSort == "Selection Sort")provider.selectionSort();
                            if(selectedSort == "Insertion Sort")provider.insertionSort();
                            if(selectedSort == "Merge Sort")provider.mergeSort();
                            if(selectedSort == "Quick Sort")provider.quickSort();}),
                    customBtn(screenWidth, context, Colors.red, "Reset", ()=>context.read<ArraysOperationsProvider>().resetArray()),
                    customBtn(screenWidth, context, Colors.purple, "Shuffle", ()=>context.read<ArraysOperationsProvider>().shuffleArray())
                  ],
                ),
              );
  }

  Container algorithmsMethod(double screenWidth) {
    return Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(12),
                width: screenWidth,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 42, 85, 107),
                   borderRadius: BorderRadius.circular(12)
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: 
                    algorithms.map((algo){
                      return ChoiceChip(
                        iconTheme: IconThemeData(
                          color: Colors.white
                        ),
                        label: Text(algo), 
                        selected: selectedSort == algo, 
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: selectedSort == algo 
                          ? Colors.white
                          : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                        onSelected: (val){
                          setState(() {
                            selectedSort = algo;
                          });
                         
                        },
                        );
                    }).toList()
                  ,
                ),
              );
  }

  Consumer<ArraysOperationsProvider> errorAndSuggestionMsgMethod() => Consumer<ArraysOperationsProvider>(builder: (_, provider, _)=>Text(provider.stepMessage, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),));

  Container visualizerMethod(double screenWidth) {
    return Container(
                width: screenWidth,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 41, 59),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Center(child: Visualizer()));
  }

  SizedBox customBtn(double screenWidth, BuildContext context, Color bgColor, String name, void Function()? onPressed) {
    return SizedBox(
                      width: screenWidth*0.7,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(bgColor),
                            elevation: WidgetStatePropertyAll(0),
                            foregroundColor: WidgetStatePropertyAll(Colors.white),
                            side: WidgetStatePropertyAll(BorderSide.none)
                          ),
                          onPressed: onPressed, child: Text(name)),
                      ),
                    );
  }
}