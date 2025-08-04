import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../Features/codia/codia_page.dart';
import 'dart:math';

// Custom scroll physics optimized for mouse wheel
class SlowScrollPhysics extends ScrollPhysics {
  const SlowScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * 0.4; // Slow down by 60%
  }
}

class RunCardOpen extends StatefulWidget {
  final Map<String, dynamic> workoutData;
  
  const RunCardOpen({Key? key, required this.workoutData}) : super(key: key);

  @override
  State<RunCardOpen> createState() => _RunCardOpenState();
}

class _RunCardOpenState extends State<RunCardOpen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _hasUnsavedChanges = false;
  
  // Original values to compare for changes
  String _originalRunName = '';
  String _originalCalories = '';
  String _originalNotes = '';

  late AnimationController _bookmarkController;
  late Animation<double> _bookmarkScaleAnimation;
  late AnimationController _likeController;
  late Animation<double> _likeScaleAnimation;

  // Initialize with default values
  String _runName = 'Evening run 1';
  String _notes = 'It was cold asf';
  String _calories = '230';
  String _time = '18h 11min';
  String _distance = '101.1km';
  String _speed = '5.2km/h';
  double _intensity = 8.0; // 8/10 intensity
  String _privacyStatus = 'Private';

  @override
  void initState() {
    super.initState();
    print('RunCardOpen initState called');

    // Initialize with no unsaved changes
    _hasUnsavedChanges = false;

    // Initialize animation controllers
    _initAnimationControllers();

    // Set initial values from parameters if available
    if (widget.workoutData['name'] != null && widget.workoutData['name'].isNotEmpty) {
      _runName = widget.workoutData['name'];
    }

    if (widget.workoutData['calories'] != null) {
      _calories = widget.workoutData['calories'].toString();
    }

    if (widget.workoutData['duration'] != null) {
      int durationInMinutes = (widget.workoutData['duration'] / 60).floor();
      _time = _formatDuration(durationInMinutes);
    }

    if (widget.workoutData['distance'] != null) {
      double distance = _extractNumericValueAsDouble(widget.workoutData['distance']) ?? 0.0;
      _distance = '${_formatDistance(distance / 1000)}km';
    }

    if (widget.workoutData['pace'] != null) {
      double pace = _extractNumericValueAsDouble(widget.workoutData['pace']) ?? 0.0;
      _speed = '${pace.toStringAsFixed(1)}km/h';
    }

    if (widget.workoutData['intensity'] != null) {
      _intensity = (widget.workoutData['intensity'] as num).toDouble();
    }

    if (widget.workoutData['notes'] != null) {
      _notes = widget.workoutData['notes'];
    }

    // Load saved data from SharedPreferences
    _loadSavedData().then((_) {
      if (mounted) {
        // Reset unsaved changes state after loading
        _resetUnsavedChangesState();
      }
    });
  }

  void _initAnimationControllers() {
    // Bookmark animations
    _bookmarkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bookmarkScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bookmarkController,
      curve: Curves.easeInOut,
    ));

    // Like animations
    _likeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _likeController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _bookmarkController.dispose();
    _likeController.dispose();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes < 1) {
      return '0 min';
    }
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}min';
    } else {
      return '${remainingMinutes}min';
    }
  }

  String _formatDistance(double distance) {
    return distance.toStringAsFixed(1);
  }

  double? _extractNumericValueAsDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove non-numeric characters except decimal point
      String cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      if (cleaned.isNotEmpty) {
        return double.tryParse(cleaned);
      }
    }
    return null;
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('run_${widget.workoutData['id'] ?? 'default'}');
      
      if (savedData != null) {
        final data = json.decode(savedData);
        setState(() {
          _runName = data['runName'] ?? _runName;
          _notes = data['notes'] ?? _notes;
          _calories = data['calories'] ?? _calories;
          _intensity = data['intensity'] ?? _intensity;
          _isLiked = data['isLiked'] ?? false;
          _isBookmarked = data['isBookmarked'] ?? false;
          _privacyStatus = data['privacyStatus'] ?? 'Private';
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'runName': _runName,
        'notes': _notes,
        'calories': _calories,
        'intensity': _intensity,
        'isLiked': _isLiked,
        'isBookmarked': _isBookmarked,
        'privacyStatus': _privacyStatus,
      };
      
      await prefs.setString('run_${widget.workoutData['id'] ?? 'default'}', json.encode(data));
      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void _resetUnsavedChangesState() {
    _originalRunName = _runName;
    _originalCalories = _calories;
    _originalNotes = _notes;
    _hasUnsavedChanges = false;
  }

  // Check for unsaved changes
  bool _checkForUnsavedChanges() {
    return _hasUnsavedChanges;
  }

  // Mark as having unsaved changes
  void _markAsUnsaved() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
      print('Marked as having unsaved changes');
    }
  }

  // Method to toggle bookmark state with animation
  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      _bookmarkController.reset();
      _bookmarkController.forward();
      _markAsUnsaved(); // Mark as having unsaved changes
    });
  }

  // Method to toggle like state with animation
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeController.reset();
      _likeController.forward();
      _markAsUnsaved(); // Mark as having unsaved changes
    });
  }

  // Handle back button press
  void _handleBack() async {
    if (_checkForUnsavedChanges()) {
      bool shouldDiscard = await _showUnsavedChangesDialog();
      if (shouldDiscard) {
        if (mounted) {
          setState(() {
            _runName = _originalRunName;
            _notes = _originalNotes;
            _calories = _originalCalories;
            _hasUnsavedChanges = false;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CodiaPage()),
            );
          });
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CodiaPage()),
        );
      }
    }
  }

  // Show confirmation dialog for unsaved changes
  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: 326,
                height: 182,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        "Discard Changes?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      SizedBox(height: 20),

                      // Discard button
                      Container(
                        width: 267,
                        height: 40,
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Centered text
                            Text(
                              "Discard",
                              style: TextStyle(
                                color: Color(0xFFE97372),
                                fontSize: 16,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Icon positioned to the left with exact spacing
                            Positioned(
                              left: 70,
                              child: Image.asset(
                                'assets/images/trashcan.png',
                                width: 20,
                                height: 20,
                                color: Color(0xFFE97372),
                              ),
                            ),
                            // Full-width button for tap area
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.of(context)
                                        .pop(true); // Discard changes
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cancel button
                      Container(
                        width: 267,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Centered text
                            Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Icon positioned to the left with exact spacing
                            Positioned(
                              left: 70,
                              child: Image.asset(
                                'assets/images/closeicon.png',
                                width: 18,
                                height: 18,
                              ),
                            ),
                            // Full-width button for tap area
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.of(context).pop(
                                        false); // Cancel and return to editing
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _showPrivacyOptions() {
    String _selectedPrivacy = _privacyStatus;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrivacyOption('Private', 'assets/images/Lock.png', _selectedPrivacy, (value) {
                setModalState(() => _selectedPrivacy = value);
                setState(() {
                  _privacyStatus = value;
                  _markAsUnsaved();
                });
                Navigator.pop(context);
              }),
              _buildPrivacyOption('Friends Only', 'assets/images/socialicon.png', _selectedPrivacy, (value) {
                setModalState(() => _selectedPrivacy = value);
                setState(() {
                  _privacyStatus = value;
                  _markAsUnsaved();
                });
                Navigator.pop(context);
              }),
              _buildPrivacyOption('Public', 'assets/images/globe.png', _selectedPrivacy, (value) {
                setModalState(() => _selectedPrivacy = value);
                setState(() {
                  _privacyStatus = value;
                  _markAsUnsaved();
                });
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(String title, String iconPath, String selectedPrivacy, Function(String) onSelect) {
    bool isSelected = selectedPrivacy == title;
    return InkWell(
      onTap: () => onSelect(title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (isSelected) Icon(Icons.check, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _editIntensity() {
    double currentIntensity = _intensity;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.close, color: Colors.black, size: 20),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Edit Intensity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Image.asset('assets/images/intensity.png', width: 48, height: 48, color: Colors.black),
                SizedBox(height: 16),
                Text(
                  'Set Run Intensity from 1-10',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.white,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: currentIntensity,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    onChanged: (value) {
                      setModalState(() {
                        currentIntensity = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  currentIntensity.round().toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Display',
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _intensity = currentIntensity;
                        _markAsUnsaved();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editRun() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Run'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Run Name',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _runName),
                onChanged: (value) {
                  _runName = value;
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _notes),
                onChanged: (value) {
                  _notes = value;
                },
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _markAsUnsaved();
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _fixWithAI() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI fix feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: Color(0xFFDADADA),
      body: WillPopScope(
        onWillPop: () async {
          _handleBack();
          return false;
        },
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background4.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Scrollable content with extra slow physics for mouse wheel
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: SingleChildScrollView(
                physics: SlowScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gray image header with back button on it
                    Container(
                      height: MediaQuery.of(context).size.width,
                      color: Color(0xFFDADADA),
                      child: Stack(
                        children: [
                          // Running shoe icon - centered like the meal image in FoodCardOpen
                          Center(
                            child: Image.asset(
                              'assets/images/Shoe.png',
                              width: 120,
                              height: 120,
                              color: Colors.black,
                            ),
                          ),
                          // Back button inside the scrollable area
                          Positioned(
                            top: statusBarHeight + 16,
                            left: 16,
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.black, size: 24),
                                  onPressed: _handleBack,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ),
                            ),
                          ),
                          // Share and more buttons
                          Positioned(
                            top: statusBarHeight + 16,
                            right: 16,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Image.asset(
                                        'assets/images/share.png',
                                        width: 21.6,
                                        height: 21.6,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Image.asset(
                                        'assets/images/more.png',
                                        width: 21.6,
                                        height: 21.6,
                                        color: Colors.black,
                                      ),
                                      onPressed: _showPrivacyOptions,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                     // White rounded container with gradient - exactly like FoodCardOpen
                     Transform.translate(
                       offset: Offset(0, -40), // Move up to create overlap
                       child: Container(
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.vertical(
                             top: Radius.circular(40),
                           ),
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             stops: [0, 0.4, 1],
                             colors: [
                               Color(0xFFFFFFFF),
                               Color(0xFFFFFFFF),
                               Color(0xFFEBEBEB),
                             ],
                           ),
                         ),
                         child: Column(
                           children: [
                             // Add 20px gap at top of white container
                             SizedBox(height: 20),

                             // Time and interaction buttons - exactly like FoodCardOpen
                             Padding(
                               padding: const EdgeInsets.fromLTRB(29, 0, 29, 0),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   // Left side: Bookmark and time
                                   Row(
                                     children: [
                                       // Bookmark button with enhanced animation
                                       GestureDetector(
                                         onTap: _toggleBookmark,
                                         child: AnimatedBuilder(
                                           animation: _bookmarkController,
                                           builder: (context, child) {
                                             return Transform.scale(
                                               scale: _bookmarkScaleAnimation.value,
                                               child: Image.asset(
                                                 _isBookmarked
                                                     ? 'assets/images/bookmarkfilled.png'
                                                     : 'assets/images/bookmark.png',
                                                 width: 24,
                                                 height: 24,
                                                 color: _isBookmarked
                                                     ? Color(0xFFFFC300)
                                                     : Colors.black,
                                               ),
                                             );
                                           },
                                         ),
                                       ),
                                       SizedBox(width: 16),
                                       // Time
                                       Container(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(
                                           color: Color(0xFFF2F2F2),
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                         child: Text(
                                           '12:07',
                                           style: TextStyle(fontSize: 12),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ],
                               ),
                             ),

                             // Title and description with adjusted padding - exactly like FoodCardOpen
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 // Title and subtitle area with 14px top spacing
                                 Padding(
                                   padding: const EdgeInsets.only(
                                       left: 29, right: 29, top: 14, bottom: 0),
                                   child: Container(
                                     width: double.infinity,
                                     // Remove fixed height and use dynamic sizing
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                                                                   Text(
                                            _runName,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'SF Pro Display',
                                            ),
                                            // Allow wrapping to multiple lines
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          // Only show description if it's not empty, null, or just whitespace
                                          if (_notes != null && _notes.trim().isNotEmpty) ...[
                                            SizedBox(height: 4),
                                            Text(
                                              _notes,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                       ],
                                     ),
                                   ),
                                 ),

                                 // Add 20px gap between subtitle and divider
                                 SizedBox(height: 20),

                                 // Calories and metrics card - exactly like FoodCardOpen
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 29),
                                   child: Container(
                                     padding: EdgeInsets.all(20),
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(20),
                                       // Remove border on this card even in edit mode
                                       border: null,
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.black.withOpacity(0.05),
                                           blurRadius: 10,
                                           offset: Offset(0, 5),
                                         ),
                                       ],
                                     ),
                                     child: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         // Calories circle
                                         Stack(
                                           alignment: Alignment.center,
                                           children: [
                                             // Circle image instead of custom painted progress
                                             Transform.translate(
                                               offset: Offset(0, -3.9),
                                               child: ColorFiltered(
                                                 colorFilter: ColorFilter.mode(
                                                   Colors.black,
                                                   BlendMode.srcIn,
                                                 ),
                                                 child: Image.asset(
                                                   'assets/images/circle.png',
                                                   width: 130,
                                                   height: 130,
                                                   fit: BoxFit.contain,
                                                 ),
                                               ),
                                             ),
                                             // Calories text
                                             Column(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 Text(
                                                   _calories,
                                                   style: TextStyle(
                                                     fontSize: 20,
                                                     fontWeight: FontWeight.bold,
                                                     color: Colors.black,
                                                     decoration: TextDecoration.none,
                                                   ),
                                                 ),
                                                 Text(
                                                   'Calories',
                                                   style: TextStyle(
                                                     fontSize: 12,
                                                     fontWeight: FontWeight.normal,
                                                     color: Colors.black,
                                                     decoration: TextDecoration.none,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ],
                                         ),
                                         SizedBox(height: 5),

                                                                                   // Run Stats - Three pill-shaped components as shown in the image
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildRunMetricPill('Time', _time, Color(0xFFD7C1FF), 'assets/images/Stopwatch.png'),
                                              _buildRunMetricPill('Distance', _distance, Color(0xFFFFD8B1), 'assets/images/distance.png'),
                                              _buildRunMetricPill('Speed', _speed, Color(0xFFB1EFD8), 'assets/images/speedicon.png'),
                                            ],
                                          ),
                                       ],
                                     ),
                                   ),
                                 ),

                                 SizedBox(height: 32),

                                 // Only show social interaction area if not Private
                                 if (_privacyStatus != 'Private') ...[
                                   // Social Section - exactly like FoodCardOpen
                                   Padding(
                                     padding: const EdgeInsets.symmetric(horizontal: 29),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           'Social',
                                           style: TextStyle(
                                             color: Colors.black,
                                             fontSize: 20,
                                             fontWeight: FontWeight.bold,
                                             fontFamily: 'SF Pro Display',
                                           ),
                                         ),
                                         SizedBox(height: 16),
                                         // Social sharing buttons - matching Figma design exactly
                                         Row(
                                           children: [
                                             // Like button area (left section)
                                             Expanded(
                                               child: Container(
                                                 height: 48,
                                                 decoration: BoxDecoration(
                                                   color: Colors.white,
                                                   borderRadius: BorderRadius.circular(24),
                                                   boxShadow: [
                                                     BoxShadow(
                                                       color: Colors.black.withOpacity(0.05),
                                                       blurRadius: 4,
                                                       offset: Offset(0, 2),
                                                     ),
                                                   ],
                                                 ),
                                                 child: Center(
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       GestureDetector(
                                                         onTap: _toggleLike,
                                                         child: AnimatedBuilder(
                                                           animation: _likeController,
                                                           builder: (context, child) {
                                                             return Transform.scale(
                                                               scale: _likeScaleAnimation.value,
                                                               child: Image.asset(
                                                                 _isLiked
                                                                     ? 'assets/images/likefilled.png'
                                                                     : 'assets/images/like.png',
                                                                 width: 24,
                                                                 height: 24,
                                                                 color: Colors.black,
                                                               ),
                                                             );
                                                           },
                                                         ),
                                                       ),
                                                       SizedBox(width: 8),
                                                       Text(
                                                         '0 Likes',
                                                         style: TextStyle(
                                                           fontSize: 16,
                                                           fontWeight: FontWeight.w500,
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             
                                             SizedBox(width: 16),
                                             
                                             // Comment button (right section)
                                             Expanded(
                                               child: Container(
                                                 height: 48,
                                                 decoration: BoxDecoration(
                                                   color: Colors.white,
                                                   borderRadius: BorderRadius.circular(24),
                                                   boxShadow: [
                                                     BoxShadow(
                                                       color: Colors.black.withOpacity(0.05),
                                                       blurRadius: 4,
                                                       offset: Offset(0, 2),
                                                     ),
                                                   ],
                                                 ),
                                                 child: Center(
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       Image.asset(
                                                         'assets/images/comment.png',
                                                         width: 24,
                                                         height: 24,
                                                         color: Colors.black,
                                                       ),
                                                       SizedBox(width: 8),
                                                       Text(
                                                         '0 Comments',
                                                         style: TextStyle(
                                                           fontSize: 16,
                                                           fontWeight: FontWeight.w500,
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ),
                                   
                                   SizedBox(height: 32),
                                 ],

                                 // Intensity Section
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 29),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         'Intensity',
                                         style: TextStyle(
                                           color: Colors.black,
                                           fontSize: 20,
                                           fontWeight: FontWeight.bold,
                                           fontFamily: 'SF Pro Display',
                                         ),
                                       ),
                                       SizedBox(height: 16),
                                                                               Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Top row with icon, label, and value
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/intensity.png',
                                                    width: 24,
                                                    height: 24,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Intensity',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    '${_intensity.toInt()}/10',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              // Progress bar
                                              Container(
                                                width: double.infinity,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE0E0E0), // Light grey background
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                                child: FractionallySizedBox(
                                                  alignment: Alignment.centerLeft,
                                                  widthFactor: _intensity / 10.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                     ],
                                   ),
                                 ),

                                 SizedBox(height: 32),

                                 // More Section - exactly like FoodCardOpen
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 29),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         'More',
                                         style: TextStyle(
                                           color: Colors.black,
                                           fontSize: 20,
                                           fontWeight: FontWeight.bold,
                                           fontFamily: 'SF Pro Display',
                                         ),
                                       ),
                                       SizedBox(height: 16),
                                       // More options buttons - matching Figma design exactly
                                       _buildMoreOption('Edit Intensity', 'intensity.png'),
                                       _buildMoreOption('Edit Run', 'pencilicon.png'),
                                       _buildMoreOption('Fix with AI', 'bulb.png'),
                                       _buildMoreOptionWithDropdown('Public', 'globe.png'),
                                     ],
                                   ),
                                 ),

                                 SizedBox(height: 32),

                                 // Save button
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 29),
                                   child: Container(
                                     width: double.infinity,
                                     height: 50,
                                     child: ElevatedButton(
                                       onPressed: _hasUnsavedChanges ? _saveData : null,
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: Colors.black,
                                         foregroundColor: Colors.white,
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(25),
                                         ),
                                         elevation: 0,
                                       ),
                                       child: Text(
                                         'Save',
                                         style: TextStyle(
                                           fontSize: 16,
                                           fontWeight: FontWeight.w600,
                                           fontFamily: 'SF Pro Display',
                                         ),
                                       ),
                                     ),
                                   ),
                                 ),

                                 SizedBox(height: 32),
                               ],
                             ),
                           ],
                         ),
                       ),
                     ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to build the pill-shaped run metrics as shown in the image
  Widget _buildRunMetricPill(String label, String value, Color color, String iconAsset) {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon and label in horizontal row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconAsset,
                  width: 16,
                  height: 16,
                  color: Colors.black,
                ),
                SizedBox(width: 4),
                Text(
                  label, 
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 4),
            Container(
              width: 35, // Reduced pill width to match food card compactness
              height: 8, // Reduced height to match food card
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(String title, String iconAsset) {
    // Base icon size for pencilicon.png
    double baseIconSize = 25.0;
    // Calculate 10% larger size for the other two icons
    double largerIconSize = baseIconSize * 1.1; // 27.5px

    // Determine the size for the current icon
    double iconSize = (iconAsset == 'intensity.png' || iconAsset == 'bulb.png')
        ? largerIconSize
        : (iconAsset == 'globe.png' ? baseIconSize * 0.9 : baseIconSize);

    return GestureDetector(
      onTap: () {
        // Handle the click based on which option was selected
        if (title == 'Edit Run') {
          _editRun();
        } else if (title == 'Fix with AI') {
          _fixWithAI();
        } else if (title == 'Edit Intensity') {
          _editIntensity();
        }
        // Add other handlers for different options if needed
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15), // Set gap between boxes to 15px
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Add 40px padding before the icon alignment container (35 + 5)
            SizedBox(width: 40),
            // Container to ensure icons align vertically and have space
            SizedBox(
              width: 40, // Keep this width consistent for alignment
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: iconAsset == 'globe.png'
                      ? const EdgeInsets.only(left: 1.0)
                      : EdgeInsets.zero,
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Image.asset(
                      'assets/images/$iconAsset',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, // Matches Health Score text size
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: false, // Prevent text from wrapping to the next line
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionWithDropdown(String title, String iconAsset) {
    // Base icon size for pencilicon.png
    double baseIconSize = 25.0;
    // Calculate 10% larger size for the other two icons
    double largerIconSize = baseIconSize * 1.1; // 27.5px

    // Determine the size for the current icon
    double iconSize = (iconAsset == 'intensity.png' || iconAsset == 'bulb.png')
        ? largerIconSize
        : (iconAsset == 'globe.png' ? baseIconSize * 0.9 : baseIconSize);

    return GestureDetector(
      onTap: _showPrivacyOptions,
      child: Container(
        margin: EdgeInsets.only(bottom: 15), // Set gap between boxes to 15px
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Add 40px padding before the icon alignment container (35 + 5)
            SizedBox(width: 40),
            // Container to ensure icons align vertically and have space
            SizedBox(
              width: 40, // Keep this width consistent for alignment
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: iconAsset == 'globe.png'
                      ? const EdgeInsets.only(left: 1.0)
                      : EdgeInsets.zero,
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Image.asset(
                      'assets/images/$iconAsset',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, // Matches Health Score text size
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: false, // Prevent text from wrapping to the next line
                ),
              ),
            ),
            // Dropdown arrow
            Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
} 