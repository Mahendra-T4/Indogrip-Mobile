// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

// import 'package:indo_mobile/core/database/boxes.dart';
// import 'package:indo_mobile/core/di/sl.dart';
// import 'package:indo_mobile/core/service/external_scanner_service.dart';
// import 'package:indo_mobile/core/theme/color_conts.dart';
// import 'package:indo_mobile/core/util/toast.dart';
// import 'package:indo_mobile/features/home/bloc/home_bloc.dart';
// import 'package:indo_mobile/features/scanner/model/round_data_model.dart';
// import 'package:indo_mobile/features/scanner/scan_details_view.dart';
// import 'package:indo_mobile/features/scanner/scanned_carton.dart';

// enum ScannerType { mobile, external }

// class ScannerViewArguments {
//   final String rKey;
//   final String unitIndex;
//   ScannerViewArguments({required this.rKey, required this.unitIndex});
// }

// class ScannerView extends StatefulWidget {
//   const ScannerView({super.key, required this.args});
//   final ScannerViewArguments args;
//   static const String routeName = '/scanner';

//   @override
//   State<ScannerView> createState() => _ScannerViewState();
// }

// class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
//   late final HomeBloc homeBloc;
//   late final ExternalScannerService externalScannerService;
//   String? units;
//   String? unitName;
//   ScannerType? selectedScannerType;
//   StreamSubscription? _externalScannerSubscription;

//   @override
//   void initState() {
//     super.initState();
//     log(
//       'ScannerView initialized with rKey: ${widget.args.rKey}, unitIndex: ${widget.args.unitIndex}',
//     );
//     homeBloc = sl<HomeBloc>();
//     homeBloc.add(FetchClientDataEvent(filterBy: '1', keyword: ''));
//     externalScannerService = ExternalScannerService();
//     result = null;
//     WidgetsBinding.instance.addObserver(this);
//     _showScannerSelectionDialog();
//   }

//   Future<void> _showScannerSelectionDialog() async {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.grey.shade50],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 25,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(28),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue.shade100, Colors.blue.shade50],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade200.withOpacity(0.5),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.qr_code_scanner,
//                     color: Colors.blue.shade600,
//                     size: 36,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Select Scanner Type',
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                     letterSpacing: 0.2,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Choose which scanner to use',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade700,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 28),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           context.pop();
//                           setState(() {
//                             selectedScannerType = ScannerType.mobile;
//                           });
//                           _requestCameraPermission();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue.shade50,
//                           foregroundColor: Colors.blue.shade600,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             side: BorderSide(
//                               color: Colors.blue.shade200,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.phone_android,
//                               size: 28,
//                               color: Colors.blue.shade600,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Mobile Scanner',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           context.pop();
//                           _initializeExternalScanner();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: secondaryColor.withOpacity(0.1),
//                           foregroundColor: secondaryColor,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             side: BorderSide(
//                               color: secondaryColor.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.devices_other,
//                               size: 28,
//                               color: secondaryColor,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'External Scanner',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _initializeExternalScanner() async {
//     if (!mounted) return;

//     setState(() {
//       selectedScannerType = ScannerType.external;
//     });

//     // Show connection type selection dialog
//     _showConnectionTypeDialog();
//   }

//   void _showConnectionTypeDialog() {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.grey.shade50],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 25,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(28),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.purple.shade100, Colors.purple.shade50],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.purple.shade200.withOpacity(0.5),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.devices_other,
//                     color: Colors.purple.shade600,
//                     size: 36,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Connection Type',
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                     letterSpacing: 0.2,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Select how to connect to external scanner',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade700,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 28),
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         context.pop();
//                         _scanBluetoothDevices();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue.shade50,
//                         foregroundColor: Colors.blue.shade600,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: BorderSide(
//                             color: Colors.blue.shade200,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.bluetooth,
//                             size: 24,
//                             color: Colors.blue.shade600,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'Bluetooth',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Wireless scanner',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.blue.shade400,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: Colors.blue.shade600,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         context.pop();
//                         _scanUsbDevices();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange.shade50,
//                         foregroundColor: Colors.orange.shade600,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: BorderSide(
//                             color: Colors.orange.shade200,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.usb,
//                             size: 24,
//                             color: Colors.orange.shade600,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'USB Serial',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Android USB devices',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.orange.shade400,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: Colors.orange.shade600,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _scanBluetoothDevices() async {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               Text(
//                 'Scanning Bluetooth Devices...',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     try {
//       await externalScannerService.initialize();
//       final devices = await externalScannerService.scanBluetoothDevices();

