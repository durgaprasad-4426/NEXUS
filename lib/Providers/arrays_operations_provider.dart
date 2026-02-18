import 'package:flutter/foundation.dart';


class ArrayElement {
  final int id;
  int value;

  ArrayElement({required this.id, required this.value});
}

class ArraysOperationsProvider extends ChangeNotifier {
  int _idCounter = 0;
  late List<ArrayElement> _arr;
   String _stepMessage = "";
   ArraysOperationsProvider(){
    _arr = [
      ArrayElement(id: _idCounter++, value: 23),
      ArrayElement(id: _idCounter++, value: 5),
      ArrayElement(id: _idCounter++, value: 63),
      ArrayElement(id: _idCounter++, value: 0),
      ArrayElement(id: _idCounter++, value: 32),
  ];
   }

  String? _errMsg;
  bool _isError = false;
  int? _highlightIndex;
  int? _currentIndex;
  String _timeComplexity = "";

  List<ArrayElement> get arr => _arr;
  String get stepMessage => _stepMessage;
  String? get errMsg => _errMsg;
  bool get isError => _isError;
  int? get highlightIndex => _highlightIndex;
  int? get currentIndex => _currentIndex;
  String get timeComplexity => _timeComplexity;



  void _setTimeComplexity(String complexity){
    _timeComplexity = complexity;
    notifyListeners();
  }

 
void _setStepMessage(String msg){
  _stepMessage = msg;
  _errMsg = null;
  notifyListeners();
}

 void _clearHighlights() {
     _stepMessage = "";
    _currentIndex = null;
    _highlightIndex = null;
    notifyListeners();
  }


  Future<void> _pause([int ms = 2000]) async =>
      Future.delayed(Duration(milliseconds: ms));

//array methods
  void resetArray() {
    _idCounter = 0;
    _arr = [
       ArrayElement(id: _idCounter++, value: 23),
    ArrayElement(id: _idCounter++, value: 5),
    ArrayElement(id: _idCounter++, value: 63),
    ArrayElement(id: _idCounter++, value: 0),
    ArrayElement(id: _idCounter++, value: 32),
    ];
    notifyListeners();
  }

  void shuffleArray() {
    _arr.shuffle();
    notifyListeners();
  }

  void sortArray(){
    _arr.sort();
    notifyListeners();
  }

  void deleteElementByIndex(int i) async {
  try {
    final removedValue = _arr[i].value; 
    _arr.removeAt(i);

    _isError = false;
    _setStepMessage("Deleted value $removedValue from index $i");
    await _pause();
  } on RangeError catch (_) {
    _isError = true;
    _errMsg = "Error: Index 7 is out of bounds (valid range: 0 to ${_arr.length - 1})";
  }
  notifyListeners();
  _clearHighlights();
}

 void insertElementById(int i, int value) async {
  try {
    if (kIsWeb) {
      if (_arr.length >= 23) {
        throw Exception("Error: Maximum size (23 elements) reached for Web");
      }
      _arr.insert(i, ArrayElement(id: _idCounter++, value: value));
    } else {
      if (_arr.length >= 5) {
        throw Exception("Error: Maximum size (5 elements) reached for Mobile");
      }
      _arr.insert(i, ArrayElement(id: _idCounter++, value: value));
    }

    _isError = false;
    _setStepMessage("Inserted value $value at index $i");
    await _pause();
  } on RangeError {
    _isError = true;
    _errMsg =
        "Error: Index $i is out of bounds (valid range: 0 to ${_arr.length})";
        await _pause();
  } on Exception catch (e) {
    _isError = true;
    _errMsg = e.toString();
    await _pause();
  }

  notifyListeners();
  _clearHighlights();
}



