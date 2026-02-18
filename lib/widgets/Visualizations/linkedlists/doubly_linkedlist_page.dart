import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'singly_linkedlist_page.dart';

class DoublyNode {
  int data;
  DoublyNode? next;
  DoublyNode? prev;

  DoublyNode(this.data);
}

class DoublyLinkedList {
  DoublyNode? head;
  DoublyNode? tail;
  int length = 0;

  void insertAtHead(int data) {
    final DoublyNode newNode = DoublyNode(data);
    newNode.next = head;
    if (head != null) {
      head!.prev = newNode;
    }
    head = newNode;
    tail ??= newNode;
    length++;
  }

  void insertAtTail(int data) {
    if (head == null) {
      insertAtHead(data);
      return;
    }
    final DoublyNode newNode = DoublyNode(data);
    tail!.next = newNode;
    newNode.prev = tail;
    tail = newNode;
    length++;
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

    DoublyNode current = head!;
    for (int i = 0; i < index - 1; i++) {
      current = current.next!;
    }
    final DoublyNode newNode = DoublyNode(data);
    newNode.next = current.next;
    newNode.prev = current;
    current.next!.prev = newNode;
    current.next = newNode;
    length++;
  }

  bool deleteFromHead() {
    if (head == null) return false;
    if (head == tail) {
      head = null;
      tail = null;
      length = 0;
      return true;
    }
    head = head!.next;
    head!.prev = null;
    length--;
    return true;
  }

  bool deleteFromTail() {
    if (tail == null) return false;
    if (head == tail) {
      head = null;
      tail = null;
      length = 0;
      return true;
    }
    tail = tail!.prev;
    tail!.next = null;
    length--;
    return true;
  }

  bool deleteAtPosition(int index) {
    if (index < 0 || index >= length || head == null) return false;
    if (index == 0) return deleteFromHead();
    if (index == length - 1) return deleteFromTail();

    DoublyNode current = head!;
    for (int i = 0; i < index; i++) {
      current = current.next!;
    }
    current.prev!.next = current.next;
    current.next!.prev = current.prev;
    length--;
    return true;
  }

  bool deleteByValue(int value) {
    if (head == null) return false;
    if (head!.data == value) {
      return deleteFromHead();
    }
    DoublyNode? current = head!.next;
    while (current != null) {
      if (current.data == value) {
        if (current.next == null) {
          return deleteFromTail();
        }
        current.prev!.next = current.next;
        current.next!.prev = current.prev;
        length--;
        return true;
      }
      current = current.next;
    }
    return false;
  }

  int? searchByValue(int value) {
    DoublyNode? current = head;
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
    DoublyNode current = head!;
    for (int i = 0; i < index; i++) {
      current = current.next!;
    }
    return current.data;
  }

  void clear() {
    head = null;
    tail = null;
    length = 0;
  }

  List<int> toList() {
    final List<int> values = [];
    DoublyNode? current = head;
    while (current != null) {
      values.add(current.data);
      current = current.next;
    }
    return values;
  }
}

class DoublyLinkedListVisualization extends StatefulWidget {
  const DoublyLinkedListVisualization({super.key});

  @override
  State<DoublyLinkedListVisualization> createState() =>
      _DoublyLinkedListVisualizationState();
}

