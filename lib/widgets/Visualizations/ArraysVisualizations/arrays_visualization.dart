import 'package:flutter/material.dart';
import 'package:nexus/Providers/arrays_operations_provider.dart';
import 'package:nexus/widgets/Visualizations/custom_input.dart';
import 'package:provider/provider.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(this.text,
      {super.key, required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ArraysVisualization extends StatefulWidget{
  const ArraysVisualization({super.key});

  @override
  State<ArraysVisualization> createState() => _ArraysVisualizationState();
}

class _ArraysVisualizationState extends State<ArraysVisualization> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _visualizerKey = GlobalKey();
   late TextEditingController valueInsertCtrl;
   late TextEditingController indexInsertCtrl;
   late TextEditingController indexDeleteCtrl;

   @override
  void initState() {
    super.initState();
    valueInsertCtrl = TextEditingController();
    indexInsertCtrl = TextEditingController();
    indexDeleteCtrl = TextEditingController();
  }

  Future<void>  _scrollToVisualizer() async{
    if(_visualizerKey.currentContext == null) return;
    await Future.delayed(Duration(microseconds: 50));

   await  Scrollable.ensureVisible(
      _visualizerKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.5
    );
  }

  Future<void> selectionSort() async {
     await _scrollToVisualizer();
    await context.read<ArraysOperationsProvider>().selectionSort();
  await _scrollToVisualizer();
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    final List<Widget> operation = [arrayInsertionByIndex(screenWidth*0.3), arrayDeletionByIndex(screenWidth*0.3), arraySorting(screenWidth*0.2)];
   
    return LayoutBuilder(builder: (context, constraints){
      if(constraints.maxWidth <= 700){
        return mobileView(textTheme, screenWidth, screenheight);
      }
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 26, 33),
         appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 15, 26, 33),
      title: GradientText(
    "Arrays",
    gradient: const LinearGradient(
      colors: [Colors.purple, Color.fromARGB(255, 33, 212, 243), Colors.green, ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
  ),),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              visualizationConatiner(screenWidth, screenheight, textTheme),
              Consumer<ArraysOperationsProvider>(builder: (_, provider, _){
                  return Text(provider.isError ? provider.errMsg ?? "" : provider.stepMessage , style: TextStyle(color: provider.isError ?  Colors.red : Colors.white,fontWeight: FontWeight.bold),);
              },),
              Wrap(
                spacing: 12,
                children: List.generate(operation.length, (i){
                  return operation[i] ;
                }),
              )
          
            ],
          ),
        ),
      );
    });
  }

  Scaffold mobileView(TextTheme textTheme, double screenWidth, double screenheight) {
    return Scaffold(
    backgroundColor: const Color.fromARGB(255, 15, 26, 33),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 15, 26, 33),
      title: GradientText(
    "Arrays",
    gradient: const LinearGradient(
      colors: [Colors.purple, Color.fromARGB(255, 33, 212, 243), Colors.green, ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
  ),),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
      
              visualizationConatiner(screenWidth, screenheight, textTheme),
            errorVisibilityMethod(),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: arrayInsertionByIndex(screenWidth),
             ),
             
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: arrayDeletionByIndex(screenWidth),
             ), 
      
             Padding(padding: EdgeInsets.all(12),
             child: arraySorting(screenWidth),)
            ],
          ),
          SizedBox(height: 30,),
          
      
        ],
      ),
    )
  );
  }

  Widget errorVisibilityMethod() {
    return Consumer<ArraysOperationsProvider>(builder: (_, provider, _){
                if(provider.isError){
                  return Text(provider.errMsg ?? "", style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),);
                }
                return Text(provider.stepMessage, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
              },);
  }

  Container arraySorting(double screenWidth) {
    return Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(12),
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurpleAccent, Colors.deepPurple]),
              borderRadius: BorderRadius.circular(12)
            ),
             child: Column(
               children: [
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.sort, color: Colors.white,),
                  title: Text("Sorting", style: TextStyle(color: Colors.white),),
                ),
                 OutlinedButton(
                  style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white), 
                  elevation: WidgetStatePropertyAll(0),
                  foregroundColor: WidgetStatePropertyAll(Colors.red),
                  side: WidgetStatePropertyAll(BorderSide.none)
                                 ),
                  onPressed: (){
                  selectionSort();
                 },
                  child: Text("Sort")),
               ],
             ),
           );
  }

  Container visualizationConatiner(double screenWidth, double screenheight, TextTheme textTheme) {
    return Container(
      key: _visualizerKey,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 34, 79, 110),
                border: Border.all(
                  width: 2,
                  color: Colors.blueGrey
                ), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                children: [
                  Container(
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.all(12),
                              width: screenWidth,
                              height: screenheight*0.3,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:const Color.fromARGB(255, 14, 27, 37),
                                  border: Border.all(width: 2, color: Colors.blueGrey)
                              ),
                              child: Center(child: Visualizer())),
    
                              SizedBox(height: 4,),
                              Text("Length ${context.watch<ArraysOperationsProvider>().arr.length}", style:textTheme.displayMedium ,)
                ],
              ),
            );
  }

  Widget arrayDeletionByIndex(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(12),
      width: screenWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color.fromARGB(255, 174, 31, 31), const Color.fromARGB(255, 97, 31, 26)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 12,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.delete, color: Colors.white,),
                  title: Text("Deletion", style: TextStyle(color: Colors.white),),
                ),
                TextField(
                  style: TextStyle(color: Colors.grey[300]),
                controller: indexDeleteCtrl,
                 decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey[300]),
                 enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 255, 154, 154)),
                  borderRadius: BorderRadius.circular(12)
                 ),
                 focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 86, 106, 221)),
                  borderRadius: BorderRadius.circular(12)
                 ),
                 hintText: "Index"
                                 ),
                              ),
              OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white), 
                  elevation: WidgetStatePropertyAll(0),
                  foregroundColor: WidgetStatePropertyAll(Colors.red),
                  side: WidgetStatePropertyAll(BorderSide.none)
                ),
                onPressed: (){
                int? i = int.tryParse(indexDeleteCtrl.text.trim());
               
                if(i != null){
                  context.read<ArraysOperationsProvider>().deleteElementByIndex(i);
                }
                indexDeleteCtrl.clear();
              }, child: Text("Delete"))
              ],
             ),
    );
  }

  Widget arrayInsertionByIndex(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(12),
      width: screenWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [ const Color.fromARGB(255, 62, 136, 64), const Color.fromARGB(255, 18, 53, 4)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
         spacing: 12,
        children: [
          ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.add, color: Colors.white,),
                  title: Text("Insertion", style: TextStyle(color: Colors.white),),
                ),
      CustomOperationInput(
        valueCtrl: valueInsertCtrl, 
        hintText: "Value", 
        enableBorderColor:const Color.fromARGB(255, 82, 220, 128) , 
        focusedBorderColor: const Color.fromARGB(255, 86, 106, 221)
        ),

        CustomOperationInput(valueCtrl: indexInsertCtrl, hintText: "Index", enableBorderColor: const Color.fromARGB(255, 82, 220, 128), focusedBorderColor: const Color.fromARGB(255, 86, 106, 221)),
     
              OutlinedButton(
                
                 style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white), 
                  elevation: WidgetStatePropertyAll(0),
                  foregroundColor: WidgetStatePropertyAll(Colors.green),
                  side: WidgetStatePropertyAll(BorderSide.none)
                ),
                onPressed: (){
                int? n = int.tryParse(valueInsertCtrl.text.trim());
                int? i = int.tryParse(indexInsertCtrl.text.trim());
                if(n != null && i != null){
                  context.read<ArraysOperationsProvider>().insertElementById(i, n);
                }
                valueInsertCtrl.clear();
                indexInsertCtrl.clear();
              }, child: Text("Add"))
             ],),
    );
  }
}



class Visualizer extends StatelessWidget {
  const Visualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArraysOperationsProvider>(
      builder: (context, provider, _) {
        final arr = provider.arr;

        return SizedBox(
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: arr.asMap().entries.map((entry) {
              int index = entry.key;
              ArrayElement element = entry.value;

              return AnimatedPositioned(
                key: ObjectKey(element),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: index * 60.0,
                top: 20,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.highlightIndex == index
                        ? Colors.green
                        : provider.currentIndex == index
                            ? Colors.red
                            : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    element.value.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
