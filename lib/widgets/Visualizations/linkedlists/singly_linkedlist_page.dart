import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doubly_linkedlist_page.dart';

class Node {
  int data;
  Node? next;
  Node(this.data);
}

class LinkedList {
  Node? head;
  int length = 0;

  void insertAtHead(int data) {
    Node newNode = Node(data);
    newNode.next = head;
    head = newNode;
    length++;
  }

  void insertAtTail(int data) {
    if (head == null) {
      insertAtHead(data);
    } else {
      Node current = head!;
      while (current.next != null) {
        current = current.next!;
      }
      current.next = Node(data);
      length++;
    }
  }

  void insertAtPosition(int data, int index) {
    if (index < 0 || index > length) {
      throw RangeError('Index $index is out of bounds');
    }
    if (index == 0) {
      insertAtHead(data);
      return;
    }
    if (index == length) {
      insertAtTail(data);
      return;
    }

    Node current = head!;
    for (int i = 0; i < index - 1; i++) {
      current = current.next!;
    }
    Node newNode = Node(data);
    newNode.next = current.next;
    current.next = newNode;
    length++;
  }

  bool deleteFromHead() {
    if (head == null) return false;
    head = head!.next;
    length--;
    return true;
  }

  bool deleteFromTail() {
    if (head == null) return false;
    if (length == 1) {
      head = null;
      length--;
      return true;
    }

    Node current = head!;
    while (current.next!.next != null) {
      current = current.next!;
    }
    current.next = null;
    length--;
    return true;
  }

  bool deleteAtPosition(int index) {
    if (index < 0 || index >= length || head == null) return false;
    if (index == 0) return deleteFromHead();
    if (index == length - 1) return deleteFromTail();

    Node current = head!;
    for (int i = 0; i < index - 1; i++) {
      current = current.next!;
    }
    current.next = current.next!.next;
    length--;
    return true;
  }

  bool deleteByValue(int value) {
    if (head == null) return false;

    if (head!.data == value) {
      return deleteFromHead();
    }

    Node current = head!;
    while (current.next != null) {
      if (current.next!.data == value) {
        current.next = current.next!.next;
        length--;
        return true;
      }
      current = current.next!;
    }
    return false;
  }

  int? searchByValue(int value) {
    Node? current = head;
    int index = 0;
    while (current != null) {
      if (current.data == value) return index;
      current = current.next;
      index++;
    }
    return null;
  }

  int? getValueAtIndex(int index) {
    if (index < 0 || index >= length || head == null) return null;
    Node current = head!;
    for (int i = 0; i < index; i++) {
      current = current.next!;
    }
    return current.data;
  }

  void clear() {
    head = null;
    length = 0;
  }

  List<int> toList() {
    List<int> result = [];
    Node? current = head;
    while (current != null) {
      result.add(current.data);
      current = current.next;
    }
    return result;
  }
}

class SinglyLinkedListVisualization extends StatefulWidget {
  const SinglyLinkedListVisualization({super.key});

  @override
  State<SinglyLinkedListVisualization> createState() =>
      _SinglyLinkedListVisualizationState();
}

class _SinglyLinkedListVisualizationState extends State<SinglyLinkedListVisualization> {
  LinkedList linkedList = LinkedList();
  static const Duration _traversalStepDelay = Duration(milliseconds: 800);
  static const Duration _postTraversalPause = Duration(milliseconds: 420);
  static const Duration _highlightHoldDuration = Duration(milliseconds: 1100);
  static const Duration _settleHighlightHold = Duration(milliseconds: 900);
  static const Duration _searchHighlightHold = Duration(milliseconds: 1400);

  LinkedListDeviceInfo? _getDeviceInfo(BuildContext context) {
    try {
      return LinkedListDeviceInfo.of(context);
    } catch (e) {
      return null;
    }
  }

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _indexController = TextEditingController();
  final TextEditingController _deleteValueController = TextEditingController();
  final TextEditingController _deleteIndexController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String insertionType = 'Head';
  String deletionType = 'By Value';
  String searchType = 'By Value';

  int? highlightedIndex;
  List<String> operationHistory = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _valueController.addListener(_updateButtonState);
    _indexController.addListener(_updateButtonState);
    _deleteValueController.addListener(_updateButtonState);
    _deleteIndexController.addListener(_updateButtonState);
    _searchController.addListener(_updateButtonState);