 //sorting algorithms 
  Future<void> bubbleSort() async {
    _setTimeComplexity(
    "Time Complexity: Best: O(n), Avg: O(n²), Worst: O(n²)"
  );
    int n = _arr.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        _currentIndex = j;
        _highlightIndex = j + 1;
        _setStepMessage("Comparing index $j (${_arr[j].value}) and ${j + 1} (${_arr[j + 1].value})");
        
        await _pause();
        if (_arr[j].value > _arr[j + 1].value) {
          final temp = _arr[j];
          _arr[j] = _arr[j + 1];
          _arr[j + 1] = temp;
          _setStepMessage("Swapped index $j and ${j+1}");
          await _pause();
        }
      }
    }
    _clearHighlights();

  }


  Future<void> insertionSort() async {
   _setTimeComplexity("Time Complexity: Best: O(n), Avg: O(n²), Worst: O(n²)");

    int n = _arr.length;
    for (int i = 1; i < n; i++) {
      int key = _arr[i].value;
      int j = i - 1;
      _currentIndex = i;
     _setStepMessage("Picked value $key at index $i");
      await _pause();

      while (j >= 0 && _arr[j].value > key) {
        _arr[j + 1].value = _arr[j].value;
        _highlightIndex = j;
         _setStepMessage("Shifting ${_arr[j].value} from index $j to ${j + 1}");
        j--;
        
        await _pause();
      }
      _arr[j + 1].value = key;
        _setStepMessage("Inserted $key at index ${j + 1}");
      await _pause();
    }
    _clearHighlights();
  }


  Future<void> selectionSort() async {
   _setTimeComplexity("Time Complexity: Best: O(n²), Avg: O(n²), Worst: O(n²)");


    for (int i = 0; i < _arr.length - 1; i++) {
      int minIndex = i;
      _currentIndex = i;
      _setStepMessage("Selecting index $i as current minimum");
      await _pause();

      for (int j = i + 1; j < _arr.length; j++) {
        _highlightIndex = j;
         _setStepMessage("Comparing current min ${_arr[minIndex].value} with index $j (${_arr[j].value})");
         await _pause();
        
        
        if (_arr[j].value < _arr[minIndex].value) {
          minIndex = j;
          _setStepMessage("New minimum found at index $minIndex (${_arr[minIndex].value})");
          await _pause();
        }
      }

      if (minIndex != i) {
        final temp = _arr[i];
        _arr[i] = _arr[minIndex];
        _arr[minIndex] = temp;
         _setStepMessage("Swapped index $i and $minIndex");
      await _pause();
      }
    }
    _clearHighlights();
  }


