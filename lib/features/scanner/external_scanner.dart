import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indo_mobile/core/database/boxes.dart';
import 'package:indo_mobile/core/theme/color_conts.dart';
import 'package:indo_mobile/core/util/toast.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';
import 'package:indo_mobile/features/scanner/scan_details_view.dart';
import 'package:indo_mobile/features/scanner/scanned_carton.dart';

import 'package:indo_mobile/features/scanner/scanner_view.dart';

class ExternalScanner extends StatefulWidget {
  const ExternalScanner({super.key, required this.args});
  static const String routeName = '/external-scanner';
  final ScannerViewArguments args;

  @override
  State<ExternalScanner> createState() => _ExternalScannerState();
}

class _ExternalScannerState extends State<ExternalScanner> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
  bool _isSubmitting = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isShowListButton();
    // Auto focus the text field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocus.requestFocus();
    });
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

  Future<void> _submitBarcode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final barcode = _barcodeController.text.trim();

    if (barcode.isEmpty) {
      showToast(
        context,
        'Please enter a barcode',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Add your submission logic here
      await Future.delayed(const Duration(milliseconds: 500));

      showToast(
        context,
        'Barcode scanned successfully',
        backgroundColor: Colors.green.shade400,
      );

      final box = Boxes.getData();

      final scannedData = box.values.toList().cast<RoundDataModel>();

      final clientData = scannedData.where(
        (item) => item.rKey == widget.args.rKey,
      );

      if (clientData.any((item) => item.batchID == barcode)) {
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
                      Colors.white.withValues(alpha: 0.98),
                      Colors.white.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Color(0xFFFFA500).withValues(alpha: 0.15),
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
                            Color(0xFFFFA500).withValues(alpha: 0.25),
                            Color(0xFFFF8C00).withValues(alpha: 0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFFFA500).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFA500).withValues(alpha: 0.3),
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
                            Color(0xFF2D7FD9).withValues(alpha: 0.12),
                            Color(0xFF2D7FD9).withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Color(0xFF2D7FD9).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2D7FD9).withValues(alpha: 0.1),
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
                              color: Color(0xFF2D7FD9).withValues(alpha: 0.2),
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
                                  barcode,
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

                        if (barcode.contains('s') ||
                            barcode.contains('t') ||
                            barcode.contains('r') ||
                            barcode.contains('S') ||
                            barcode.contains('T') ||
                            barcode.contains('R'))
                          SizedBox()
                        else ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2D7FD9),
                                foregroundColor: Colors.white,
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: Color(
                                  0xFF2D7FD9,
                                ).withValues(alpha: 0.4),
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
        // Wait for snackbar to show, then navigate
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          context.pushNamed(
            ScanDetailsView.routeName,
            extra: SubmitData(
              unitName: widget.args.unitName ?? 'N/A',
              rKey: widget.args.rKey,
              baseID: barcode,
              unitIndex: widget.args.unitIndex,
            ),
          );
        }
        _barcodeController.clear();
        _barcodeFocus.requestFocus();
        // _submitBarcode();
      }
    } catch (e) {
      showToast(context, 'Error: $e', backgroundColor: Colors.red.shade400);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'External Scanner',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (isShowListButton())
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => GoRouter.of(context).pushNamed(
                    ScannedCarton.routeName,
                    extra: ScannedData(
                      rKey: widget.args.rKey,
                      unitIndex: widget.args.unitIndex,
                      clientName: widget.args.clientName ?? 'N/A',
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
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
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              secondaryColor.withValues(alpha: 0.1),
              secondaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          secondaryColor.withValues(alpha: 0.2),
                          secondaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Scan Barcode',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'Enter or scan the barcode below',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Text Field
                  Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _barcodeController,
                        focusNode: _barcodeFocus,
                        keyboardType: TextInputType.none,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a barcode';
                          }
                          return null;
                        },
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter barcode...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: secondaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: Icon(
                              Icons.barcode_reader,
                              color: secondaryColor,
                              size: 24,
                            ),
                          ),
                          suffixIcon: _barcodeController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _barcodeController.clear();
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {});
                          // Auto-submit if barcode ends with Enter
                          if (value.endsWith('\n')) {
                            _barcodeController.text = value.replaceAll(
                              '\n',
                              '',
                            );
                            _submitBarcode();
                          }
                        },
                        onFieldSubmitted: (_) => _submitBarcode(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          secondaryColor,
                          secondaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSubmitting ? null : () => _submitBarcode(),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSubmitting)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              const SizedBox(width: 12),
                              Text(
                                _isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit Barcode',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Clear Button
                  TextButton.icon(
                    onPressed: () {
                      _barcodeController.clear();
                      setState(() {});
                      _barcodeFocus.requestFocus();
                    },
                    icon: Icon(Icons.refresh, color: Colors.grey.shade600),
                    label: Text(
                      'Clear & Scan Again',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
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

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }
}