    linkedList.insertAtHead(1);
    linkedList.insertAtTail(2);
    linkedList.insertAtTail(3);
    linkedList.insertAtTail(4);
    linkedList.insertAtTail(5);
  }

  @override
  void dispose() {
    _valueController.dispose();
    _indexController.dispose();
    _deleteValueController.dispose();
    _deleteIndexController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addToHistory(String operation) {
    setState(() {
      operationHistory.insert(0, '${operationHistory.length + 1}. $operation');
      if (operationHistory.length > 10) {
        operationHistory.removeLast();
      }
    });
  }

  void _updateButtonState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: MediaQuery.of(context).size.width * 0.35,
          right: MediaQuery.of(context).size.width * 0.35,
          bottom: MediaQuery.of(context).size.height - 100,
        ),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 20,
        dismissDirection: DismissDirection.up,
      ),
    );
  }

  Future<void> _animateTraversal(int targetIndex) async {
    if (!mounted || linkedList.length == 0 || targetIndex < 0) {
      return;
    }

    final int clampedTarget = targetIndex.clamp(0, linkedList.length - 1);
    for (int i = 0; i <= clampedTarget && i < linkedList.length; i++) {
      if (!mounted) return;
      setState(() => highlightedIndex = i);
      await Future.delayed(_traversalStepDelay);
    }
  }

  Future<void> _animateFullTraversal() async {
    if (!mounted || linkedList.length == 0) {
      return;
    }

    for (int i = 0; i < linkedList.length; i++) {
      if (!mounted) return;
      setState(() => highlightedIndex = i);
      await Future.delayed(_traversalStepDelay);
    }
  }

  Future<void> _highlightNodeOnce(int index, {Duration? hold}) async {
    if (!mounted) return;

    if (linkedList.length == 0) {
      setState(() => highlightedIndex = null);
      return;
    }

    final int clampedIndex = index.clamp(0, linkedList.length - 1);
    setState(() => highlightedIndex = clampedIndex);
    final Duration effectiveHold = hold ?? _highlightHoldDuration;
    await Future.delayed(effectiveHold);
    if (!mounted) return;
    setState(() => highlightedIndex = null);
  }

  bool _isInsertButtonEnabled() {
    if (_isAnimating) return false;
    if (_valueController.text.isEmpty) return false;
    if (insertionType == 'Position' && _indexController.text.isEmpty)
      return false;
    return true;
  }

  bool _isDeleteButtonEnabled() {
    if (_isAnimating) return false;
    if (linkedList.length == 0) return false;
    if (deletionType == 'By Value' && _deleteValueController.text.isEmpty)
      return false;
    if (deletionType == 'By Position' && _deleteIndexController.text.isEmpty)
      return false;
    return true;
  }

  bool _isSearchButtonEnabled() {
    if (_isAnimating) return false;
    return _searchController.text.isNotEmpty;
  }

  Future<void> _performInsertion() async {
    if (_isAnimating) return;
    if (_valueController.text.isEmpty) return;

    final int? value = int.tryParse(_valueController.text);
    if (value == null) {
      _showErrorMessage('❌ Please enter a valid number');
      return;
    }

    final int originalLength = linkedList.length;
    int traverseUntil = -1;
    int targetIndex = 0;
    String historyMessage = '';

    if (insertionType == 'Head') {
      traverseUntil = originalLength > 0 ? 0 : -1;
      targetIndex = 0;
      historyMessage = 'Inserted $value at head';
    } else if (insertionType == 'Tail') {
      traverseUntil = originalLength > 0 ? originalLength - 1 : -1;
      targetIndex = originalLength;
      historyMessage = 'Inserted $value at tail';
    } else {
      if (_indexController.text.isEmpty) return;
      final int? index = int.tryParse(_indexController.text);
      if (index == null) {
        _showErrorMessage('❌ Please enter a valid index');
        return;
      }
      if (index < 0 || index > originalLength) {
        _showErrorMessage('❌ Position must be between 0 and $originalLength');
        return;
      }
      traverseUntil = index == 0 ? -1 : index - 1;
      targetIndex = index;
      historyMessage = 'Inserted $value at position $index';
    }

    _isAnimating = true;
    try {
      if (traverseUntil >= 0 && linkedList.length > 0) {
        await _animateTraversal(traverseUntil);
        await Future.delayed(_postTraversalPause);
      }

      setState(() {
        if (insertionType == 'Head') {
          linkedList.insertAtHead(value);
        } else if (insertionType == 'Tail') {
          linkedList.insertAtTail(value);
        } else {
          linkedList.insertAtPosition(value, targetIndex);
        }
      });

      _addToHistory(historyMessage);

      if (linkedList.length > 0) {
        await _highlightNodeOnce(targetIndex);
      }
    } catch (e) {
      _showErrorMessage('❌ Insertion failed');
    } finally {
      _isAnimating = false;
      if (mounted) {
        setState(() => highlightedIndex = null);
      }
    }

    _valueController.clear();
    _indexController.clear();
  }

  Future<void> _performDeletion() async {
    if (_isAnimating) return;
    if (linkedList.length == 0) return;

    _isAnimating = true;
    try {
      switch (deletionType) {
        case 'By Value':
          if (_deleteValueController.text.isEmpty) {
            return;
          }
          final int? value = int.tryParse(_deleteValueController.text);
          if (value == null) {
            _showErrorMessage('❌ Please enter a valid number');
            return;
          }
          final int? deletedIndex = linkedList.searchByValue(value);
          if (deletedIndex == null) {
            _addToHistory('Delete failed: value $value not found');
            _showErrorMessage('❌ Value $value not found in the list');
            return;
          }

          await _animateTraversal(deletedIndex);
          await Future.delayed(_postTraversalPause);

          setState(() {
            linkedList.deleteByValue(value);
          });
          _addToHistory('Deleted value $value from list');

          if (linkedList.length > 0) {
            final int settleIndex =
                deletedIndex >= linkedList.length
                    ? linkedList.length - 1
                    : deletedIndex;
            if (settleIndex >= 0) {
              await _highlightNodeOnce(settleIndex, hold: _settleHighlightHold);
            }
          }
          break;
        case 'By Position':
          if (_deleteIndexController.text.isEmpty) {
            return;
          }
          final int? index = int.tryParse(_deleteIndexController.text);
          if (index == null) {
            _showErrorMessage('❌ Please enter a valid index');
            return;
          }
          if (index < 0 || index >= linkedList.length) {
            final String rangeMessage =
                linkedList.length == 0
                    ? 'the list is currently empty'
                    : 'valid range: 0-${linkedList.length - 1}';
            _addToHistory('Delete failed: position $index out of bounds');
            _showErrorMessage(
              '❌ Position $index is out of bounds ($rangeMessage)',
            );
            return;
          }

          await _animateTraversal(index);
          await Future.delayed(_postTraversalPause);

          setState(() {
            linkedList.deleteAtPosition(index);
          });
          _addToHistory('Deleted from position $index');

          if (linkedList.length > 0) {
            final int settleIndex =
                index >= linkedList.length ? linkedList.length - 1 : index;
            if (settleIndex >= 0) {
              await _highlightNodeOnce(settleIndex, hold: _settleHighlightHold);
            }
          }
          break;
      }
    } catch (e) {
      _showErrorMessage('❌ Deletion failed');
    } finally {
      _isAnimating = false;
      if (mounted) {
        setState(() => highlightedIndex = null);
      }
    }

    _deleteValueController.clear();
    _deleteIndexController.clear();
  }

  Future<void> _performSearch() async {
    if (_isAnimating) return;
    if (_searchController.text.isEmpty) return;

    _isAnimating = true;
    try {
      switch (searchType) {
        case 'By Value':
          final int? value = int.tryParse(_searchController.text);
          if (value == null) {
            _showErrorMessage('❌ Please enter a valid number');
            return;
          }

          final int? foundIndex = linkedList.searchByValue(value);
          if (foundIndex != null) {
            await _animateTraversal(foundIndex);
            _addToHistory('Found value $value at index $foundIndex');
            await _highlightNodeOnce(foundIndex, hold: _searchHighlightHold);
          } else {
            await _animateFullTraversal();
            _addToHistory('Search failed: value $value not found');
            _showErrorMessage('🔍 Value $value not found in the list');
          }
          break;
        case 'By Index':
          final int? index = int.tryParse(_searchController.text);
          if (index == null) {
            _showErrorMessage('❌ Please enter a valid index');
            return;
          }

          if (index < 0 || index >= linkedList.length) {
            await _animateFullTraversal();
            final String rangeMessage =
                linkedList.length == 0
                    ? 'the list is currently empty'
                    : 'valid range: 0-${linkedList.length - 1}';
            _addToHistory('Search failed: index $index out of bounds');
            _showErrorMessage(
              '🔍 Index $index is out of bounds ($rangeMessage)',
            );
            return;
          }

          final int? value = linkedList.getValueAtIndex(index);
          await _animateTraversal(index);
          if (value != null) {
            _addToHistory('Found at index $index: value $value');
            await _highlightNodeOnce(index, hold: _searchHighlightHold);
          }
          break;
      }
    } catch (e) {
      _showErrorMessage('❌ Search failed');
    } finally {
      _isAnimating = false;
      if (mounted) {
        setState(() => highlightedIndex = null);
      }
    }

    _searchController.clear();
  }

  void _resetList() {
    linkedList.clear();
    setState(() {
      highlightedIndex = null;
      operationHistory.clear();
    });
    _addToHistory('Singly LinkedList reset - all data cleared');
  }

  Future<void> _generateRandomNodes() async {
    if (_isAnimating) return;

    _isAnimating = true;
    final random = Random();
    final values = List<int>.generate(5, (_) => random.nextInt(90) + 10);

    setState(() {
      linkedList.clear();
      highlightedIndex = null;
    });

    try {
      for (int i = 0; i < values.length; i++) {
        setState(() {
          linkedList.insertAtTail(values[i]);
        });
        await _highlightNodeOnce(i);
        if (i < values.length - 1) {
          await Future.delayed(_postTraversalPause);
        }
      }

      _addToHistory('Generated 5 random nodes: ${values.join(', ')}');
    } catch (e) {
      _showErrorMessage('❌ Random populate failed');
    } finally {
      _isAnimating = false;
      if (mounted) {
        setState(() => highlightedIndex = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get linked list device info from the inherited widget
    final linkedListDeviceInfo = _getDeviceInfo(context);
    
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isSmallScreen = linkedListDeviceInfo?.isMobile ?? screenWidth < 600;
    final isMediumScreen = linkedListDeviceInfo?.isTablet ?? (screenWidth >= 600 && screenWidth < 900);
    final isLargeScreen = linkedListDeviceInfo?.isDesktop ?? screenWidth >= 900;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    final horizontalPadding = linkedListDeviceInfo?.responsivePadding ?? (isSmallScreen ? 8.0 : (isMediumScreen ? 16.0 : 24.0));
    final verticalPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    
    final adjustForLandscape = isSmallScreen && isLandscape;
    final useCompactLayout = isSmallScreen || (isMediumScreen && isPortrait);
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: _buildResponsiveAppBar(context, isSmallScreen, isMediumScreen),
        body: SafeArea(
          child: adjustForLandscape 
            ? _buildLandscapeLayout(horizontalPadding, verticalPadding, isSmallScreen, isMediumScreen, isLargeScreen)
            : useCompactLayout
              ? _buildPortraitLayout(horizontalPadding, verticalPadding, isSmallScreen, isMediumScreen, isLargeScreen)
              : _buildPortraitLayout(horizontalPadding, verticalPadding, isSmallScreen, isMediumScreen, isLargeScreen),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double horizontalPadding, double verticalPadding, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVisualizationContainer(isSmallScreen, isMediumScreen),
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildButtonRow(isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 20),
          _buildOperationsColumn(context, isSmallScreen, isMediumScreen, isLargeScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(double horizontalPadding, double verticalPadding, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding / 2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildVisualizationContainer(isSmallScreen, isMediumScreen),
                SizedBox(height: isSmallScreen ? 6 : 8),
                _buildButtonRow(isSmallScreen),
              ],
            ),
          ),
          SizedBox(width: horizontalPadding),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: _buildOperationsColumn(context, isSmallScreen, isMediumScreen, isLargeScreen),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(BuildContext context, bool isSmallScreen, bool isMediumScreen) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Expanded(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  isSmallScreen ? 'Singly LinkedList' : 'Singly LinkedList Visualizer',
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                  ),
                  speed: const Duration(milliseconds: 180),
                  cursor: '|',
                ),
              ],
              repeatForever: true,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .then()
            .shimmer(
              duration: 1500.ms,
              color: const Color(0xFF3B82F6).withOpacity(0.3),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E293B),
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
          child: _buildNavButtons(isSmallScreen),
        ),
      ],
    );
  }

  Widget _buildNavButtons(bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isVerySmallScreen = screenWidth < 400;
        final isReallySmallScreen = screenWidth < 600;
        
        // Determine sizing based on screen size
        final fontSize = isVerySmallScreen ? 8.0 : (isReallySmallScreen ? 9.0 : 11.0);
        final horizontalPadding = isVerySmallScreen ? 8.0 : (isReallySmallScreen ? 12.0 : 16.0);
        final verticalPadding = isVerySmallScreen ? 10.0 : (isReallySmallScreen ? 14.0 : 18.0);
        final borderRadius = isVerySmallScreen ? 8.0 : 12.0;
        if (isVerySmallScreen && screenWidth < 350) {
          return PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white, size: isVerySmallScreen ? 18 : 20),
            onSelected: (value) {
              if (value == 'doubly') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ResponsiveWrapper(
                      child: DoublyLinkedListVisualization(),
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'singly',
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.deepPurple, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Singly LinkedList',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'doubly',
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Doubly LinkedList',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Singly LinkedList',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ResponsiveWrapper(
                      child: DoublyLinkedListVisualization(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Doubly LinkedList',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: const Color.fromARGB(180, 0, 0, 0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonRow(bool isSmallScreen) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: isSmallScreen ? 8 : 12,
      runSpacing: 8,
      children: [
        _buildAutoFillButton(isSmallScreen),
        _buildResetButton(isSmallScreen),
      ],
    );
  }

  Widget _buildOperationsColumn(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    final linkedListDeviceInfo = _getDeviceInfo(context);
    
    final useCompactLayout = linkedListDeviceInfo?.isMobile ?? isSmallScreen;
    final useTabletLayout = linkedListDeviceInfo?.isTablet ?? isMediumScreen;
    final useDesktopLayout = linkedListDeviceInfo?.isDesktop ?? isLargeScreen;
    
    if (useCompactLayout) {
      return Column(
        children: [
          Column(
            children: [
              _buildInsertionBox(isSmallScreen),
              const SizedBox(height: 12),
              _buildDeletionBox(isSmallScreen),
              const SizedBox(height: 12),
              _buildSearchBox(isSmallScreen),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryBox(isSmallScreen),
        ],
      );
    } else if (useTabletLayout) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildInsertionBox(isSmallScreen)),
                const SizedBox(width: 8),
                Expanded(child: _buildDeletionBox(isSmallScreen)),
                const SizedBox(width: 8),
                Expanded(child: _buildSearchBox(isSmallScreen)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildHistoryBox(isSmallScreen),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: useDesktopLayout ? 3 : 3,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _buildInsertionBox(isSmallScreen)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDeletionBox(isSmallScreen)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSearchBox(isSmallScreen)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildHistoryBox(isSmallScreen)),
        ],
      );
    }
  }

  Widget _buildVisualizationContainer(bool isSmallScreen, bool isMediumScreen) {
    // Safely get linked list device info for enhanced responsiveness
    final linkedListDeviceInfo = _getDeviceInfo(context);
    
    // Use LinkedListDeviceInfo responsive dimensions or fallback
    final containerPadding = linkedListDeviceInfo?.responsivePadding ?? (isSmallScreen ? 12.0 : (isMediumScreen ? 18.0 : 25.0));
    final titleFontSize = linkedListDeviceInfo?.responsiveFontSize ?? (isSmallScreen ? 14.0 : (isMediumScreen ? 17.0 : 20.0));
    final badgeFontSize = isSmallScreen ? 10.0 : 12.0;
    final visualizationHeight = isSmallScreen ? 100.0 : 120.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
        border: Border.all(color: const Color(0xFF334155), width: isSmallScreen ? 1 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: isSmallScreen ? 8 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVisualizationHeader(isSmallScreen, titleFontSize, badgeFontSize),
          SizedBox(height: isSmallScreen ? 15 : 25),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: visualizationHeight,
              minHeight: isSmallScreen ? 80 : 100,
            ),
            child: _buildLinkedListVisualization(isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationHeader(bool isSmallScreen, double titleFontSize, double badgeFontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Singly LinkedList Structure',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 10 : 12,
            vertical: isSmallScreen ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
          ),
          child: Text(
            'Length: ${linkedList.length}',
            style: GoogleFonts.inter(
              fontSize: badgeFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedListVisualization(bool isSmallScreen) {
    if (linkedList.length == 0) {
      return Center(
        child: Text(
          'Empty Singly LinkedList\nAdd some nodes to see the visualization',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    List<int> values = linkedList.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // HEAD label
          _buildPointer('HEAD', const Color(0xFF10B981), isSmallScreen),
          _buildArrow(isSmallScreen),

          // Nodes
          ...values.asMap().entries.map((entry) {
            int index = entry.key;
            int value = entry.value;
            bool isHighlighted = highlightedIndex == index;

            return Row(
              children: [
                _buildNode(value, isHighlighted, index, isSmallScreen),
                if (index < values.length - 1) _buildArrow(isSmallScreen),
              ],
            );
          }),

          // Arrow to NULL
          _buildArrow(isSmallScreen),
          _buildPointer('NULL', const Color(0xFFEF4444), isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildNode(int value, bool isHighlighted, int index, bool isSmallScreen) {
    final nodeSize = isSmallScreen ? 50.0 : 70.0;
    final fontSize = isSmallScreen ? 14.0 : 18.0;
    final indexFontSize = isSmallScreen ? 9.0 : 10.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isHighlighted
                        ? [const Color(0xFFEAB308), const Color(0xFFF59E0B)]
                        : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              boxShadow: [
                BoxShadow(
                  color: (isHighlighted
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF3B82F6))
                      .withOpacity(0.4),
                  blurRadius: isHighlighted ? (isSmallScreen ? 12 : 20) : (isSmallScreen ? 4 : 8),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),
          Text(
            '[$index]',
            style: GoogleFonts.inter(
              fontSize: indexFontSize,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(bool isSmallScreen) {
    final arrowWidth = isSmallScreen ? 15.0 : 20.0;
    final iconSize = isSmallScreen ? 12.0 : 16.0;
    final bottomMargin = isSmallScreen ? 15.0 : 20.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Row(
        children: [
          Container(
                width: arrowWidth,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleX(
                duration: 1200.ms,
                begin: 0.9,
                end: 1.1,
                curve: Curves.easeInOut,
              )
              .shimmer(
                duration: 2000.ms,
                color: const Color(0xFF3B82F6).withOpacity(0.35),
              ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Icon(Icons.arrow_forward, color: const Color(0xFF64748B), size: iconSize)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .slideX(
                duration: 1200.ms,
                begin: -0.15,
                end: 0.15,
                curve: Curves.easeInOut,
              )
              .then()
              .shimmer(
                duration: 2200.ms,
                color: const Color(0xFF3B82F6).withOpacity(0.45),
              ),
        ],
      ),
    );
  }

  Widget _buildPointer(String label, Color color, bool isSmallScreen) {
    final fontSize = isSmallScreen ? 9.0 : 11.0;
    final padding = isSmallScreen ? 6.0 : 8.0;
    final verticalPadding = isSmallScreen ? 3.0 : 4.0;
    final bottomMargin = isSmallScreen ? 15.0 : 20.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: isSmallScreen ? 4 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInsertionBox(bool isSmallScreen) {
    // Get linked list device info for enhanced responsiveness
    final linkedListDeviceInfo = _getDeviceInfo(context);
    
    // Use LinkedListDeviceInfo responsive dimensions or fallback
    final boxPadding = linkedListDeviceInfo?.responsivePadding ?? (isSmallScreen ? 8.0 : 12.0);
    final titleFontSize = linkedListDeviceInfo?.responsiveFontSize ?? (isSmallScreen ? 12.0 : 14.0);
    final iconSize = linkedListDeviceInfo?.responsiveIconSize ?? (isSmallScreen ? 14.0 : 18.0);
    
    // Add horizontal margin for mobile to prevent full width stretching
    final horizontalMargin = isSmallScreen ? 16.0 : 0.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(boxPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: isSmallScreen ? 4 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle, color: Colors.white, size: iconSize),
              SizedBox(width: isSmallScreen ? 4 : 6),
              Flexible(
                child: Text(
                  'Insert',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Dropdown
          _buildDropdown(
            value: insertionType,
            items: ['Head', 'Tail', 'Position'],
            onChanged: (value) => setState(() => insertionType = value!),
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Value input
          _buildTextField(
            controller: _valueController,
            hint: 'Enter value',
            icon: Icons.numbers,
            isSmallScreen: isSmallScreen,
          ),

          // Index input (only for position)
          if (insertionType == 'Position') ...[
            SizedBox(height: isSmallScreen ? 4 : 8),
            _buildTextField(
              controller: _indexController,
              hint: 'Enter position',
              icon: Icons.location_on,
              isSmallScreen: isSmallScreen,
            ),
          ],

          SizedBox(height: isSmallScreen ? 4 : 8),
          _buildActionButton(
            'Insert',
            _isInsertButtonEnabled() ? _performInsertion : null,
            Colors.white,
            const Color(0xFF047857),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDeletionBox(bool isSmallScreen) {
    // Get linked list device info for enhanced responsiveness
    final linkedListDeviceInfo = _getDeviceInfo(context);
    
    // Use LinkedListDeviceInfo responsive dimensions or fallback
    final boxPadding = linkedListDeviceInfo?.responsivePadding ?? (isSmallScreen ? 8.0 : 12.0);
    final titleFontSize = linkedListDeviceInfo?.responsiveFontSize ?? (isSmallScreen ? 12.0 : 14.0);
    final iconSize = linkedListDeviceInfo?.responsiveIconSize ?? (isSmallScreen ? 14.0 : 18.0);
    
    final horizontalMargin = isSmallScreen ? 16.0 : 0.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(boxPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.2),
            blurRadius: isSmallScreen ? 4 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_circle, color: Colors.white, size: iconSize),
              SizedBox(width: isSmallScreen ? 4 : 6),
              Flexible(
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Dropdown
          _buildDropdown(
            value: deletionType,
            items: ['By Value', 'By Position'],
            onChanged: (value) => setState(() => deletionType = value!),
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Value input (only for By Value)
          if (deletionType == 'By Value') ...[
            _buildTextField(
              controller: _deleteValueController,
              hint: 'Enter value to delete',
              icon: Icons.numbers,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
          ],

          // Index input (only for By Position)
          if (deletionType == 'By Position') ...[
            _buildTextField(
              controller: _deleteIndexController,
              hint: 'Enter position to delete',
              icon: Icons.location_on,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
          ],

          SizedBox(height: isSmallScreen ? 4 : 8),
          _buildActionButton(
            'Delete',
            _isDeleteButtonEnabled() ? _performDeletion : null,
            Colors.white,
            const Color(0xFFB91C1C),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(bool isSmallScreen) {
    // Get linked list device info for enhanced responsiveness
    final linkedListDeviceInfo = _getDeviceInfo(context);
    
    // Use LinkedListDeviceInfo responsive dimensions or fallback
    final boxPadding = linkedListDeviceInfo?.responsivePadding ?? (isSmallScreen ? 8.0 : 12.0);
    final titleFontSize = linkedListDeviceInfo?.responsiveFontSize ?? (isSmallScreen ? 12.0 : 14.0);
    final iconSize = linkedListDeviceInfo?.responsiveIconSize ?? (isSmallScreen ? 14.0 : 18.0);
    
    // Add horizontal margin for mobile to prevent full width stretching
    final horizontalMargin = isSmallScreen ? 16.0 : 0.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(boxPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            blurRadius: isSmallScreen ? 4 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: Colors.white, size: iconSize),
              SizedBox(width: isSmallScreen ? 4 : 6),
              Flexible(
                child: Text(
                  'Search',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Dropdown
          _buildDropdown(
            value: searchType,
            items: ['By Value', 'By Index'],
            onChanged: (value) => setState(() => searchType = value!),
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Search input
          _buildTextField(
            controller: _searchController,
            hint:
                searchType == 'By Value'
                    ? 'Enter value to find'
                    : 'Enter index to check',
            icon: searchType == 'By Value' ? Icons.numbers : Icons.location_on,
            isSmallScreen: isSmallScreen,
          ),

          SizedBox(height: isSmallScreen ? 4 : 8),
          _buildActionButton(
            'Search',
            _isSearchButtonEnabled() ? _performSearch : null,
            Colors.white,
            const Color(0xFF6D28D9),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isSmallScreen,
  }) {
    // Enhanced mobile-first responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;
    
    final fontSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 15.0 : 14.0);
    final padding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 12.0);
    final verticalPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 4.0);
    final borderRadius = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 8.0);
    
    return Container(
      height: isSmallScreen ? 48.0 : 56.0, // Fixed height for consistency
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          style: GoogleFonts.inter(
            color: Colors.white, 
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.arrow_drop_down, 
            color: Colors.white,
            size: isSmallScreen ? 24.0 : 20.0,
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item, 
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    // Enhanced mobile-first responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;
    
    final fontSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 15.0 : 14.0);
    final padding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 12.0);
    final iconSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 22.0 : 20.0);
    final borderRadius = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 8.0);
    
    return Container(
      height: isSmallScreen ? 48.0 : 56.0, // Fixed height for consistency
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.inter(
          color: Colors.white, 
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontSize: fontSize,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: iconSize,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: isSmallScreen ? 12.0 : 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback? onPressed,
    Color textColor,
    Color bgColor,
    bool isSmallScreen,
  ) {
    // Enhanced mobile-first responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;
    
    final fontSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 15.0 : 12.0);
    final buttonHeight = isVerySmallScreen ? 44.0 : (isSmallScreen ? 48.0 : 32.0);
    final borderRadius = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 6.0);
    
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            onPressed != null ? textColor : Colors.white.withOpacity(0.3),
        foregroundColor:
            onPressed != null ? bgColor : Colors.white.withOpacity(0.8),
        elevation: onPressed != null ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );

    return SizedBox(width: double.infinity, height: buttonHeight, child: button)
        .animate(target: onPressed != null ? 1 : 0)
        .scale(duration: 200.ms, curve: Curves.easeOut)
        .shimmer(
          duration: 1500.ms,
          color:
              onPressed != null
                  ? textColor.withOpacity(0.3)
                  : Colors.transparent,
          delay: 500.ms,
        );
  }

  Widget _buildAutoFillButton(bool isSmallScreen) {
    final bool disabled = _isAnimating;
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final horizontalPadding = isSmallScreen ? 12.0 : 22.0;
    final verticalPadding = isSmallScreen ? 8.0 : 10.0;
    final buttonText = 'Generate Random numbers';

    final baseButton = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: disabled ? null : () => _generateRandomNodes(),
        icon: Icon(Icons.auto_mode, color: Colors.white, size: iconSize),
        label: Text(
          buttonText,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    final animatedButton = baseButton
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          duration: 1800.ms,
          begin: 1.0,
          end: 1.04,
          curve: Curves.easeInOut,
        )
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.18));

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled ? 0.6 : 1.0,
      child: animatedButton,
    );
  }

  Widget _buildResetButton(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final verticalPadding = isSmallScreen ? 8.0 : 10.0;
    
    return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64748B), Color(0xFF475569)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _resetList,
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: iconSize,
            ),
            label: Text(
              'Reset',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          duration: 1500.ms,
          begin: 1.0,
          end: 1.05,
          curve: Curves.easeInOut,
        )
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildHistoryBox(bool isSmallScreen) {
    final linkedListDeviceInfo = _getDeviceInfo(context);
    final boxHeight = isSmallScreen ? 250.0 : 300.0;
    final titleFontSize = linkedListDeviceInfo?.responsiveFontSize ?? (isSmallScreen ? 14.0 : 16.0);
    final iconSize = linkedListDeviceInfo?.responsiveIconSize ?? (isSmallScreen ? 18.0 : 20.0);
    final contentFontSize = isSmallScreen ? 11.0 : 12.0;
    final emptyStateFontSize = isSmallScreen ? 12.0 : 14.0;
    final boxPadding = linkedListDeviceInfo?.responsivePadding ?? (isSmallScreen ? 12.0 : 16.0);
    
    return Container(
      height: boxHeight,
      padding: EdgeInsets.all(boxPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: isSmallScreen ? 4 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: const Color(0xFF64748B), size: iconSize),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Flexible(
                child: Text(
                  'Operations History',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Expanded(
            child:
                operationHistory.isEmpty
                    ? Center(
                      child: Text(
                        'No operations performed yet',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: emptyStateFontSize,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: operationHistory.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                            border: Border.all(
                              color: const Color(0xFF475569).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            operationHistory[index],
                            style: GoogleFonts.inter(
                              color: Colors.grey[300],
                              fontSize: contentFontSize,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

enum LinkedListDeviceType { mobile, tablet, desktop }

class LinkedListDeviceInfo extends InheritedWidget {
  final LinkedListDeviceType deviceType;
  final double screenWidth;
  final double screenHeight;

  const LinkedListDeviceInfo({
    super.key,
    required this.deviceType,
    required this.screenWidth,
    required this.screenHeight,
    required super.child,
  });

  static LinkedListDeviceInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LinkedListDeviceInfo>();
  }

  bool get isMobile => deviceType == LinkedListDeviceType.mobile;
  bool get isTablet => deviceType == LinkedListDeviceType.tablet;
  bool get isDesktop => deviceType == LinkedListDeviceType.desktop;

  double get responsivePadding {
    switch (deviceType) {
      case LinkedListDeviceType.mobile:
        return 8.0;
      case LinkedListDeviceType.tablet:
        return 12.0;
      case LinkedListDeviceType.desktop:
        return 16.0;
    }
  }

  double get responsiveFontSize {
    switch (deviceType) {
      case LinkedListDeviceType.mobile:
        return 12.0;
      case LinkedListDeviceType.tablet:
        return 14.0;
      case LinkedListDeviceType.desktop:
        return 16.0;
    }
  }

  double get responsiveIconSize {
    switch (deviceType) {
      case LinkedListDeviceType.mobile:
        return 16.0;
      case LinkedListDeviceType.tablet:
        return 18.0;
      case LinkedListDeviceType.desktop:
        return 20.0;
    }
  }

  @override
  bool updateShouldNotify(LinkedListDeviceInfo oldWidget) {
    return deviceType != oldWidget.deviceType ||
           screenWidth != oldWidget.screenWidth ||
           screenHeight != oldWidget.screenHeight;
  }
}

class LinkedListResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const LinkedListResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        LinkedListDeviceType deviceType;
        if (screenWidth < 600) {
          deviceType = LinkedListDeviceType.mobile;
        } else if (screenWidth < 900) {
          deviceType = LinkedListDeviceType.tablet;
        } else {
          deviceType = LinkedListDeviceType.desktop;
        }

        return LinkedListDeviceInfo(
          deviceType: deviceType,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          child: child,
        );
      },
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        LinkedListDeviceType deviceType;
        if (screenWidth < 600) {
          deviceType = LinkedListDeviceType.mobile;
        } else if (screenWidth < 900) {
          deviceType = LinkedListDeviceType.tablet;
        } else {
          deviceType = LinkedListDeviceType.desktop;
        }

        return LinkedListDeviceInfo(
          deviceType: deviceType,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          child: child,
        );
      },
    );
  }
}