//       if (mounted) {
//         context.pop();
//       }

//       if (devices.isNotEmpty) {
//         _showDeviceSelectionDialog(devices, 'Bluetooth');
//       } else {
//         if (mounted) {
//           showToast(
//             context,
//             'No Bluetooth devices found',
//             backgroundColor: Colors.red.shade400,
//           );
//           _showConnectionTypeDialog();
//         }
//       }
//     } catch (e) {
//       log('Error scanning Bluetooth devices: $e');
//       if (mounted) {
//         context.pop();
//         showToast(
//           context,
//           'Error: ${e.toString()}',
//           backgroundColor: Colors.red.shade400,
//         );
//         _showConnectionTypeDialog();
//       }
//     }
//   }

//   Future<void> _scanUsbDevices() async {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               Text(
//                 'Scanning USB Devices...',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     try {
//       final devices = await externalScannerService.getUsbDevices();

//       if (mounted) {
//         context.pop();
//       }

//       if (devices.isNotEmpty) {
//         _showDeviceSelectionDialog(devices, 'USB');
//       } else {
//         if (mounted) {
//           showToast(
//             context,
//             'No USB devices found. Please connect a USB scanner.',
//             backgroundColor: Colors.red.shade400,
//           );
//           _showConnectionTypeDialog();
//         }
//       }
//     } catch (e) {
//       log('Error scanning USB devices: $e');
//       if (mounted) {
//         context.pop();
//         showToast(
//           context,
//           'Error: ${e.toString()}',
//           backgroundColor: Colors.red.shade400,
//         );
//         _showConnectionTypeDialog();
//       }
//     }
//   }

//   void _showDeviceSelectionDialog(
//     List<ScannerDevice> devices,
//     String connectionType,
//   ) {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.grey.shade50],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 25,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Select Device',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 300,
//                   child: ListView.builder(
//                     itemCount: devices.length,
//                     itemBuilder: (context, index) {
//                       final device = devices[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             context.pop();
//                             _connectToDevice(device, connectionType);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey.shade50,
//                             foregroundColor: Colors.black87,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               side: BorderSide(
//                                 color: Colors.grey.shade200,
//                                 width: 1,
//                               ),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 connectionType == 'Bluetooth'
//                                     ? Icons.bluetooth
//                                     : Icons.usb,
//                                 size: 24,
//                                 color: connectionType == 'Bluetooth'
//                                     ? Colors.blue.shade600
//                                     : Colors.orange.shade600,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       device.name,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     Text(
//                                       device.id,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w400,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (device.isConnected)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade50,
//                                     borderRadius: BorderRadius.circular(6),
//                                     border: Border.all(
//                                       color: Colors.green.shade200,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Connected',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.green.shade700,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           context.pop();
//                           _showConnectionTypeDialog();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey.shade200,
//                           foregroundColor: Colors.grey.shade700,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: Text(
//                           'Back',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _connectToDevice(
//     ScannerDevice device,
//     String connectionType,
//   ) async {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               Text(
//                 'Connecting to ${device.name}...',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     try {
//       bool connected = false;

//       if (connectionType == 'Bluetooth') {
//         connected = await externalScannerService.connectBluetoothDevice(
//           device.id,
//         );
//       } else {
//         connected = await externalScannerService.connectUsbDevice(device.id);
//       }

//       if (mounted) {
//         context.pop();
//       }

//       if (connected) {
//         if (!mounted) return;

