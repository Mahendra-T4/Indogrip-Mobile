import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indo_mobile/core/database/boxes.dart';
import 'package:indo_mobile/core/database/hive_service.dart';
import 'package:indo_mobile/core/di/sl.dart';
import 'package:indo_mobile/core/theme/color_conts.dart' as ColourPalette;
import 'package:indo_mobile/features/home/bloc/home_bloc.dart';
import 'package:indo_mobile/features/home/model/client_model.dart';
import 'package:indo_mobile/features/scanner/external_scanner.dart';
import 'package:indo_mobile/features/scanner/challan_details.dart';
import 'package:indo_mobile/features/scanner/scanner_view.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class User {
  final String name;
  final String email;
  final String avatarUrl;
  final String role;

  User({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});
  static const String routeName = '/';

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  Set<int> expandedTiles = {};
  late final HomeBloc homeBloc;

  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechEnabled = false;
  String? units;

  Future<void> initSpeech() async {
    try {
      // Request microphone permission
      if (await Permission.microphone.request().isGranted) {
        _speechEnabled = await _speech.initialize(
          onError: (error) => print('Speech recognition error: $error'),
          debugLogging: kDebugMode,
        );
        if (mounted) {
          setState(() {});
        }
      } else {
        print('Microphone permission denied');
        _speechEnabled = false;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    // clearData();
    // timer = Timer.periodic(Duration(seconds: 1), (timer) async {
    //   await Boxes.getData().clear();
    //   log('Client Scanned Data Cleared', name: 'Scanned Cartons');
    // });
    // Clear any previously stored scan data when the user lands on the home page

    homeBloc = sl<HomeBloc>();
    homeBloc.add(
      FetchClientDataEvent(filterBy: '1', keyword: _searchController.text),
    );
    initSpeech();
    // Generate 100 fake users

    // _filteredUsers = List.from(_allUsers);
    _searchController.addListener(() {
      homeBloc.add(
        FetchClientDataEvent(filterBy: '1', keyword: _searchController.text),
      );
    });
  }

  // void clearData() async {
  //   await Future.delayed(Duration(seconds: 1), () async {
  //     await Boxes.getData().clear();
  //     log('Client Scanned Data Cleared', name: 'Scanned Cartons');
  //   });
  // }

  Future<void> _startListening() async {
    try {
      if (!_speechEnabled) {
        // Try to initialize again if it failed before
        await initSpeech();
      }

      if (_speechEnabled) {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _searchController.text = result.recognizedWords;
              });
              homeBloc.add(
                FetchClientDataEvent(
                  filterBy: '1',
                  keyword: _searchController.text,
                ),
              );
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.search,
        );
        if (mounted) {
          setState(() {});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition is not available'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error starting speech recognition: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start voice input: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  unitListWidget(List<UnitList>? unitList, String rKey) {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Unit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  unitList != null && unitList.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: DropdownButtonFormField<String>(
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.store,
                                    color: Colors.grey.shade500,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Choose unit',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                color: ColourPalette.textFieldLabelColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              value: null,
                              items: unitList
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit.unitIndex.toString(),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade500,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              unit.unitName!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) async {
                                if (value != null) {
                                  context
                                      .pop(); // Close the unit selection dialog
                                  await Boxes.getData().clear();
                                  //     log('Client Scanned Data Cleared', name: 'Scanned Cartons');
                                  context.pushNamed(
                                    ScannerView.routeName,
                                    extra: ScannerViewArguments(
                                      rKey: rKey.toString(),
                                      unitIndex: value.toString(),
                                      unitName: unitList.first.unitName ?? '',
                                    ),
                                  );
                                  // _showScannerSelectorDialog(
                                  //   context,
                                  //   ScannerViewArguments(
                                  //     rKey: rKey.toString(),
                                  //     unitIndex: value.toString(),
                                  //     unitName: unitList.first.unitName ?? '',
                                  //   ),
                                  //   rKey,
                                  // );
                                }
                              },
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.withOpacity(.3),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2D8FCF),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                                size: 18,
                              ),
                              dropdownColor: Colors.white,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 35,
                        child: TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  // void _filterUsers() {
  //   final query = _searchController.text.toLowerCase();
  //   setState(() {
  //     _filteredUsers = _allUsers.where((user) {
  //       return user.name.toLowerCase().contains(query) ||
  //           user.email.toLowerCase().contains(query) ||
  //           user.role.toLowerCase().contains(query);
  //     }).toList();
  //   });
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Logout?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to logout from your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            context.pop();
                            HiveService.logout(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScannerSelectorDialog(
    BuildContext context,
    ScannerViewArguments data,
    rKey,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.blue.shade600,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Scanner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose how you want to scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Mobile Scanner
                    TextButton(
                      onPressed: () {
                        context.pop();
                        context.pushNamed(
                          ScannerView.routeName,
                          extra: ScannerViewArguments(
                            rKey: rKey.toString(),
                            unitIndex: data.unitIndex.toString(),
                            unitName: data.unitName.toString(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue.shade200,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.smartphone_rounded,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mobile Scanner',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use camera to scan QR',
                              style: TextStyle(
                                color: Colors.blue.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // USB OTG Scanner
                    TextButton(
                      onPressed: () {
                        context.pop();
                        context.pushNamed(
                          ExternalScanner.routeName,
                          extra: ScannerViewArguments(
                            rKey: rKey.toString(),
                            unitIndex: data.unitIndex.toString(),
                            unitName: data.unitName.toString(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.green.shade200,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.usb,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'External Scanner',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connected via Bluetooth',
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Glassmorphism
            ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D7FD9), Color(0xFF1E5BA8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2D7FD9).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Bar with Logout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Client',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose where to scan',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 12,
                          children: [
                            // Material(
                            //   color: Colors.transparent,
                            //   child: InkWell(
                            //     onTap: () => GoRouter.of(
                            //       context,
                            //     ).pushNamed(ChallanDetailsPage.routeName),
                            //     borderRadius: BorderRadius.circular(12),
                            //     child: Container(
                            //       padding: const EdgeInsets.all(8),
                            //       decoration: BoxDecoration(
                            //         color: Colors.white.withOpacity(0.25),
                            //         borderRadius: BorderRadius.circular(12),
                            //         border: Border.all(
                            //           color: Colors.white.withOpacity(0.3),
                            //         ),
                            //       ),
                            //       child: Icon(
                            //         Icons.visibility,
                            //         color: Colors.white,
                            //         size: 22,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showLogoutDialog(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar with Glass Effect
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.withOpacity(0.4),
                          Colors.grey.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.2,
                      ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.08),
                      //     blurRadius: 20,
                      //     offset: const Offset(0, 8),
                      //   ),
                      // ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search clients...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF2D7FD9),
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _speech.isListening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            color: _speech.isListening
                                ? Color(0xFF2D7FD9)
                                : Colors.grey.shade400,
                            size: 22,
                          ),
                          onPressed: _speechEnabled
                              ? () {
                                  if (_speech.isListening) {
                                    _stopListening();
                                  } else {
                                    _startListening();
                                  }
                                }
                              : null,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Client List
            SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  // horizontal: 16,
                  vertical: 16,
                ),
                child: buildContent,
              ),
            ),
            // SizedBox(height: 70),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          setState(() {
            _searchController.clear();
          });
          homeBloc.add(
            FetchClientDataEvent(
              filterBy: '1',
              keyword: _searchController.text,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),

          // height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D7FD9), Color(0xFF1E5BA8)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2D7FD9).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 30),
              const SizedBox(width: 6),
              Text(
                'Refresh',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get buildContent => BlocBuilder(
    bloc: homeBloc,
    builder: (context, state) {
      switch (state.runtimeType) {
        case const (HomeLoadingStatus):
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF2D7FD9),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading clients...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        case const (HomeClientDataLoadedSuccessStatus):
          final successState =
              (state as HomeClientDataLoadedSuccessStatus).clientModel;
          return successState.status != 1
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        successState.message ?? 'No data found',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,

                  itemCount: successState.record?.length,
                  itemBuilder: (context, index) {
                    final user = successState.record![index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildModernClientCard(context, user, index),
                    );
                  },
                );
        case const (HomeErrorStatus):
          final errorState = state as HomeErrorStatus;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    errorState.errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    },
  );

  Widget _buildModernClientCard(BuildContext context, Record user, int index) {
    return Material(
      // color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (user.unitList != null && user.unitList!.isNotEmpty) {
            unitListWidget(user.unitList, user.rKey.toString());
          } else {
            await Boxes.getData().clear();
            //     log('Client Scanned Data Cleared', name: 'Scanned Cartons');
            context.pushNamed(
              ScannerView.routeName,
              extra: ScannerViewArguments(
                rKey: user.rKey.toString(),
                unitIndex: '',
                unitName: '',
              ),
            );
            // _showScannerSelectorDialog(
            //   context,
            //   ScannerViewArguments(
            //     rKey: user.rKey.toString(),
            //     unitIndex: '',
            //     unitName: '',
            //   ),
            //   user.rKey.toString(),
            // );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0xFF2D7FD9).withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            margin: index + 1 == 1
                ? const EdgeInsets.only(top: 10)
                : const EdgeInsets.all(0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Client Avatar/Badge
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2D7FD9), Color(0xFF1E5BA8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF2D7FD9).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Client Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF2D7FD9).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user.cCode ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D7FD9),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.cConsigneeName.toString(),

                          style: GoogleFonts.poppins(
                            fontSize: 12,

                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                            // letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (user.unitList != null && user.unitList!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: Color(0xFF2D7FD9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user.unitList!.length} unit(s)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D7FD9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF2D7FD9),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Clipper for curved header
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
