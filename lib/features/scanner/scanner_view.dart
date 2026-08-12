import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indo_mobile/core/database/boxes.dart';
import 'package:indo_mobile/core/di/sl.dart';
import 'package:indo_mobile/core/util/toast.dart';
import 'package:indo_mobile/features/home/bloc/home_bloc.dart';
import 'package:indo_mobile/features/scanner/external_scanner.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';
import 'package:indo_mobile/features/scanner/scan_details_view.dart';
import 'package:indo_mobile/features/scanner/scanned_carton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScannerViewArguments {
  final String rKey;
  final String unitIndex;
  final String? unitName;
  final String? clientName;
  ScannerViewArguments({
    required this.rKey,
    required this.unitIndex,
    this.unitName,
    this.clientName,
  });
}

class ScannerView extends StatefulWidget {
  const ScannerView({super.key, required this.args});
  final ScannerViewArguments args;
  static const String routeName = '/scanner';

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  late final HomeBloc homeBloc;
  String? units;
  String? unitName;

  @override
  void initState() {
    super.initState();

    log(
      'ScannerView initialized with rKey: ${widget.args.rKey}, unitIndex: ${widget.args.unitIndex}',
    );
    homeBloc = sl<HomeBloc>();
    homeBloc.add(FetchClientDataEvent(filterBy: '1', keyword: ''));
    result = null;
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
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
                  'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        case const (HomeClientDataLoadedSuccessStatus):
          final successState =
              (state as HomeClientDataLoadedSuccessStatus).clientModel;

          final user = successState.record?.toList() ?? [];
          if (user.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 48,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No client data available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          final selectedUser = user.firstWhere(
            (u) => u.rKey == widget.args.rKey,
            orElse: () => user.first,
          );
          clientName = selectedUser.cConsigneeName.toString();
          return successState.status != 1
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.red.withOpacity(0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        successState.message ?? 'Refresh to load data',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Client Info Section
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2D7FD9).withOpacity(0.15),
                                      Color(0xFF2D7FD9).withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF2D7FD9).withOpacity(0.3),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        0xFF2D7FD9,
                                      ).withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  spacing: 12,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF2D7FD9),
                                            Color(0xFF1E5BA8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              0xFF2D7FD9,
                                            ).withOpacity(0.4),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.business_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Scanning For',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2D7FD9),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${selectedUser.cCode} - ${selectedUser.cConsigneeName}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade900,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
        case const (HomeErrorStatus):
          final errorState = state as HomeErrorStatus;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'Error',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    errorState.errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
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

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        showToast(context, 'Camera permission is required to use the scanner');
      }
    }
  }

  int scanCount = 0;

  bool isShowListButton() {
    final box = Boxes.getData();
    final data = box.values.toList().cast<RoundDataModel>();
    final clientData = data.where((item) => item.rKey == widget.args.rKey);
    if (clientData.isNotEmpty) {
      setState(() {
        scanCount = clientData.length;
      });
      return true;
    } else {
      return false;
    }
  }

  stopDuplicateQRScan(String code) {
    final box = Boxes.getData();

    final scannedData = box.values.toList().cast<RoundDataModel>();

    final clientData = scannedData.where(
      (item) => item.rKey == widget.args.rKey,
    );

    if (clientData.any((item) => item.batchID == result?.code)) {
      // Show modern alert dialog for duplicate scan
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.98),
                    Colors.white.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Color(0xFFFFA500).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFA500).withOpacity(0.25),
                          Color(0xFFFF8C00).withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFFFA500).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFA500).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFFA500),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'Duplicate Scan',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade900,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    'This batch code has already been scanned.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // Batch code info box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2D7FD9).withOpacity(0.12),
                          Color(0xFF2D7FD9).withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Color(0xFF2D7FD9).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF2D7FD9).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF2D7FD9).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            color: Color(0xFF2D7FD9),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D7FD9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result?.code ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade900,
                                  letterSpacing: 0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.grey.shade700,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      if ((result?.code ?? '').contains('s') ||
                          (result?.code ?? '').contains('t') ||
                          (result?.code ?? '').contains('r') ||
                          (result?.code ?? '').contains('S') ||
                          (result?.code ?? '').contains('T') ||
                          (result?.code ?? '').contains('R'))
                        SizedBox()
                      else ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.pop();
                              _onScan(code);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2D7FD9),
                              foregroundColor: Colors.white,
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Color(0xFF2D7FD9).withOpacity(0.4),
                            ),
                            child: Text(
                              'Add Again',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    } else {
      _onScan(code);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          result = null;
        });
        if (_qrViewController != null) {
          _qrViewController!.resumeCamera();
        }
      }
    } else if (state == AppLifecycleState.paused) {
      if (_qrViewController != null) {
        _qrViewController!.pauseCamera();
      }
    }
  }

  final TextEditingController _scanController = TextEditingController();
  // final List<ScanData> _scannedItems = [];
  String? batchCode;

  Barcode? result;
  String clientName = '';
  QRViewController? _qrViewController;
  final GlobalKey globalKey = GlobalKey(debugLabel: "QR");

  StreamSubscription? _scanSubscription;
  bool _isScanned = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    setState(() {
      result = null;
    });
    if (Platform.isAndroid) {
      _qrViewController!.pauseCamera();
    } else {
      _qrViewController!.resumeCamera();
    }
  }

  /// Helper method to safely get values with default fallback
  void _onScan(String value) {
    if (value.trim().isEmpty) {
      showToast(
        context,
        'No data scanned',
        backgroundColor: Colors.red.shade400,
      );
    } else {
      setState(() {
        batchCode = value.toString();
        _isScanned = true;
        _scanController.clear();
      });

      // Pause the camera before navigating away so it does not keep
      // running in the background on the details page.
      _qrViewController?.pauseCamera();

      context
          .pushNamed(
            ScanDetailsView.routeName,
            extra: SubmitData(
              unitName: unitName ?? 'N/A ',
              rKey: widget.args.rKey,
              baseID: value.trim(),
              unitIndex: widget.args.unitIndex,
            ),
          )
          .then((_) {
            // Resume the camera only after we return to this page.
            if (mounted && _qrViewController != null) {
              setState(() {
                result = null;
              });
              _qrViewController!.resumeCamera();
            }
          });
    }
  }

  void _rescanQR() {
    setState(() {
      result = null;
      _isScanned = false;
      batchCode = null;
      _scanController.clear();
    });
    if (_qrViewController != null) {
      _qrViewController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
          title: Row(
            children: [
              Text(
                'QR Scanner',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D7FD9), Color(0xFF1E5BA8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2D7FD9).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Text(
            //   scanCount > 0 ? '$scanCount Scanned' : '',
            //   style: GoogleFonts.poppins(
            //     fontSize: 14,
            //     color: Colors.white.withOpacity(0.9),
            //     fontWeight: FontWeight.w600,
            //     letterSpacing: 0.2,
            //   ),
            // ),
            if (isShowListButton()) ...[
              SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _qrViewController?.pauseCamera();
                      GoRouter.of(context)
                          .pushNamed(
                            ScannedCarton.routeName,
                            extra: ScannedData(
                              rKey: widget.args.rKey,
                              unitIndex: widget.args.unitIndex,
                              clientName: clientName.isNotEmpty
                                  ? clientName
                                  : widget.args.unitName?.isNotEmpty == true
                                  ? widget.args.unitName!
                                  : 'Unknown Client',
                            ),
                          )
                          .then((_) {
                            if (mounted) _qrViewController?.resumeCamera();
                          });
                    },
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
                      child: Badge(
                        label: Text(
                          '$scanCount',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Icon(
                          Icons.list_alt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        body: _buildQrView(context),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _qrViewController?.pauseCamera();
            GoRouter.of(context)
                .pushNamed(
                  ExternalScanner.routeName,
                  extra: ScannerViewArguments(
                    rKey: widget.args.rKey,
                    unitIndex: widget.args.unitIndex,
                    unitName: widget.args.unitName ?? '',
                    clientName: clientName.isNotEmpty
                        ? clientName
                        : widget.args.unitName?.isNotEmpty == true
                        ? widget.args.unitName!
                        : 'Unknown Client',
                  ),
                )
                .then((_) {
                  if (mounted) _qrViewController?.resumeCamera();
                });
          },
          icon: Icon(Icons.barcode_reader, color: Colors.white),
          label: Text(
            'Gun Scanner',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          backgroundColor: Color(0xFF2D7FD9),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    var scanArea = (size.width < 600 || size.height < 600) ? 280.0 : 320.0;

    return Stack(
      children: [
        QRView(
          key: globalKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Color(0xFF2D7FD9),
            borderRadius: 16,
            borderLength: 40,
            borderWidth: 10,
            cutOutSize: scanArea,
            overlayColor: Colors.black87,
          ),
          cameraFacing: CameraFacing.back,
        ),
        Positioned(
          top: size.height * 0.025,
          left: 0,
          right: 0,
          child: buildContent,
        ),
        if (_isScanned)
          Positioned(
            bottom: size.height * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2D7FD9).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _rescanQR,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Rescan',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D7FD9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    // Prevent duplicate initialization
    if (_qrViewController != null) {
      return;
    }

    setState(() {
      _qrViewController = controller;
    });

    // Cancel any existing subscription before creating a new one
    _scanSubscription?.cancel();

    // Stream listener for continuous scanning
    _scanSubscription = controller.scannedDataStream.listen((scanData) {
      if (!mounted) return;

      // Check if it's a valid QR code
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        // Prevent multiple scans of the same code in quick succession
        if (result?.code != scanData.code) {
          setState(() {
            result = scanData;
          });

          stopDuplicateQRScan(scanData.code.toString());
          // Pause camera after successful scan
          controller.pauseCamera();

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _qrViewController != null) {
              _qrViewController!.resumeCamera();
              setState(() {
                result = null;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    // Stop and release the camera so it does not keep running in the background.
    _qrViewController?.stopCamera();
    _qrViewController?.dispose();
    _qrViewController = null;
    _scanController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