//         // Listen to external scanner
//         _externalScannerSubscription?.cancel();
//         _externalScannerSubscription = externalScannerService.scannedDataStream
//             .listen((event) {
//               if (event.code != null && event.code!.isNotEmpty) {
//                 stopDuplicateQRScan(event.code!);
//               }
//             });

//         if (mounted) {
//           showToast(
//             context,
//             'Connected to ${device.name}',
//             backgroundColor: Colors.green.shade400,
//           );
//         }
//       } else {
//         if (mounted) {
//           showToast(
//             context,
//             'Failed to connect to device',
//             backgroundColor: Colors.red.shade400,
//           );
//           _showConnectionTypeDialog();
//         }
//       }
//     } catch (e) {
//       log('Error connecting to device: $e');
//       if (mounted) {
//         context.pop();
//         showToast(
//           context,
//           'Error: ${e.toString()}',
//           backgroundColor: Colors.red.shade400,
//         );
//         _showConnectionTypeDialog();
//       }
//     }
//   }

//   Widget get buildContent => BlocBuilder(
//     bloc: homeBloc,
//     builder: (context, state) {
//       switch (state.runtimeType) {
//         case const (HomeLoadingStatus):
//           return const Center(child: CircularProgressIndicator());
//         case const (HomeClientDataLoadedSuccessStatus):
//           final successState =
//               (state as HomeClientDataLoadedSuccessStatus).clientModel;