Future<void> mergeSort() async {
  _setTimeComplexity("Time Complexity: Best: O(n log n), Avg: O(n log n), Worst: O(n log n)");

  Future<void> merge(int left, int mid, int right) async {
    
    List<ArrayElement> leftArr = [
      for (int i = left; i <= mid; i++) ArrayElement(id: _arr[i].id, value: _arr[i].value),
    ];
    List<ArrayElement> rightArr = [
      for (int i = mid + 1; i <= right; i++) ArrayElement(id: _arr[i].id, value: _arr[i].value),
    ];

    int i = 0, j = 0, k = left;

    while (i < leftArr.length && j < rightArr.length) {
      _currentIndex = k;
      _highlightIndex = k;
      _setStepMessage("Comparing ${leftArr[i].value} with ${rightArr[j].value}  (right)");
      await _pause();
      if (leftArr[i].value <= rightArr[j].value) {
        _arr[k] = leftArr[i];
        _setStepMessage("Placing ${leftArr[i].value} at index $k");
        i++;
      } else {
        _arr[k] = rightArr[j];
         _setStepMessage("Placing ${rightArr[j].value} at index $k");
        j++;
      }
      k++;
      notifyListeners();
      await _pause();
    }

    while (i < leftArr.length) {
      if (k < _arr.length) _currentIndex = k;
       _setStepMessage("Placing remaining ${leftArr[i].value} at index $k");
      _arr[k] = leftArr[i];
      i++;
      k++;
      notifyListeners();
      await _pause();
    }

    while (j < rightArr.length) {
      if (k < _arr.length) _currentIndex = k;
      _arr[k] = rightArr[j];
      _setStepMessage("Placing remaining ${rightArr[j].value} at index $k");
      j++;
      k++;
      notifyListeners();
      await _pause();
    }
  }

  Future<void> mergeSortRec(int left, int right) async {
    _setTimeComplexity("Time Complexity: Best: O(n log n), Avg: O(n log n), Worst: O(n²)");

    if (left < right) {
      int mid = (left + right) ~/ 2;
      _setStepMessage("Dividing array: left=$left, mid=$mid, right=$right");
      notifyListeners();
      await _pause();
      await mergeSortRec(left, mid);
      await mergeSortRec(mid + 1, right);
      await merge(left, mid, right);
    }
  }

  await mergeSortRec(0, _arr.length - 1);
  _clearHighlights();

}

  Future<void> quickSort() async {
    Future<int> partition(int low, int high) async {
      int pivot = _arr[high].value;
      _highlightIndex = high;
      _setStepMessage("Pivot selected at index $high with value $pivot");
      await _pause();

      int i = low - 1;

      for (int j = low; j < high; j++) {
        _currentIndex = j;
        _setStepMessage("Comparing index $j (${_arr[j].value}) with pivot $pivot");
        await _pause();

        if (_arr[j].value < pivot) {
          i++;
          final temp = _arr[i];
          _arr[i] = _arr[j];
          _arr[j] = temp;
          _setStepMessage("Swapped index $i and $j");
          await _pause();
        }
      }
      final temp = _arr[i + 1];
      _arr[i + 1] = _arr[high];
      _arr[high] = temp;
      _setStepMessage("Swapped pivot $pivot to index ${i+1}");
      await _pause();
      return i + 1;
    }

    Future<void> quickSortRec(int low, int high) async {
      if (low < high) {
        int pi = await partition(low, high);
        await quickSortRec(low, pi - 1);
        await quickSortRec(pi + 1, high);
      }
    }

    await quickSortRec(0, _arr.length - 1);
    _clearHighlights();
  }

//searching algorithms
Future<void> linearSearch(int target) async {
  _setTimeComplexity("Best: O(1)  Average: O(n) Worst: O(n)");
  for (int i = 0; i < _arr.length; i++) {
    _currentIndex = i;
    _setStepMessage("Checking index $i (value: ${_arr[i].value})");
    await _pause();

    if (_arr[i].value == target) {
      _highlightIndex = i;
      _setStepMessage("Found target $target at index $i");
      await _pause(2000);
      break;
    }
  }

  if (_highlightIndex == null) {
    _setStepMessage("Target $target not found in array");
    await _pause(2000);
  }

   await _pause();
  _clearHighlights();
}

Future<void> binarySearch(int target) async {
  _setTimeComplexity("Best: O(1)  Average: O(log n) Worst: O(log n)");
  int left = 0;
  int right = _arr.length - 1;

  while (left <= right) {
    int mid = left + (right - left) ~/ 2;
    _currentIndex = mid;
    _setStepMessage("Checking middle index $mid (value: ${_arr[mid].value})");
    await _pause();

    if (_arr[mid].value == target) {
      _highlightIndex = mid;
      _setStepMessage("Found target $target at index $mid");
      await _pause(2000);
      break;
    } else if (_arr[mid].value < target) {
      _setStepMessage(
          "Target $target is greater than ${_arr[mid].value}, moving right");
      left = mid + 1;
      await _pause();
    } else {
      _setStepMessage(
          "Target $target is smaller than ${_arr[mid].value}, moving left");
      right = mid - 1;
      await _pause();
    }
  }

  if (_highlightIndex == null) {
    _setStepMessage("Target $target not found in array");
    await _pause(2000);
  }

  await _pause();
  _clearHighlights();
}

void silentQuickSort() {
  _arr.sort((a, b) => a.value.compareTo(b.value));
  notifyListeners(); 
  }


 
}