class _DoublyLinkedListVisualizationState
    extends State<DoublyLinkedListVisualization> {
  final DoublyLinkedList linkedList = DoublyLinkedList();
  static const Duration _traversalStepDelay = Duration(milliseconds: 800);
  static const Duration _postTraversalPause = Duration(milliseconds: 420);
  static const Duration _highlightHoldDuration = Duration(milliseconds: 1100);
  static const Duration _settleHighlightHold = Duration(milliseconds: 900);
  static const Duration _searchHighlightHold = Duration(milliseconds: 1400);

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
    _valueController.addListener(() => setState(() {}));
    _indexController.addListener(() => setState(() {}));
    _deleteValueController.addListener(() => setState(() {}));
    _deleteIndexController.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));

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

  void _addToHistory(String message) {
    setState(() {
      operationHistory.insert(0, '${operationHistory.length + 1}. $message');
      if (operationHistory.length > 10) {
        operationHistory.removeLast();
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 18,
        dismissDirection: DismissDirection.up,
      ),
    );
  }

  Future<void> _animateTraversal(int targetIndex) async {
    if (!mounted || linkedList.length == 0 || targetIndex < 0) return;
    final int clamped = targetIndex.clamp(0, linkedList.length - 1);
    for (int i = 0; i <= clamped && i < linkedList.length; i++) {
      if (!mounted) return;
      setState(() => highlightedIndex = i);
      await Future.delayed(_traversalStepDelay);
    }
  }

  Future<void> _animateFullTraversal() async {
    if (!mounted || linkedList.length == 0) return;
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
    final int clamped = index.clamp(0, linkedList.length - 1);
    setState(() => highlightedIndex = clamped);
    await Future.delayed(hold ?? _highlightHoldDuration);
    if (!mounted) return;
    setState(() => highlightedIndex = null);
  }

  bool _canInsert() {
    if (_isAnimating) return false;
    if (_valueController.text.isEmpty) return false;
    if (insertionType == 'Position' && _indexController.text.isEmpty)
      return false;
    return true;
  }

  bool _canDelete() {
    if (_isAnimating) return false;
    if (linkedList.length == 0) return false;
    if (deletionType == 'By Value' && _deleteValueController.text.isEmpty)
      return false;
    if (deletionType == 'By Position' && _deleteIndexController.text.isEmpty)
      return false;
    return true;
  }

  bool _canSearch() {
    if (_isAnimating) return false;
    return _searchController.text.isNotEmpty;
  }

  Future<void> _performInsertion() async {
    if (!_canInsert()) return;
    final int? value = int.tryParse(_valueController.text);
    if (value == null) {
      _showError('❌ Please enter a valid number');
      return;
    }

    final int originalLength = linkedList.length;
    int traverseUntil = -1;
    int targetIndex = 0;
    String history = '';

    if (insertionType == 'Head') {
      traverseUntil = originalLength > 0 ? 0 : -1;
      targetIndex = 0;
      history = 'Inserted $value at head';
    } else if (insertionType == 'Tail') {
      traverseUntil = originalLength > 0 ? originalLength - 1 : -1;
      targetIndex = originalLength;
      history = 'Inserted $value at tail';
    } else {
      final int? index = int.tryParse(_indexController.text);
      if (index == null) {
        _showError('❌ Please enter a valid index');
        return;
      }
      if (index < 0 || index > originalLength) {
        _showError('❌ Position must be between 0 and $originalLength');
        return;
      }
      traverseUntil = index == 0 ? -1 : index - 1;
      targetIndex = index;
      history = 'Inserted $value at position $index';
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

      _addToHistory(history);
      if (linkedList.length > 0) {
        await _highlightNodeOnce(targetIndex);
      }
    } catch (_) {
      _showError('❌ Insertion failed');
    } finally {
      _isAnimating = false;
      if (mounted) setState(() => highlightedIndex = null);
    }

    _valueController.clear();
    _indexController.clear();
  }

  Future<void> _performDeletion() async {
    if (!_canDelete()) return;
    _isAnimating = true;
    try {
      switch (deletionType) {
        case 'By Value':
          final int? value = int.tryParse(_deleteValueController.text);
          if (value == null) {
            _showError('❌ Please enter a valid number');
            return;
          }
          final int? index = linkedList.searchByValue(value);
          if (index == null) {
            _addToHistory('Delete failed: value $value not found');
            _showError('❌ Value $value not found in the list');
            return;
          }
          await _animateTraversal(index);
          await Future.delayed(_postTraversalPause);
          setState(() {
            linkedList.deleteByValue(value);
          });
          _addToHistory('Deleted value $value from list');
          if (linkedList.length > 0) {
            final int settle =
                index >= linkedList.length ? linkedList.length - 1 : index;
            if (settle >= 0) {
              await _highlightNodeOnce(settle, hold: _settleHighlightHold);
            }
          }
          break;
        case 'By Position':
          final int? index = int.tryParse(_deleteIndexController.text);
          if (index == null) {
            _showError('❌ Please enter a valid index');
            return;
          }
          if (index < 0 || index >= linkedList.length) {
            final String rangeMessage =
                linkedList.length == 0
                    ? 'the list is currently empty'
                    : 'valid range: 0-${linkedList.length - 1}';
            _addToHistory('Delete failed: position $index out of bounds');
            _showError('❌ Position $index is out of bounds ($rangeMessage)');
            return;
          }
          await _animateTraversal(index);
          await Future.delayed(_postTraversalPause);
          setState(() {
            linkedList.deleteAtPosition(index);
          });
          _addToHistory('Deleted from position $index');
          if (linkedList.length > 0) {
            final int settle =
                index >= linkedList.length ? linkedList.length - 1 : index;
            if (settle >= 0) {
              await _highlightNodeOnce(settle, hold: _settleHighlightHold);
            }
          }
          break;
      }
    } catch (_) {
      _showError('❌ Deletion failed');
    } finally {
      _isAnimating = false;
      if (mounted) setState(() => highlightedIndex = null);
    }

    _deleteValueController.clear();
    _deleteIndexController.clear();
  }

  Future<void> _performSearch() async {
    if (!_canSearch()) return;
    _isAnimating = true;
    try {
      switch (searchType) {
        case 'By Value':
          final int? value = int.tryParse(_searchController.text);
          if (value == null) {
            _showError('❌ Please enter a valid number');
            return;
          }
          final int? index = linkedList.searchByValue(value);
          if (index != null) {
            await _animateTraversal(index);
            _addToHistory('Found value $value at index $index');
            await _highlightNodeOnce(index, hold: _searchHighlightHold);
          } else {
            await _animateFullTraversal();
            _addToHistory('Search failed: value $value not found');
            _showError('🔍 Value $value not found in the list');
          }
          break;
        case 'By Index':
          final int? index = int.tryParse(_searchController.text);
          if (index == null) {
            _showError('❌ Please enter a valid index');
            return;
          }
          if (index < 0 || index >= linkedList.length) {
            await _animateFullTraversal();
            final String rangeMessage =
                linkedList.length == 0
                    ? 'the list is currently empty'
                    : 'valid range: 0-${linkedList.length - 1}';
            _addToHistory('Search failed: index $index out of bounds');
            _showError('🔍 Index $index is out of bounds ($rangeMessage)');
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
    } catch (_) {
      _showError('❌ Search failed');
    } finally {
      _isAnimating = false;
      if (mounted) setState(() => highlightedIndex = null);
    }

    _searchController.clear();
  }

  void _resetList() {
    linkedList.clear();
    setState(() {
      highlightedIndex = null;
      operationHistory.clear();
    });
    _addToHistory('Doubly LinkedList reset - all data cleared');
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
    } catch (_) {
      _showError('❌ Random populate failed');
    } finally {
      _isAnimating = false;
      if (mounted) setState(() => highlightedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Move screen size detection to the top level for AppBar usage
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define breakpoints for responsive design
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isPortrait = screenHeight > screenWidth;
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    isMobile ? 'Doubly LinkedList' : 'Doubly LinkedList Visualizer',
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: isMobile ? 16 : (isTablet ? 18 : 20),
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
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          actions: [
            _buildNavigationButtons(),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use the screen dimensions from the top level
              // Determine responsive values
              final horizontalPadding = isMobile ? 8.0 : (isTablet ? 16.0 : 24.0);
              final verticalPadding = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
              final spacing = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
              
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        children: [
                          // Visualization container
                          _buildVisualizationContainer(screenWidth, isMobile, isTablet),
                          SizedBox(height: spacing),

                          // Control buttons
                          _buildControlButtons(isMobile, isTablet, spacing),
                          SizedBox(height: spacing * 1.5),

                          // Operations and History - Responsive layout
                          Expanded(
                            child: _buildResponsiveContent(
                              isMobile: isMobile,
                              isTablet: isTablet,
                              isDesktop: isDesktop,
                              isPortrait: isPortrait,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              spacing: spacing,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizationContainer(double screenWidth, bool isMobile, bool isTablet) {
    final containerPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 25.0);
    final titleFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final lengthFontSize = isMobile ? 10.0 : (isTablet ? 11.0 : 12.0);
    final visualizationHeight = isMobile ? 120.0 : (isTablet ? 130.0 : 140.0);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 15 : 20),
        border: Border.all(color: const Color(0xFF334155), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Doubly LinkedList Structure',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Length: ${linkedList.length}',
                  style: GoogleFonts.inter(
                    fontSize: lengthFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 15 : 25),
          SizedBox(
            height: visualizationHeight,
            child: _buildLinkedListVisualization(isMobile, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedListVisualization(bool isMobile, bool isTablet) {
    if (linkedList.length == 0) {
      return Center(
        child: Text(
          'Empty Doubly LinkedList\nAdd some nodes to see the visualization',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final values = linkedList.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPointer('HEAD', const Color(0xFF10B981), isMobile, isTablet),
          _buildDoubleArrow(isLeading: true, isMobile: isMobile, isTablet: isTablet),
          ...values.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            final isHighlighted = highlightedIndex == index;
            return Row(
              children: [
                _buildNode(value, index, isHighlighted, isMobile, isTablet),
                if (index < values.length - 1) 
                  _buildDoubleArrow(isMobile: isMobile, isTablet: isTablet),
              ],
            );
          }),
          _buildDoubleArrow(isTrailing: true, isMobile: isMobile, isTablet: isTablet),
          _buildPointer('TAIL', const Color(0xFF6366F1), isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildNode(int value, int index, bool isHighlighted, bool isMobile, bool isTablet) {
    final nodeSize = isMobile ? 60.0 : (isTablet ? 66.0 : 72.0);
    final fontSize = isMobile ? 16.0 : (isTablet ? 17.0 : 18.0);
    final indexFontSize = isMobile ? 10.0 : 11.0;
    final marginHorizontal = isMobile ? 6.0 : 10.0;
    final marginBottom = isMobile ? 8.0 : 10.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: marginHorizontal),
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
                        : [const Color(0xFF6366F1), const Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
              boxShadow: [
                BoxShadow(
                  color: (isHighlighted
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF6366F1))
                      .withOpacity(0.4),
                  blurRadius: isHighlighted ? 22 : 10,
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
          SizedBox(height: marginBottom),
          Text(
            '[$index]',
            style: GoogleFonts.inter(
              fontSize: indexFontSize,
              color: Colors.grey[300],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleArrow({bool isLeading = false, bool isTrailing = false, bool isMobile = false, bool isTablet = false}) {
    final iconSize = isMobile ? 12.0 : 14.0;
    final arrowWidth = isMobile ? 20.0 : 26.0;
    final marginBottom = isMobile ? 16.0 : 20.0;
    final marginSide = isMobile ? 4.0 : 6.0;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: marginBottom,
        right: isTrailing ? 0 : marginSide,
        left: isLeading ? 0 : marginSide,
      ),
      child: Row(
        children: [
          Icon(
                Icons.arrow_back_ios_new,
                size: iconSize,
                color: const Color(0xFF94A3B8).withOpacity(0.8),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .slideX(
                duration: 1500.ms,
                begin: 0.1,
                end: -0.1,
                curve: Curves.easeInOut,
              ),
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
                duration: 1600.ms,
                begin: 0.9,
                end: 1.1,
                curve: Curves.easeInOut,
              )
              .shimmer(
                duration: 2200.ms,
                color: const Color(0xFF3B82F6).withOpacity(0.35),
              ),
          Icon(
                Icons.arrow_forward_ios,
                size: iconSize,
                color: const Color(0xFF94A3B8).withOpacity(0.8),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .slideX(
                duration: 1500.ms,
                begin: -0.1,
                end: 0.1,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  Widget _buildPointer(String label, Color color, bool isMobile, bool isTablet) {
    final fontSize = isMobile ? 10.0 : 11.0;
    final padding = isMobile ? 8.0 : 10.0;
    final marginBottom = isMobile ? 16.0 : 20.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 4 : 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
    );
  }

  Widget _buildControlButtons(bool isMobile, bool isTablet, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildAutoFillButton(isMobile, isTablet),
        SizedBox(width: spacing),
        _buildResetButton(isMobile, isTablet),
      ],
    );
  }

  Widget _buildResponsiveContent({
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isPortrait,
    required double screenWidth,
    required double screenHeight,
    required double spacing,
  }) {
    if (isMobile) {
      return _buildMobileLayout(spacing);
    } else if (isTablet) {
      return _buildTabletLayout(isPortrait, spacing);
    } else {
      return _buildDesktopLayout(spacing);
    }
  }
  Widget _buildInsertionBox({bool isMobile = false, bool isTablet = false}) {
    final padding = isMobile ? 10.0 : 12.0;
    final fontSize = isMobile ? 13.0 : 14.0;
    final iconSize = isMobile ? 16.0 : 18.0;
    final spacing = isMobile ? 6.0 : 8.0;

    // Add horizontal margin for mobile to prevent full width stretching
    final horizontalMargin = isMobile ? 16.0 : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_link, color: Colors.white, size: iconSize),
              SizedBox(width: spacing),
              Text(
                'Insert',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          _buildDropdown(
            value: insertionType,
            items: const ['Head', 'Tail', 'Position'],
            onChanged:
                (value) => setState(() => insertionType = value ?? 'Head'),
            isMobile: isMobile,
          ),
          SizedBox(height: spacing),
          _buildInputField(
            controller: _valueController,
            hint: 'Enter value',
            icon: Icons.onetwothree,
            isMobile: isMobile,
          ),
          if (insertionType == 'Position') ...[
            SizedBox(height: spacing),
            _buildInputField(
              controller: _indexController,
              hint: 'Enter position',
              icon: Icons.location_on,
              isMobile: isMobile,
            ),
          ],
          SizedBox(height: spacing),
          _buildActionButton(
            label: 'Insert',
            onPressed: _canInsert() ? _performInsertion : null,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
            textColor: const Color(0xFF0284C7),
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDeletionBox({bool isMobile = false, bool isTablet = false}) {
    final padding = isMobile ? 10.0 : 12.0;
    final fontSize = isMobile ? 13.0 : 14.0;
    final iconSize = isMobile ? 16.0 : 18.0;
    final spacing = isMobile ? 6.0 : 8.0;

    // Add horizontal margin for mobile to prevent full width stretching
    final horizontalMargin = isMobile ? 16.0 : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_off, color: Colors.white, size: iconSize),
              SizedBox(width: spacing),
              Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          _buildDropdown(
            value: deletionType,
            items: const ['By Value', 'By Position'],
            onChanged:
                (value) => setState(() => deletionType = value ?? 'By Value'),
            isMobile: isMobile,
          ),
          SizedBox(height: spacing),
          if (deletionType == 'By Value')
            _buildInputField(
              controller: _deleteValueController,
              hint: 'Enter value to delete',
              icon: Icons.onetwothree,
              isMobile: isMobile,
            ),
          if (deletionType == 'By Position')
            _buildInputField(
              controller: _deleteIndexController,
              hint: 'Enter position to delete',
              icon: Icons.location_searching,
              isMobile: isMobile,
            ),
          SizedBox(height: spacing),
          _buildActionButton(
            label: 'Delete',
            onPressed: _canDelete() ? _performDeletion : null,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
            textColor: const Color(0xFFB91C1C),
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox({bool isMobile = false, bool isTablet = false}) {
    final padding = isMobile ? 10.0 : 12.0;
    final fontSize = isMobile ? 13.0 : 14.0;
    final iconSize = isMobile ? 16.0 : 18.0;
    final spacing = isMobile ? 6.0 : 8.0;

    // Add horizontal margin for mobile to prevent full width stretching
    final horizontalMargin = isMobile ? 16.0 : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.manage_search, color: Colors.white, size: iconSize),
              SizedBox(width: spacing),
              Text(
                'Search',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          _buildDropdown(
            value: searchType,
            items: const ['By Value', 'By Index'],
            onChanged:
                (value) => setState(() => searchType = value ?? 'By Value'),
            isMobile: isMobile,
          ),
          SizedBox(height: spacing),
          _buildInputField(
            controller: _searchController,
            hint:
                searchType == 'By Value'
                    ? 'Enter value to find'
                    : 'Enter index to check',
            icon:
                searchType == 'By Value'
                    ? Icons.onetwothree
                    : Icons.location_on,
            isMobile: isMobile,
          ),
          SizedBox(height: spacing),
          _buildActionButton(
            label: 'Search',
            onPressed: _canSearch() ? _performSearch : null,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
            textColor: const Color(0xFF6D28D9),
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isMobile = false,
  }) {
    // Enhanced mobile-first responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;
    
    final fontSize = isVerySmallScreen ? 14.0 : (isMobile ? 15.0 : 14.0);
    final padding = isVerySmallScreen ? 12.0 : (isMobile ? 14.0 : 12.0);
    final verticalPadding = isVerySmallScreen ? 8.0 : (isMobile ? 10.0 : 4.0);
    final borderRadius = isVerySmallScreen ? 8.0 : (isMobile ? 10.0 : 8.0);
    
    return Container(
      height: isMobile ? 48.0 : 56.0, // Fixed height for consistency
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
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
            size: isMobile ? 24.0 : 20.0,
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem<String>(
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isMobile = false,
  }) {
    // Enhanced mobile-first responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;
    
    final fontSize = isVerySmallScreen ? 14.0 : (isMobile ? 15.0 : 14.0);
    final padding = isVerySmallScreen ? 12.0 : (isMobile ? 14.0 : 12.0);
    final iconSize = isVerySmallScreen ? 20.0 : (isMobile ? 22.0 : 20.0);
    final borderRadius = isVerySmallScreen ? 8.0 : (isMobile ? 10.0 : 8.0);
    
    return Container(
      height: isMobile ? 48.0 : 56.0, // Fixed height for consistency
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
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
            vertical: isMobile ? 12.0 : 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required Color activeColor,
    required Color inactiveColor,
    required Color textColor,
    bool isMobile = false,
  }) {
    // Enhanced mobile-first responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;
    
    final fontSize = isVerySmallScreen ? 14.0 : (isMobile ? 15.0 : 12.0);
    final buttonHeight = isVerySmallScreen ? 44.0 : (isMobile ? 48.0 : 32.0);
    final borderRadius = isVerySmallScreen ? 8.0 : (isMobile ? 10.0 : 6.0);
    
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? activeColor : inactiveColor,
        foregroundColor: textColor,
        elevation: onPressed != null ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600, 
          fontSize: fontSize,
        ),
      ),
    );

    return SizedBox(width: double.infinity, height: buttonHeight, child: button)
        .animate(target: onPressed != null ? 1 : 0)
        .scale(duration: 220.ms, curve: Curves.easeOut)
        .shimmer(
          duration: 1700.ms,
          color:
              onPressed != null
                  ? activeColor.withOpacity(0.3)
                  : Colors.transparent,
          delay: 500.ms,
        );
  }

  Widget _buildAutoFillButton(bool isMobile, bool isTablet) {
    final disabled = _isAnimating;
    final fontSize = isMobile ? 11.0 : 12.0;
    final iconSize = isMobile ? 14.0 : 16.0;
    final horizontalPadding = isMobile ? 16.0 : 22.0;
    final verticalPadding = isMobile ? 8.0 : 10.0;
    
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
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: disabled ? null : _generateRandomNodes,
        icon: Icon(Icons.auto_mode, color: Colors.white, size: iconSize),
        label: Text(
          isMobile ? 'Random' : 'Generate random numbers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            color: Colors.white,
          ),
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

  Widget _buildResetButton(bool isMobile, bool isTablet) {
    final fontSize = isMobile ? 11.0 : 12.0;
    final iconSize = isMobile ? 14.0 : 16.0;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 8.0 : 10.0;
    
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

  Widget _buildHistoryBox({bool isMobile = false, bool isTablet = false}) {
    final height = isMobile ? 250.0 : (isTablet ? 280.0 : 300.0);
    final padding = isMobile ? 12.0 : 16.0;
    final titleFontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 18.0 : 20.0;
    final textFontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 14.0);
    
    return Container(
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
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
              const SizedBox(width: 8),
              Text(
                'Operations History',
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                operationHistory.isEmpty
                    ? Center(
                      child: Text(
                        'No operations performed yet',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: textFontSize,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: operationHistory.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155).withOpacity(0.35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF475569).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            operationHistory[index],
                            style: GoogleFonts.inter(
                              color: Colors.grey[200],
                              fontSize: textFontSize,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Mobile layout - single column (vertical arrangement)
  Widget _buildMobileLayout(double spacing) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Operations arranged vertically (one below other)
          _buildInsertionBox(isMobile: true),
          SizedBox(height: spacing * 1.5),
          _buildDeletionBox(isMobile: true),
          SizedBox(height: spacing * 1.5),
          _buildSearchBox(isMobile: true),
          SizedBox(height: spacing * 2),
          _buildHistoryBox(isMobile: true),
        ],
      ),
    );
  }

  // Tablet layout - adjusts based on orientation
  Widget _buildTabletLayout(bool isPortrait, double spacing) {
    if (isPortrait) {
      // Portrait - single column like mobile but with more space
      return SingleChildScrollView(
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _buildInsertionBox(isTablet: true)),
                  SizedBox(width: spacing),
                  Expanded(child: _buildDeletionBox(isTablet: true)),
                  SizedBox(width: spacing),
                  Expanded(child: _buildSearchBox(isTablet: true)),
                ],
              ),
            ),
            SizedBox(height: spacing),
            _buildHistoryBox(isTablet: true),
          ],
        ),
      );
    } else {
      // Landscape - two column layout
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Operations
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _buildInsertionBox(isTablet: true)),
                    SizedBox(width: spacing * 0.8),
                    Expanded(child: _buildDeletionBox(isTablet: true)),
                    SizedBox(width: spacing * 0.8),
                    Expanded(child: _buildSearchBox(isTablet: true)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: spacing * 1.5),
          // Right side - History
          Expanded(
            flex: 2,
            child: _buildHistoryBox(isTablet: true),
          ),
        ],
      );
    }
  }

  // Desktop layout - side by side
  Widget _buildDesktopLayout(double spacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildInsertionBox()),
                SizedBox(width: spacing),
                Expanded(child: _buildDeletionBox()),
                SizedBox(width: spacing),
                Expanded(child: _buildSearchBox()),
              ],
            ),
          ),
        ),
        SizedBox(width: spacing * 1.5),
        Expanded(
          flex: 2,
          child: _buildHistoryBox(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isVerySmallScreen = screenWidth < 400;
        final isSmallScreen = screenWidth < 600;
        
        // Determine sizing based on screen size
        final fontSize = isVerySmallScreen ? 8.0 : (isSmallScreen ? 9.0 : 12.0);
        final horizontalPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 16.0);
        final verticalPadding = isVerySmallScreen ? 10.0 : (isSmallScreen ? 14.0 : 18.0);
        final rightPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 24.0);
        final borderRadius = isVerySmallScreen ? 8.0 : 12.0;
        
        return Padding(
          padding: EdgeInsets.only(right: rightPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ResponsiveWrapper(
                        child: SinglyLinkedListVisualization(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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
                    color: const Color.fromARGB(180, 0, 0, 0),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