//           final user = successState.record?.toList() ?? [];
//           if (user.isEmpty) {
//             return Center(
//               child: Text(
//                 'No client data available',
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }
//           final selectedUser = user.firstWhere(
//             (u) => u.rKey == widget.args.rKey,
//             orElse: () => user.first,
//           );
//           return successState.status != 1
//               ? Center(
//                   child: Text(
//                     successState.message ?? 'Refresh to load data',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//               : Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 50),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.white, Colors.grey.shade50],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Client Info Section
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: Colors.blue.shade200,
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             spacing: 10,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade600,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: const Icon(
//                                   Icons.business,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Client',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.blue.shade700,
//                                       ),
//                                     ),
//                                     Text(
//                                       '${selectedUser.cCode} - ${selectedUser.cConsigneeName}',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // const SizedBox(height: 10),
//                         // Vendor Selection Section
//                       ],
//                     ),
//                   ),
//                 );
//         case const (HomeErrorStatus):
//           final errorState = state as HomeErrorStatus;
//           return Center(
//             child: Text(
//               'Error: ${errorState.errorMessage}',
//               style: const TextStyle(color: Colors.red),
//             ),
//           );
//         default:
//           return const SizedBox.shrink();
//       }
//     },
//   );

//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     if (!status.isGranted) {
//       if (mounted) {
//         showToast(context, 'Camera permission is required to use the scanner');
//       }
//     }
//   }

//   bool isShowListButton() {
//     final box = Boxes.getData();
//     final data = box.values.toList().cast<RoundDataModel>();
//     final clientData = data.where((item) => item.rKey == widget.args.rKey);
//     if (clientData.isNotEmpty) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   stopDuplicateQRScan(String code) {
//     final box = Boxes.getData();

//     final scannedData = box.values.toList().cast<RoundDataModel>();

//     final clientData = scannedData.where(
//       (item) => item.rKey == widget.args.rKey,
//     );

//     if (clientData.any((item) => item.batchID == result?.code)) {
//       // Show modern alert dialog for duplicate scan
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return Dialog(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.white, Colors.grey.shade50],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 25,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(28),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Icon with gradient background
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.orange.shade100, Colors.orange.shade50],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.orange.shade200.withOpacity(0.5),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.warning_amber_rounded,
//                       color: Colors.orange.shade600,
//                       size: 36,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Title
//                   Text(
//                     'Duplicate Scan Detected',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                       letterSpacing: 0.2,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   // Batch code info box
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.blue.shade200,
//                         width: 1.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.shade100.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.qr_code_2,
//                           color: Colors.blue.shade600,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             'Code: ${result?.code}',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blue.shade900,
//                               letterSpacing: 0.3,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Message
//                   Text(
//                     'This batch code has already been scanned. Would you like to add it again?',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade700,
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 28),
//                   // Action buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             context.pop();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey.shade200,
//                             foregroundColor: Colors.grey.shade700,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               side: BorderSide(
//                                 color: Colors.grey.shade300,
//                                 width: 1,
//                               ),
//                             ),
//                           ),
//                           child: Text(
//                             'Cancel',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             context.pop();
//                             _onScan(code);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: secondaryColor,
//                             foregroundColor: Colors.white,
//                             elevation: 4,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             shadowColor: secondaryColor.withOpacity(0.4),
//                           ),
//                           child: Text(
//                             'Add Again',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//       return;
//     } else {
//       _onScan(code);
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       if (mounted) {
//         setState(() {
//           result = null;
//         });
//         if (_qrViewController != null) {
//           _qrViewController!.resumeCamera();
//         }
//       }
//     } else if (state == AppLifecycleState.paused) {
//       if (_qrViewController != null) {
//         _qrViewController!.pauseCamera();
//       }
//     }
//   }

//   final TextEditingController _scanController = TextEditingController();
//   // final List<ScanData> _scannedItems = [];
//   String? batchCode;

//   Barcode? result;
//   QRViewController? _qrViewController;
//   final GlobalKey globalKey = GlobalKey(debugLabel: "QR");

//   StreamSubscription? _scanSubscription;
//   bool _isScanned = false;

//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     setState(() {
//       result = null;
//     });
//     if (Platform.isAndroid) {
//       _qrViewController!.pauseCamera();
//     } else {
//       _qrViewController!.resumeCamera();
//     }
//   }

//   /// Helper method to safely get values with default fallback
//   void _onScan(String value) {
//     if (value.trim().isEmpty) {
//       showToast(
//         context,
//         'No data scanned',
//         backgroundColor: Colors.red.shade400,
//       );
//     } else {
//       setState(() {
//         batchCode = value.toString();
//         _isScanned = true;
//         _scanController.clear();
//       });
//       context.pushNamed(
//         ScanDetailsView.routeName,
//         extra: SubmitData(
//           unitName: unitName ?? 'N/A ',
//           rKey: widget.args.rKey,
//           baseID: value.trim(),
//           unitIndex: widget.args.unitIndex,
//         ),
//       );

//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted && _qrViewController != null) {
//           _qrViewController!.resumeCamera();
//         }
//       });
//     }
//   }

//   void _rescanQR() {
//     setState(() {
//       result = null;
//       _isScanned = false;
//       batchCode = null;
//       _scanController.clear();
//     });
//     if (_qrViewController != null) {
//       _qrViewController!.resumeCamera();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // If no scanner type selected, show loading
//     if (selectedScannerType == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     // Show mobile scanner when selected
//     if (selectedScannerType == ScannerType.mobile) {
//       return _buildMobileScannerUI();
//     }

//     // Show external scanner UI when selected
//     return _buildExternalScannerUI();
//   }

//   Widget _buildMobileScannerUI() {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             onPressed: () {
//               GoRouter.of(context).pop();
//             },
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.qr_code_scanner,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Mobile Scanner (Camera)',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: secondaryColor,
//           elevation: 0,
//           actions: [
//             if (isShowListButton())
//               Container(
//                 margin: const EdgeInsets.only(right: 16),
//                 child: Badge(
//                   child: IconButton(
//                     onPressed: () => GoRouter.of(context).pushNamed(
//                       ScannedCarton.routeName,
//                       extra: ScannedData(
//                         rKey: widget.args.rKey,
//                         unitIndex: widget.args.unitIndex,
//                       ),
//                     ),
//                     icon: const Icon(
//                       Icons.list_alt_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         body: _buildQrView(context),
//       ),
//     );
//   }

//   Widget _buildExternalScannerUI() {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             onPressed: () {
//               externalScannerService.disconnect();
//               _externalScannerSubscription?.cancel();
//               GoRouter.of(context).pop();
//             },
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.devices_other,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'External Scanner',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       externalScannerService.isConnected
//                           ? 'Connected'
//                           : 'Connecting...',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.white70,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: secondaryColor,
//           elevation: 0,
//           actions: [
//             if (isShowListButton())
//               Container(
//                 margin: const EdgeInsets.only(right: 16),
//                 child: Badge(
//                   child: IconButton(
//                     onPressed: () => GoRouter.of(context).pushNamed(
//                       ScannedCarton.routeName,
//                       extra: ScannedData(
//                         rKey: widget.args.rKey,
//                         unitIndex: widget.args.unitIndex,
//                       ),
//                     ),
//                     icon: const Icon(
//                       Icons.list_alt_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         body: _buildExternalScannerContent(context),
//       ),
//     );
//   }

//   Widget _buildExternalScannerContent(BuildContext context) {
//     return Stack(
//       children: [
//         buildContent,
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           bottom: 0,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue.shade100, Colors.blue.shade50],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade200.withOpacity(0.5),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.devices_other,
//                     color: Colors.blue.shade600,
//                     size: 64,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'External Scanner Ready',
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   externalScannerService.isConnected
//                       ? 'Please scan items on the external device'
//                       : 'Connecting to scanner...',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade700,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.green.shade200,
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: Colors.green.shade600,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Auto-scanning enabled',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.green.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     externalScannerService.disconnect();
//                     _externalScannerSubscription?.cancel();
//                     setState(() {
//                       selectedScannerType = null;
//                     });
//                     _showScannerSelectionDialog();
//                   },
//                   icon: const Icon(Icons.swap_horiz, color: Colors.white),
//                   label: Text(
//                     'Switch Scanner',
//                     style: GoogleFonts.poppins(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade600,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 28,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQrView(BuildContext context) {
//     Size size = MediaQuery.sizeOf(context);
//     var scanArea = (size.width < 600 || size.height < 600) ? 280.0 : 320.0;

