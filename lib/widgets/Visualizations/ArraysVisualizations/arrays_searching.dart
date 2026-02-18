import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Providers/arrays_operations_provider.dart';
import 'package:nexus/widgets/Visualizations/ArraysVisualizations/arrays_visualization.dart';
import 'package:nexus/widgets/Visualizations/custom_input.dart';
import 'package:provider/provider.dart';

class ArraysSearching extends StatefulWidget{
  const ArraysSearching({super.key});

  @override
  State<ArraysSearching> createState() => _ArraysSearchingState();
}

class _ArraysSearchingState extends State<ArraysSearching> {
   final TextEditingController _linearSearchCrl = TextEditingController();
    final TextEditingController _binarySearchCrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    double screenWidth = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(builder: (_, constraints){
      if(constraints.maxWidth <= 700){
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 15, 26, 33),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 15, 26, 33),
            title: Text("Searching", style: Theme.of(context).textTheme.headlineLarge,),
            actions: [
              SizedBox(width: 12,),
              IconButton(onPressed: (){
                context.read<ArraysOperationsProvider>().resetArray();
              }, icon: Icon(Iconsax.refresh, color: Colors.white,))
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                timeComplexityMethod(textTheme),
                visualizerMethod(screenWidth),
                stepMsgMethod(textTheme),
                algo1Container(textTheme, context),
                algo2Container(textTheme, context)
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 26, 33),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 15, 26, 33),
            title: Text("Searching", style: Theme.of(context).textTheme.headlineLarge,),
            actions: [
              SizedBox(width: 12,),
              IconButton(onPressed: (){
                context.read<ArraysOperationsProvider>().resetArray();
              }, icon: Icon(Iconsax.refresh, color: Colors.white,))
            ],
          ),
        body: Column(
          spacing: 12,
          children: [
            timeComplexityMethod(textTheme),
            visualizerMethod(screenWidth),
           
            Row(
              spacing: 8,
              children: [
                Expanded(child: algo1Container(textTheme, context)),
                Expanded(child: algo2Container(textTheme, context))
              ],
            ),
            SizedBox(
              height:100 ,
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(12),
                child:  stepMsgMethod(textTheme),
              ),
            )
          ],
        ),
      );
    });
  }

  Container algo2Container(TextTheme textTheme, BuildContext context) {
    return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                 gradient: LinearGradient(colors: [ Colors.purple, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.search, color: Colors.white,),
                    title: Text("Binary Search",  style: textTheme.displayMedium),
                  ),
                 CustomOperationInput(valueCtrl: _binarySearchCrl, hintText: "Target", enableBorderColor: const Color.fromARGB(255, 255, 255, 255), focusedBorderColor: Colors.deepOrange,),
                 SizedBox(height: 12,),
                 OutlinedButton(
                   style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(Colors.deepOrangeAccent),
                    elevation: WidgetStatePropertyAll(0)
                  ),
                  onPressed: () async {
                  final provider = context.read<ArraysOperationsProvider>();
                 provider.silentQuickSort();
                  await Future.delayed(Duration(microseconds: 500));
                  provider.binarySearch(int.parse(_binarySearchCrl.text.trim()));
                 }, child: Text("Search"))
                ],
              ),
            );
  }

  Container algo1Container(TextTheme textTheme, BuildContext context) {
    return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.orange, Colors.deepPurple]),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.search, color: Colors.white,),
                    title: Text("Linear Search", style: textTheme.displayMedium,),
                  ),
                 CustomOperationInput(valueCtrl: _linearSearchCrl, hintText: "Target", enableBorderColor: Colors.white, focusedBorderColor: Colors.deepOrange,),
                 SizedBox(height: 12,),
                 OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(Colors.deepOrangeAccent),
                    elevation: WidgetStatePropertyAll(0)
                  ),
                  onPressed: (){
                  context.read<ArraysOperationsProvider>().linearSearch(int.parse(_linearSearchCrl.text.trim()));
                 }, child: Text("Search"))
                ],
              ),
            );
  }

  Consumer<ArraysOperationsProvider> stepMsgMethod(TextTheme textTheme) {
    return Consumer<ArraysOperationsProvider>(builder: (_, provider, _){
              return Text(provider.stepMessage, style: textTheme.displayMedium,);
            });
  }

  Container visualizerMethod(double screenWidth) {
    return Container(
              width: screenWidth,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 2, 41, 59),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Visualizer());
  }

  Consumer<ArraysOperationsProvider> timeComplexityMethod(TextTheme textTheme) {
    return Consumer<ArraysOperationsProvider>(builder: (_, provider, _){
              return Text(provider.timeComplexity, style: textTheme.labelMedium!.copyWith(color: Colors.blue));
            });
  }
}