import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:indo_mobile/core/database/boxes.dart';
import 'package:indo_mobile/core/database/hive%20initialize.dart';
import 'package:indo_mobile/core/di/sl.dart';
import 'package:indo_mobile/core/util/toast.dart';
import 'package:indo_mobile/features/auth/scanned%20carton/scanned_carton.dart';
import 'package:indo_mobile/features/scanner/bloc/round_details_bloc.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';

class SubmitData {
  final String rKey;
  final String baseID;
  final String unitIndex;
  final String unitName;

  SubmitData({
    required this.rKey,
    required this.baseID,
    required this.unitIndex,
    required this.unitName,
  });
}

class ScanDetailsView extends StatefulWidget {
  final SubmitData submitData;
  const ScanDetailsView({super.key, required this.submitData});

  static const String routeName = '/scan-details';

  @override
  State<ScanDetailsView> createState() => _ScanDetailsViewState();
}

class _ScanDetailsViewState extends State<ScanDetailsView> {
  late final RoundDetailsBloc _roundDetailsBloc;
  // TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log(
      'ScannerView initialized with rKey: ${widget.submitData.rKey}, unitIndex: ${widget.submitData.unitIndex}',
    );
    _roundDetailsBloc = sl<RoundDetailsBloc>();
    // quantityController.text = '0';
    _roundDetailsBloc.add(
      FetchRoundDetailsEvent(batchCode: widget.submitData.baseID),
    );
  }

  // @override
  // void dispose() {
  //   quantityController.dispose();
  //   super.dispose();
  // }

  String _safeValue(dynamic value, {String defaultValue = 'N/A'}) {
    if (value == null) return defaultValue;
    if (value is String) return value.isEmpty ? defaultValue : value;
    if (value is int || value is double) return value.toString();
    return value.toString();
  }

  void saveDate(RoundDataModel data) async {
    final box = Hive.box<RoundDataModel>(HiveInitialize.roundBox);
    await box.add(data);
    // context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
          title: Text(
            'Scan Details',
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    GoRouter.of(context).pushNamed(ScannedCarton.routeName);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        ),
        body: BlocConsumer(
          bloc: _roundDetailsBloc,
          listener: (context, state) {
            if (state is RoundDetailsLoadedSuccessStatus) {
              if (state.dataModel.record != null) {
                log('Product Type: ${state.dataModel.record!.productType}');
              }
            } else if (state is RoundDetailsLoadedFailureStatus) {
              log('Failed to load round details: ${state.errorMessage}');
            }
          },
          builder: (context, state) {
            switch (state.runtimeType) {
              case const (RoundDetailsLoadingStatus):
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
                        'Loading scan details...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              case const (RoundDetailsLoadedSuccessStatus):
                final roundDetails =
                    (state as RoundDetailsLoadedSuccessStatus).dataModel;
                final record = roundDetails.record;

                // if (roundDetails.status != 1) {
                //   return Center(
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: Text(
                //         roundDetails.message.toString(),
                //         style: GoogleFonts.poppins(
                //           fontSize: 14,
                //           color: Colors.grey.shade600,
                //           fontWeight: FontWeight.w400,
                //         ),
                //       ),
                //     ),
                //   );
                // }

                return roundDetails.status != 1
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                roundDetails.message ?? 'Try again please.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // _buildQtyField,
                              // Tape Information Card
                              _buildInfoCard('Tape Information', [
                                if (record?.productType == 1) ...[
                                  _buildDetailItem(
                                    'Cut MM Meter',
                                    _safeValue(record?.cutMMMeter),
                                  ),
                                  _buildDetailItem(
                                    'Pieces Per Carton',
                                    _safeValue(record?.piecesPerCarton),
                                  ),
                                  _buildDetailItem(
                                    'Tape Length',
                                    _safeValue(record?.tapeLength),
                                  ),
                                ],
                                if (record?.productType == 2) ...[
                                  _buildDetailItem(
                                    'Size',
                                    _safeValue(record?.size),
                                  ),
                                  _buildDetailItem(
                                    'Stretch Weight',
                                    _safeValue(record?.stretchWeight),
                                  ),
                                  _buildDetailItem(
                                    'Operation',
                                    _safeValue(record?.operation),
                                  ),
                                ],
                                _buildDetailItem(
                                  'Base',
                                  _safeValue(record?.baseLabel),
                                ),
                                _buildDetailItem(
                                  'Mic',
                                  _safeValue(record?.micLabel),
                                ),
                              ]),
                              const SizedBox(height: 16),

                              // Base Information Card
                              // _buildInfoCard('Base Information', [
                              //   _buildDetailItem('Unit', widget.submitData.unitName),

                              // ]),
                              const SizedBox(height: 16),

                              // Mic Information Card
                              // _buildInfoCard('Mic Information', [
                              //   _buildDetailItem('Mic ID', _safeValue(record?.micID)),

                              // ]),
                              // const SizedBox(height: 16),

                              // Display Information Card
                              _buildInfoCard('Information', [
                                // _buildDetailItem(
                                //   'Show For',
                                //   _safeValue(record?.showFor),
                                // ),
                                // _buildDetailItem(
                                //   'Show Label',
                                //   _safeValue(record?.showLabel),
                                // ),
                                _buildDetailItem(
                                  'Batch Code',
                                  _safeValue(record?.batchCode),
                                ),
                                _buildDetailItem(
                                  'MFG',
                                  _safeValue(record?.displayMFG),
                                ),

                                _buildDetailItem(
                                  'Batch Remark',
                                  _safeValue(record?.batchRemark),
                                ),
                              ]),

                              // const SizedBox(height: 16),

                              // // Remarks Card
                              // _buildInfoCard('Remarks', []),
                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          GoRouter.of(context).pop();
                                        },
                                        icon: Icon(
                                          Icons.refresh_rounded,
                                          size: 20,
                                        ),
                                        label: Text(
                                          'Rescan',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade600,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              0xFF2D7FD9,
                                            ).withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 3,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final data = RoundDataModel(
                                            productType: record?.productType,
                                            size: record?.size,
                                            stretchWeigh: record?.stretchWeight,
                                            operation: record?.operation,
                                            unitName:
                                                widget.submitData.unitName,
                                            unitIndex:
                                                widget.submitData.unitIndex,
                                            // quantity: quantityController.text,
                                            rKey: widget.submitData.rKey,
                                            baseID:
                                                record?.baseID.toString() ?? '',
                                            piecesPerCarton:
                                                record?.piecesPerCarton
                                                    .toString() ??
                                                '',
                                            cutMMMeter:
                                                record?.cutMMMeter.toString() ??
                                                '',
                                            micID:
                                                record?.micID.toString() ?? '',
                                            micLabel:
                                                record?.micLabel.toString() ??
                                                '',
                                            showFor:
                                                record?.showFor.toString() ??
                                                '',
                                            tapeLength:
                                                record?.tapeLength.toString() ??
                                                '',
                                            batchRemark:
                                                record?.batchRemark
                                                    .toString() ??
                                                '',
                                            baseLabel:
                                                record?.baseLabel.toString() ??
                                                '',
                                            displayMFG:
                                                record?.displayMFG.toString() ??
                                                '',
                                            displayMFGLabel:
                                                record?.displayMFGLabel
                                                    .toString() ??
                                                '',
                                            tapeWeight:
                                                record?.tapeWeight.toString() ??
                                                '',
                                            showForLabel: '',
                                            batchID: widget.submitData.baseID,
                                            batchCode:
                                                record?.batchCode.toString() ??
                                                '',
                                            quantity: '1',
                                          );

                                          saveDate(data);
                                          if (mounted) {
                                            showToast(
                                              context,
                                              'Scan data saved successfully!',
                                              backgroundColor:
                                                  Colors.green.shade600,
                                            );
                                            GoRouter.of(context).pop();
                                          }

                                          // Save to Hive box
                                          // final box = Hive.box<RoundDataModel>(
                                          //   HiveInitialize.roundBox,
                                          // );
                                        },
                                        icon: Icon(
                                          Icons.check_circle_rounded,
                                          size: 20,
                                        ),
                                        label: Text(
                                          'Submit',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF2D7FD9),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
              case const (RoundDetailsLoadedFailureStatus):
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
                        'Error loading details',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  // Widget get _buildQtyField => Padding(
  //   padding: const EdgeInsets.only(bottom: 16),
  //   child: TextField(
  //     controller: quantityController,
  //     decoration: InputDecoration(
  //       labelText: 'Quantity',
  //       hintText: 'Enter quantity',
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //       filled: true,
  //       fillColor: Colors.grey.shade100,
  //       labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
  //       hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
  //     ),
  //     keyboardType: TextInputType.number,
  //     style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
  //   ),
  // );

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
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
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D7FD9),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D7FD9).withOpacity(0.12),
                  Color(0xFF2D7FD9).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(0xFF2D7FD9).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