//     return Stack(
//       children: [
//         QRView(
//           key: globalKey,
//           onQRViewCreated: _onQRViewCreated,
//           overlay: QrScannerOverlayShape(
//             borderColor: secondaryColor,
//             borderRadius: 12,
//             borderLength: 40,
//             borderWidth: 10,
//             cutOutSize: scanArea,
//             overlayColor: Colors.black87,
//           ),
//           cameraFacing: CameraFacing.back,
//         ),
//         Positioned(
//           top: size.height * 0.025,
//           left: 0,
//           right: 0,
//           child: buildContent,
//         ),
//         if (_isScanned)
//           Positioned(
//             bottom: size.height * 0.08,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: ElevatedButton.icon(
//                 onPressed: _rescanQR,
//                 icon: const Icon(Icons.refresh, color: Colors.white),
//                 label: Text(
//                   'Rescan',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: secondaryColor,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     // Prevent duplicate initialization
//     if (_qrViewController != null) {
//       return;
//     }

//     setState(() {
//       _qrViewController = controller;
//     });

//     // Cancel any existing subscription before creating a new one
//     _scanSubscription?.cancel();

//     // Stream listener for continuous scanning
//     _scanSubscription = controller.scannedDataStream.listen((scanData) {
//       if (!mounted) return;

//       // Check if it's a valid QR code
//       if (scanData.code != null && scanData.code!.isNotEmpty) {
//         // Prevent multiple scans of the same code in quick succession
//         if (result?.code != scanData.code) {
//           setState(() {
//             result = scanData;
//           });

//           stopDuplicateQRScan(scanData.code.toString());
//           // Pause camera after successful scan
//           controller.pauseCamera();

//           Future.delayed(const Duration(seconds: 2), () {
//             if (mounted && _qrViewController != null) {
//               _qrViewController!.resumeCamera();
//               setState(() {
//                 result = null;
//               });
//             }
//           });
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scanSubscription?.cancel();
//     _externalScannerSubscription?.cancel();
//     // Disconnect external scanner
//     externalScannerService.disconnect();
//     externalScannerService.dispose();
//     _scanController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }
