import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

// Inherited widget to provide device information throughout the app
class DeviceInfo extends InheritedWidget {
  final DeviceType deviceType;
  final Orientation orientation;
  final double screenWidth;
  final double screenHeight;
  
  const DeviceInfo({
    super.key,
    required this.deviceType,
    required this.orientation,
    required this.screenWidth,
    required this.screenHeight,
    required super.child,
  });
  
  // Helper getters for responsive design
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  
  // Responsive dimensions
  double get responsivePadding {
    switch (deviceType) {
      case DeviceType.mobile: return 8.0;
      case DeviceType.tablet: return 16.0;
      case DeviceType.desktop: return 24.0;
    }
  }
  
  double get responsiveFontSize {
    switch (deviceType) {
      case DeviceType.mobile: return 14.0;
      case DeviceType.tablet: return 16.0;
      case DeviceType.desktop: return 18.0;
    }
  }
  
  double get responsiveIconSize {
    switch (deviceType) {
      case DeviceType.mobile: return 20.0;
      case DeviceType.tablet: return 24.0;
      case DeviceType.desktop: return 28.0;
    }
  }
  
  static DeviceInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DeviceInfo>();
  }
  
  @override
  bool updateShouldNotify(DeviceInfo oldWidget) {
    return deviceType != oldWidget.deviceType ||
           orientation != oldWidget.orientation ||
           screenWidth != oldWidget.screenWidth ||
           screenHeight != oldWidget.screenHeight;
  }
}

// Responsive wrapper to handle different screen sizes and orientations
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  
  const ResponsiveWrapper({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Safety check for valid constraints
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }
        
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final orientation = MediaQuery.of(context).orientation;
        
        // Determine device type based on screen width
        DeviceType deviceType;
        if (screenWidth < 600) {
          deviceType = DeviceType.mobile;
        } else if (screenWidth < 900) {
          deviceType = DeviceType.tablet;
        } else {
          deviceType = DeviceType.desktop;
        }
        
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3)),
          ),
          child: DeviceInfo(
            deviceType: deviceType,
            orientation: orientation,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            child: child,
          ),
        );
      },
    );
  }
}

class IntStack {
  final List<int> _items = <int>[];

  void push(int value) => _items.add(value);
  int? pop() => _items.isEmpty ? null : _items.removeLast();
  int? peek() => _items.isEmpty ? null : _items.last;
  void clear() => _items.clear();
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  List<int> toList() => List.unmodifiable(_items);
}

class StackVisualization extends StatefulWidget {
	const StackVisualization({super.key});

	@override
	State<StackVisualization> createState() => _StackVisualizationState();
}

class _StackVisualizationState extends State<StackVisualization> with TickerProviderStateMixin {
	final IntStack _stack = IntStack();
	final TextEditingController _pushController = TextEditingController();

	int? _highlightedIndex;
	bool _isAnimating = false;
	bool _isPeeking = false;
	bool _isPopping = false;
	bool _isPushing = false;
	final List<String> _history = <String>[];
	
	// Typewriter animation
	late AnimationController _typewriterController;
	late Animation<int> _typewriterAnimation;
	final String _fullTitle = 'Stack Visualizer';

	@override
	void initState() {
		super.initState();
		_pushController.addListener(() => setState(() {}));
		_seedInitialValues();
		
		// Initialize typewriter animation
		_typewriterController = AnimationController(
			duration: const Duration(milliseconds: 4000),
			vsync: this,
		);
		
		_typewriterAnimation = IntTween(
			begin: 0,
			end: _fullTitle.length,
		).animate(CurvedAnimation(
			parent: _typewriterController,
			curve: Curves.easeInOut,
		));
		
		// Start typewriter animation and make it continuous
		Future.delayed(const Duration(milliseconds: 1000), () {
			_typewriterController.repeat();
		});
	}

	@override
	void dispose() {
		_pushController.dispose();
		_typewriterController.dispose();
		super.dispose();
	}

	void _seedInitialValues() {
		_stack.push(10);
		_stack.push(100);
		_stack.push(50);
    _stack.push(20);
    _stack.push(80);
	}

