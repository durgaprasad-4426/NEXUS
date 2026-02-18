import 'package:flutter/material.dart';
import 'package:nexus/widgets/Visualizations/ArraysVisualizations/arrays_searching.dart';
import 'package:nexus/widgets/Visualizations/ArraysVisualizations/arrays_sorting_techniques.dart';
import 'package:nexus/widgets/Visualizations/ArraysVisualizations/arrays_visualization.dart';
import 'package:nexus/widgets/Visualizations/linkedlists/singly_linkedlist_page.dart';
import 'package:nexus/widgets/Visualizations/TreesVisualization/tress_operations_page.dart';
import 'package:nexus/widgets/Visualizations/stack_and_queues/stack_page.dart';
import 'package:nexus/widgets/Visualizations/stack_and_queues/queues_page.dart';

class VisualizationMaps {
  final Map<String, WidgetBuilder> visualizationMap = {
  'C0001':(_)=>ArraysVisualization(),
  'C0002':(_)=>ArraysSortingTechniques(),
  'C0003':(_)=>ArraysSearching(),
  'C0004':(_)=>SinglyLinkedListVisualization(),
  'C0005':(_)=>StackVisualization(),
  'C0006':(_)=>QueueVisualization(),
  'C0007':(_)=>TressOperationsPage(),

};

WidgetBuilder buildVisualization(BuildContext context,  String topicId){
  final builder = visualizationMap[topicId];
  if(builder != null){
    return builder;
  }
  return (_)=>Scaffold(
    backgroundColor: Colors.black,
    body: Center(child: Text("Visualization is underconstruction", 
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),),),);
}
}