	bool get _canPush => !_isAnimating && _pushController.text.isNotEmpty;
	bool get _canPop => !_isAnimating && !_stack.isEmpty;
	bool get _canPeek => !_isAnimating && !_stack.isEmpty;

	void _addToHistory(String entry) {
		setState(() {
			_history.insert(0, '${_history.length + 1}. $entry');
			if (_history.length > 10) {
				_history.removeLast();
			}
		});
	}

	void _showError(String message) {
		if (!mounted) return;
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						const Icon(Icons.error_outline, color: Colors.white, size: 18),
						const SizedBox(width: 8),
						Expanded(
							child: Text(
								message,
								style: GoogleFonts.inter(
									color: Colors.white,
									fontSize: 13,
									fontWeight: FontWeight.w500,
								),
							),
						),
					],
				),
				behavior: SnackBarBehavior.floating,
				backgroundColor: const Color(0xFFDC2626),
				duration: const Duration(milliseconds: 2200),
				margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
			),
		);
	}

	void _clearHighlight() {
		if (_highlightedIndex != null) {
			setState(() => _highlightedIndex = null);
		}
	}

	Future<void> _performPush() async {
		if (!_canPush) return;
		final int? value = int.tryParse(_pushController.text);
		if (value == null) {
			_showError('Enter a valid number to push.');
			return;
		}

		setState(() {
			_isAnimating = true;
			_isPushing = true;
		});
		try {
			// Add the element to stack
			setState(() => _stack.push(value));
			_addToHistory('Pushed $value');
			
			// Single green flash for success
			setState(() => _highlightedIndex = _stack.length - 1);
			await Future.delayed(const Duration(milliseconds: 1000));
			
		} finally {
			_clearHighlight();
			setState(() {
				_isAnimating = false;
				_isPushing = false;
			});
		}

		_pushController.clear();
	}

	Future<void> _performPop() async {
		if (!_canPop) return;

		setState(() {
			_isAnimating = true;
			_isPopping = true;
		});
		try {
			// Single red flash before removal
			setState(() => _highlightedIndex = _stack.length - 1);
			await Future.delayed(const Duration(milliseconds: 800));
			
			// Remove the element
			final removed = _stack.pop();
			setState(() {});
			_addToHistory('Popped ${removed ?? 'value'}');
			
			// Brief pause to see the change
			await Future.delayed(const Duration(milliseconds: 200));
			
		} finally {
			_clearHighlight();
			setState(() {
				_isAnimating = false;
				_isPopping = false;
			});
		}
	}

	Future<void> _performPeek() async {
		if (!_canPeek) return;

		setState(() {
			_isAnimating = true;
			_isPeeking = true;
		});
		try {
			final topValue = _stack.peek();
			if (topValue == null) {
				_showError('Stack is empty.');
				return;
			}
			_addToHistory('Peeked top value: $topValue');
			
			setState(() => _highlightedIndex = _stack.length - 1);
			await Future.delayed(const Duration(milliseconds: 200));
			_clearHighlight();
			await Future.delayed(const Duration(milliseconds: 150));
			
			setState(() => _highlightedIndex = _stack.length - 1);
			await Future.delayed(const Duration(milliseconds: 300));
			_clearHighlight();
			await Future.delayed(const Duration(milliseconds: 150));
			
			setState(() => _highlightedIndex = _stack.length - 1);
			await Future.delayed(const Duration(milliseconds: 600));
			
		} finally {
			_clearHighlight();
			setState(() {
				_isAnimating = false;
				_isPeeking = false;
			});
		}
	}

	Future<void> _generateRandomStack() async {
		if (_isAnimating) return;

		setState(() {
			_isAnimating = true;
			_isPushing = true;
			_stack.clear();
			_highlightedIndex = null;
		});

		final random = Random();
		final values = List<int>.generate(5, (_) => random.nextInt(90) + 10);

		try {
			for (final value in values) {
				// Add element with push animation (green color)
				setState(() => _stack.push(value));
				
				// Green flash animation for each element
				setState(() => _highlightedIndex = _stack.length - 1);
				await Future.delayed(const Duration(milliseconds: 500));
				_clearHighlight();
				await Future.delayed(const Duration(milliseconds: 200));
			}
			_addToHistory('Generated stack: ${values.join(', ')}');
		} finally {
			_clearHighlight();
			setState(() {
				_isAnimating = false;
				_isPushing = false;
			});
		}
	}

	void _resetStack() {
		if (_isAnimating) return;
		setState(() {
			_stack.clear();
			_highlightedIndex = null;
			_history.clear();
		});
		_addToHistory('Stack reset – all elements cleared');
	}

	@override
	Widget build(BuildContext context) {
		final topValue = _stack.peek();
		final screenSize = MediaQuery.of(context).size;
		final isSmallScreen = screenSize.width < 600;
		final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
		final isVerySmallHeight = screenSize.height < 600;
		final isTabletPortrait = screenSize.width >= 600 && screenSize.width < 900 && screenSize.height > screenSize.width;

		return Scaffold(
			backgroundColor: const Color(0xFF0F172A),
			appBar: AppBar(
				leadingWidth: isSmallScreen ? 40 : 56,
				centerTitle: false,
				title: AnimatedBuilder(
					animation: _typewriterAnimation,
					builder: (context, child) {
						return Text(
							_fullTitle.substring(0, _typewriterAnimation.value),
							style: GoogleFonts.poppins(
								fontWeight: FontWeight.w600,
								fontSize: isSmallScreen ? 16 : 20,
								color: Colors.white,
							),
							maxLines: 1,
							overflow: TextOverflow.ellipsis,
						);
					},
				)
						.animate()
						.fadeIn(duration: 300.ms)
						.then()
						.shimmer(duration: 1400.ms, color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
				backgroundColor: const Color(0xFF1E293B),
				elevation: 0,
			),
			body: SafeArea(
				minimum: EdgeInsets.only(
					top: isSmallScreen ? 8 : 16,
					left: isSmallScreen ? 8 : 16,
					right: isSmallScreen ? 8 : 16,
					bottom: isSmallScreen ? 8 : 16,
				),
				child: Padding(
					padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
					child: LayoutBuilder(
						builder: (context, constraints) {
							// Safety check for valid constraints
							if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
								return const SizedBox.shrink();
							}
							
							// Responsive breakpoints
							if (isSmallScreen) {
								// Mobile layout - Single column with scrollable content
								return SingleChildScrollView(
									padding: EdgeInsets.only(bottom: isVerySmallHeight ? 20 : 16),
									child: Column(
										children: [
											_buildVisualizer(topValue, isSmallScreen: true),
											SizedBox(height: isSmallScreen ? 12 : 16),
											_buildOperationsColumn(isSmallScreen: true),
											SizedBox(height: isSmallScreen ? 12 : 16),
											SizedBox(
												height: isVerySmallHeight ? 200 : 250,
												child: _buildHistoryBox(isSmallScreen: true),
											),
										],
									),
								);
							} else if (isMediumScreen) {
								// Tablet layout - Responsive design for different tablet sizes
								if (isTabletPortrait) {
									// Tablet Portrait - Single column like mobile but with more space
									return SingleChildScrollView(
										padding: const EdgeInsets.symmetric(horizontal: 40),
										child: Column(
											children: [
												Center(
													child: ConstrainedBox(
														constraints: const BoxConstraints(maxWidth: 500),
														child: _buildVisualizer(topValue),
													),
												),
												const SizedBox(height: 24),
												Center(
													child: ConstrainedBox(
														constraints: const BoxConstraints(maxWidth: 400),
														child: _buildOperationsColumn(),
													),
												),
												const SizedBox(height: 24),
												Center(
													child: ConstrainedBox(
														constraints: const BoxConstraints(maxWidth: 500),
														child: SizedBox(
															height: 300,
															child: _buildHistoryBox(),
														),
													),
												),
											],
										),
									);
								} else {
									// Tablet Landscape - Two column layout
									return Padding(
										padding: const EdgeInsets.all(16),
										child: Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												// Left side - Visualizer
												Expanded(
													flex: 3,
													child: SingleChildScrollView(
														child: _buildVisualizer(topValue),
													),
												),
												const SizedBox(width: 20),
												// Right side - Operations and History
												Expanded(
													flex: 2,
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.stretch,
														children: [
															_buildOperationsColumn(),
															const SizedBox(height: 20),
															Expanded(
																child: _buildHistoryBox(),
															),
														],
													),
												),
											],
										),
									);
								}
							} else {
								// Desktop layout - Two columns with optimal proportions
								return Padding(
									padding: const EdgeInsets.all(16),
									child: Row(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Expanded(
												flex: 3,
												child: _buildVisualizer(topValue),
											),
											const SizedBox(width: 24),
											Expanded(
												flex: 2,
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.stretch,
													children: [
														_buildOperationsColumn(),
														const SizedBox(height: 24),
														Expanded(child: _buildHistoryBox()),
													],
												),
											),
										],
									),
								);
							}
						},
					),
				),
			),
		);
	}

	Widget _buildVisualizer(int? topValue, {bool isSmallScreen = false}) {
		final values = _stack.toList();
		final screenSize = MediaQuery.of(context).size;
		final isVerySmallScreen = screenSize.width < 350;
		
		return Container(
			padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 18),
				border: Border.all(color: const Color(0xFF334155), width: isSmallScreen ? 1.5 : 2),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withValues(alpha: 0.25),
						blurRadius: isSmallScreen ? 12 : 18,
						offset: Offset(0, isSmallScreen ? 4 : 8),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Expanded(
										child: Text(
											'Stack Structure',
											style: GoogleFonts.poppins(
												fontSize: isSmallScreen ? 16 : 18,
												fontWeight: FontWeight.w600,
												color: Colors.white,
											),
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
									),
								],
							),
							const SizedBox(height: 8),
							Wrap(
								spacing: 8,
								runSpacing: 8,
								children: [
									_buildBadge('Length: ${_stack.length}', const Color(0xFF10B981), isSmallScreen: isSmallScreen),
									_buildBadge('Top: ${topValue?.toString() ?? 'None'}', const Color(0xFFF59E0B), isSmallScreen: isSmallScreen),
								],
							),
						],
					),
					SizedBox(height: isSmallScreen ? 12 : 20),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
						decoration: BoxDecoration(
							color: const Color(0xFF0F172A),
							borderRadius: BorderRadius.circular(14),
							border: Border.all(color: const Color(0xFF334155), width: 1.5),
						),
						child: SizedBox(
							height: isSmallScreen ? 280 : (isVerySmallScreen ? 250 : 320),
							child: values.isEmpty
									? Center(
											child: Text(
												'Stack is empty\nPush elements to visualize',
												textAlign: TextAlign.center,
												style: GoogleFonts.poppins(
													fontSize: 15,
													color: Colors.grey[400],
												),
											),
										)
									: SingleChildScrollView(
											child: Center(
												child: ConstrainedBox(
													constraints: BoxConstraints(maxWidth: isSmallScreen ? 280 : 300),
													child: Column(
														mainAxisSize: MainAxisSize.min,
														children: values.asMap().entries.map((entry) {
															final index = entry.key;
															final reversedIndex = values.length - 1 - index;
															final reversedValue = values[reversedIndex];
															final bool isTop = reversedIndex == values.length - 1;
															final bool isHighlighted = _highlightedIndex == reversedIndex;
															return Padding(
																padding: EdgeInsets.only(bottom: index == values.length - 1 ? 0 : 8),
																child: _buildStackRow(
																	value: reversedValue,
																	index: reversedIndex,
																	isTop: isTop,
																	isHighlighted: isHighlighted,
																	total: values.length,
																	isSmallScreen: isSmallScreen,
																),
															);
														}).toList(),
													),
												),
											),
										),
						),
					),
					const SizedBox(height: 18),
					Align(
						alignment: Alignment.centerRight,
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								_buildRandomButton(isSmallScreen: isSmallScreen),
								const SizedBox(width: 12),
								_buildResetButton(),
							],
						),
					),
				],
			),
		);
	}

	Widget _buildBadge(String text, Color color, {bool isSmallScreen = false}) {
		return Container(
			constraints: BoxConstraints(
				minWidth: isSmallScreen ? 80 : 100,
				maxWidth: isSmallScreen ? 120 : 140,
			),
			padding: EdgeInsets.symmetric(
				horizontal: isSmallScreen ? 8 : 12,
				vertical: isSmallScreen ? 4 : 6,
			),
			decoration: BoxDecoration(
				color: color,
				borderRadius: BorderRadius.circular(12),
					boxShadow: [
						BoxShadow(
							color: color.withValues(alpha: 0.35),
						blurRadius: 12,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Text(
				text,
				textAlign: TextAlign.center,
				style: GoogleFonts.inter(
					fontWeight: FontWeight.w600,
					fontSize: isSmallScreen ? 9 : 12,
					color: Colors.white,
				),
				maxLines: 1,
				overflow: TextOverflow.ellipsis,
			),
		);
	}

	// A single row for a stack item
	Widget _buildStackRow({
		required int value,
		required int index,
		required bool isTop,
		required bool isHighlighted,
		required int total,
		bool isSmallScreen = false,
	}) {
		// Special colors for different operations
		final colors = isHighlighted && _isPushing
				? [const Color(0xFF10B981), const Color(0xFF059669)]  // Green success colors
				: isHighlighted && _isPopping
				? [const Color(0xFFEF4444), const Color(0xFFDC2626)]  // Red removal colors
				: isHighlighted && _isPeeking
				? [const Color(0xFFF59E0B), const Color(0xFFD97706)]  // Golden peek colors
				: isHighlighted
				? [const Color(0xFF22D3EE), const Color(0xFF2563EB)]  // Normal highlight
				: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]; // Default

		return AnimatedContainer(
			duration: const Duration(milliseconds: 250),
			margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
			padding: EdgeInsets.symmetric(
				horizontal: isSmallScreen ? 12 : 20,
				vertical: isSmallScreen ? 12 : 16,
			),
			decoration: BoxDecoration(
				gradient: LinearGradient(
					colors: colors,
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(
						color: colors.last.withValues(alpha: isHighlighted && (_isPeeking || _isPopping || _isPushing) ? 0.8 : isHighlighted ? 0.5 : 0.3),
						blurRadius: isHighlighted && (_isPeeking || _isPopping || _isPushing) ? 30 : isHighlighted ? 20 : 12,
						offset: const Offset(0, 4),
					),
					// Extra glow effect for peek (golden)
					if (isHighlighted && _isPeeking)
						BoxShadow(
							color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
							blurRadius: 40,
							offset: const Offset(0, 0),
						),
					// Extra warning glow for pop (red)
					if (isHighlighted && _isPopping)
						BoxShadow(
							color: const Color(0xFFEF4444).withValues(alpha: 0.6),
							blurRadius: 35,
							offset: const Offset(0, 0),
						),
					// Extra success glow for push (green)
					if (isHighlighted && _isPushing)
						BoxShadow(
							color: const Color(0xFF10B981).withValues(alpha: 0.5),
							blurRadius: 32,
							offset: const Offset(0, 0),
						),
				],
				border: isTop ? Border.all(
					color: const Color(0xFFF59E0B),
					width: 2,
				) : null,
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Row(
						children: [
							Text(
								value.toString(),
								style: GoogleFonts.poppins(
									fontSize: isSmallScreen ? 16 : 20,
									fontWeight: FontWeight.bold,
									color: Colors.white,
								),
							),
							if (isTop) ...[
								const SizedBox(width: 12),
								Container(
									padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
									decoration: BoxDecoration(
										color: const Color(0xFFF59E0B),
										borderRadius: BorderRadius.circular(8),
									),
									child: Text(
										'TOP',
										style: GoogleFonts.inter(
											fontSize: isSmallScreen ? 8 : 10,
											fontWeight: FontWeight.bold,
											color: Colors.white,
										),
									),
								),
							],
						],
					),
					Text(
						'#$index',
						style: GoogleFonts.inter(
							fontSize: isSmallScreen ? 12 : 14,
							fontWeight: FontWeight.w500,
							color: Colors.white.withValues(alpha: 0.8),
						),
					),
				],
			),
		);
	}

	Widget _buildOperationsColumn({bool isSmallScreen = false}) {
		return Center(
			child: ConstrainedBox(
				constraints: BoxConstraints(maxWidth: isSmallScreen ? 300 : 320),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						_buildPushBox(isSmallScreen: isSmallScreen),
						SizedBox(height: isSmallScreen ? 10 : 12),
						_buildActionBox(
							title: 'Pop',
							description: 'Remove top element',
							colorA: const Color(0xFFEF4444),
							colorB: const Color(0xFFB91C1C),
							onPressed: _canPop ? _performPop : null,
							icon: Icons.download,
							isSmallScreen: isSmallScreen,
						),
						SizedBox(height: isSmallScreen ? 10 : 12),
						_buildActionBox(
							title: 'Peek',
							description: 'View top element',
							colorA: const Color(0xFF8B5CF6),
							colorB: const Color(0xFF6D28D9),
							onPressed: _canPeek ? _performPeek : null,
							icon: Icons.visibility,
							isSmallScreen: isSmallScreen,
						),
					],
				),
			),
		);
	}

	Widget _buildPushBox({bool isSmallScreen = false}) {
		return Container(
			padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF16A34A).withValues(alpha: 0.22),
						blurRadius: 10,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							const Icon(Icons.upload, color: Colors.white, size: 20),
							const SizedBox(width: 8),
							Text(
								'Push',
								style: GoogleFonts.poppins(
									fontSize: isSmallScreen ? 14 : 16,
									fontWeight: FontWeight.w600,
									color: Colors.white,
								),
							),  
						],
					),
					const SizedBox(height: 12),
					_buildTextField(
						controller: _pushController,
						hint: 'Enter value to push',  
					),
					const SizedBox(height: 12),
					SizedBox(
						width: double.infinity,
						height: isSmallScreen ? 32 : 36,
						child: ElevatedButton(
							onPressed: _canPush ? _performPush : null,
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.white,
								foregroundColor: const Color(0xFF047857),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(8),
								),
							),
							child: Text(
								'Push',
								style: GoogleFonts.inter(
									fontWeight: FontWeight.w600,
									fontSize: 13,
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildActionBox({
		required String title,
		required String description,
		required Color colorA,
		required Color colorB,
		required VoidCallback? onPressed,
		required IconData icon,
		bool isSmallScreen = false,
	}) {
		return Container(
			padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
			decoration: BoxDecoration(
				gradient: LinearGradient(
					colors: [colorA, colorB],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(
						color: colorB.withValues(alpha: 0.22),
						blurRadius: 10,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(icon, color: Colors.white, size: 20),
							const SizedBox(width: 8),
							Text(
								title,
								style: GoogleFonts.poppins(
									fontSize: isSmallScreen ? 14 : 16,
									fontWeight: FontWeight.w600,
									color: Colors.white,
								),
							),
						],
					),
					const SizedBox(height: 8),
					Text(
						description,
						style: GoogleFonts.inter(
							fontSize: isSmallScreen ? 11 : 12,
							color: Colors.white.withValues(alpha: 0.85),
						),
					),
					const SizedBox(height: 12),
					SizedBox(
						width: double.infinity,
						height: isSmallScreen ? 32 : 36,
						child: ElevatedButton(
							onPressed: onPressed,
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.white,
								foregroundColor: colorB,
								disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
								disabledForegroundColor: Colors.white,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(8),
								),
							),
							child: Text(
								title,
								style: GoogleFonts.inter(
									fontWeight: FontWeight.w600,
									fontSize: 13,
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildTextField({
		required TextEditingController controller,
		required String hint,
	}) {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white.withValues(alpha: 0.2),
				borderRadius: BorderRadius.circular(10),
				border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
			),
			child: TextField(
				controller: controller,
				keyboardType: TextInputType.number,
				inputFormatters: [
					FilteringTextInputFormatter.digitsOnly,
					LengthLimitingTextInputFormatter(13),
				],
				style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
				decoration: InputDecoration(
					hintText: hint,
					hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7)),
					prefixIcon: Icon(Icons.numbers, color: Colors.white.withValues(alpha: 0.7)),
					border: InputBorder.none,
					contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
				),
			),
		);
	}

	Widget _buildHistoryBox({bool isSmallScreen = false}) {
		return Container(
			padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: const Color(0xFF334155), width: 1.4),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							const Icon(Icons.history_rounded, color: Color(0xFF94A3B8)),
							const SizedBox(width: 8),
							Text(
								'Operations History',
								style: GoogleFonts.poppins(
									fontSize: isSmallScreen ? 14 : 16,
									fontWeight: FontWeight.w600,
									color: Colors.white,
								),
							),
						],
					),
					const SizedBox(height: 12),
					Expanded(
						child: _history.isEmpty
								? Center(
										child: Text(
											'No operations yet',
											style: GoogleFonts.inter(
												color: Colors.grey[400],
												fontSize: 14,
											),
										),
									)
								: ListView.separated(
										itemCount: _history.length,
										separatorBuilder: (_, __) => const SizedBox(height: 8),
										itemBuilder: (context, index) {
											return Container(
												padding: EdgeInsets.symmetric(
													horizontal: isSmallScreen ? 10 : 12,
													vertical: isSmallScreen ? 8 : 10,
												),
												decoration: BoxDecoration(
													color: const Color(0xFF334155).withValues(alpha: 0.35),
													borderRadius: BorderRadius.circular(10),
													border: Border.all(color: const Color(0xFF475569).withValues(alpha: 0.4)),
												),
												child: Text(
													_history[index],
													style: GoogleFonts.inter(
														color: Colors.white.withValues(alpha: 0.9),
														fontSize: isSmallScreen ? 11 : 12.5,
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

	Widget _buildResetButton() {
		return Container(
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF64748B), Color(0xFF475569)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(10),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF475569).withValues(alpha: 0.25),
						blurRadius: 8,
						offset: const Offset(0, 4),
					),
				],
			),
			child: ElevatedButton.icon(
				onPressed: _isAnimating ? null : _resetStack,
				icon: const Icon(Icons.restart_alt, size: 18, color: Colors.white),
				label: Text(
					'Reset',
					style: GoogleFonts.inter(
						fontSize: 12,
						fontWeight: FontWeight.w600,
						color: Colors.white,
					),
				),
				style: ElevatedButton.styleFrom(
					backgroundColor: Colors.transparent,
					disabledBackgroundColor: Colors.transparent,
					shadowColor: Colors.transparent,
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
				),
			),
		)
				.animate(onPlay: (controller) => controller.repeat(reverse: true))
				.scaleXY(duration: 1600.ms, begin: 1, end: 1.05, curve: Curves.easeInOut)
				.then()
				.shimmer(duration: 1800.ms, color: Colors.white.withValues(alpha: 0.18));
	}

	Widget _buildRandomButton({bool isSmallScreen = false}) {
		return Container(
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(10),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF2563EB).withValues(alpha: 0.3),
						blurRadius: 10,
						offset: const Offset(0, 4),
					),
				],
			),
			child: ElevatedButton.icon(
				onPressed: _isAnimating ? null : _generateRandomStack,
				icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
				label: Flexible(
					child: Text(
						isSmallScreen ? 'Random Numbers' : 'Generate Random Numbers',
						style: GoogleFonts.inter(
							fontSize: 12,
							fontWeight: FontWeight.w600,
							color: Colors.white,
						),
						maxLines: 1,
						overflow: TextOverflow.ellipsis,
					),
				),
				style: ElevatedButton.styleFrom(
					backgroundColor: Colors.transparent,
					disabledBackgroundColor: Colors.transparent,
					shadowColor: Colors.transparent,
					padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
				),
			),
		)
				.animate(onPlay: (controller) => controller.repeat(reverse: true))
				.scaleXY(duration: 1700.ms, begin: 1, end: 1.04, curve: Curves.easeInOut)
				.then()
				.shimmer(duration: 1900.ms, color: Colors.white.withValues(alpha: 0.2));
	}
}