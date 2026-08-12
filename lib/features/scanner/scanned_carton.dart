import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:indo_mobile/core/database/boxes.dart';
import 'package:indo_mobile/core/di/sl.dart';
import 'package:indo_mobile/core/theme/color_conts.dart';
import 'package:indo_mobile/core/util/toast.dart';
import 'package:indo_mobile/features/scanner/bloc/round_details_bloc.dart';
import 'package:indo_mobile/features/scanner/challan_details.dart';
import 'package:indo_mobile/features/scanner/miss_record.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';
import 'package:indo_mobile/features/scanner/widgets/submittion_success_msg.dart';

class ScannedData {
  final String rKey;
  final String unitIndex;
  final String? clientName;

  ScannedData({required this.rKey, required this.unitIndex, this.clientName});
}

class ScannedCarton extends StatefulWidget {
  const ScannedCarton({super.key, required this.data});
  // final List<ScanData> scannedItems;
  final ScannedData data;
  static const String routeName = '/scanned-carton';

  @override
  State<ScannedCarton> createState() => _ScannedCartonState();
}

class _ScannedCartonState extends State<ScannedCarton> {
  List<String> batchCodes = [];
  List<String> batchQty = [];
  List<String> unitIndex = [];
  late final RoundDetailsBloc _roundDetailsBloc;
  bool isShowButton = false;
  @override
  void initState() {
    super.initState();
    log(
      'ScannerView initialized with rKey: ${widget.data.rKey}, unitIndex: ${widget.data.unitIndex}',
    );
    _roundDetailsBloc = sl<RoundDetailsBloc>();
    loader();
  }

  Future<void> loader() async {
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  int _scannedItemCount = 0;
  int _totalQuantity = 0;
  int _totalScannedCount = 0;
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                children: [
                  Text(
                    'Scanned Cartons',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    widget.data.clientName ?? 'Unknown Client',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF2D7FD9), const Color(0xFF1E5BA8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D7FD9).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading scanned items...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ValueListenableBuilder<Box<RoundDataModel>>(
                valueListenable: Boxes.getData().listenable(),
                builder: (context, box, child) {
                  final scannedData = box.values
                      .toList()
                      .cast<RoundDataModel>();
                  final scannedDataByKey = scannedData
                      .where((element) => element.rKey == widget.data.rKey)
                      .toList()
                      .reversed
                      .toList();

                  // ============================================
                  // BLOCK 1: GROUP ITEMS BY BATCH ID
                  // ============================================
                  // Create a Map where:
                  // - Key: batchID (unique identifier for each batch)
                  // - Value: List of all RoundDataModel items with that batchID
                  Map<String, List<RoundDataModel>> groupedByBatchId = {};

                  // Loop through all scanned items to group them
                  for (var item in scannedDataByKey) {
                    // Extract batchID from item, use 'N/A' if batchID is null
                    final batchId = item.batchID ?? 'N/A';

                    // Check if this batchID doesn't already exist in our map
                    if (!groupedByBatchId.containsKey(batchId)) {
                      // Create an empty list for this new batchID
                      groupedByBatchId[batchId] = [];
                    }

                    // Add the current item to the list for this batchID
                    // The ! operator means we're sure the key exists (we just created it above)
                    groupedByBatchId[batchId]!.add(item);
                  }

                  // ============================================
                  // BLOCK 2: CREATE MERGED ITEMS & COUNT DUPLICATES
                  // ============================================
                  // Create a list to store only unique batch items (no duplicates)
                  // This will show only the first occurrence of each batch
                  final mergedItems = <RoundDataModel>[];

                  // Create a Map to track how many times each batch appears
                  // Key: batchID, Value: count of duplicates (e.g., x2 means scanned twice)
                  final duplicateCounts = <String, int>{};

                  // Loop through all scanned items again to process them
                  for (var item in scannedDataByKey) {
                    // Extract batchID from item, use 'N/A' if null
                    final batchId = item.batchID ?? 'N/A';

                    // Check if we haven't processed this batchID yet
                    if (!duplicateCounts.containsKey(batchId)) {
                      // Add the first occurrence of this batch to our merged list
                      // This ensures we only show each unique batch once
                      mergedItems.add(item);

                      // Store how many total times this batchID appears
                      // Get the count from groupedByBatchId (which we created in BLOCK 1)
                      // Example: if batch '12345' appears 3 times, this stores 3
                      duplicateCounts[batchId] =
                          groupedByBatchId[batchId]!.length;
                    }
                  }

                  final scannedQntByKey = scannedData
                      .where(
                        (element) =>
                            element.quantity.toString() == element.quantity,
                      )
                      .toList()
                      .reversed
                      .toList();
                  // final unitIndexList = scannedData
                  //     .where(
                  //       (element) =>
                  //           element.unitIndex.toString() == element.unitIndex,
                  //     )
                  //     .toList()
                  //     .reversed
                  //     .toList();

                  _scannedItemCount = mergedItems.length;
                  _totalQuantity = mergedItems.fold(0, (sum, item) {
                    final qty = int.tryParse(item.quantity ?? '0') ?? 0;
                    return sum + qty;
                  });
                  _totalScannedCount = duplicateCounts.values.fold(
                    0,
                    (sum, count) => sum + count,
                  );

                  // Update state variables without calling setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && mergedItems.isNotEmpty && !isShowButton) {
                      setState(() {
                        isShowButton = true;
                      });
                    }
                  });

                  batchCodes = mergedItems.expand((element) {
                    final batchId = element.batchID?.split(',').join(',') ?? '';
                    final duplicateCount =
                        duplicateCounts[element.batchID ?? 'N/A'] ?? 1;
                    return List.filled(duplicateCount, batchId);
                  }).toList();
                  batchQty = scannedQntByKey
                      .map(
                        (element) =>
                            element.quantity?.split(',').join(',') ?? '',
                      )
                      .toList();

                  // unitIndex = unitIndexList
                  //     .map(
                  //       (element) =>
                  //           element.unitIndex?.split(',').join(',') ?? '',
                  //     )
                  //     .toList();
                  return mergedItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: secondaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.inbox_rounded,
                                  size: 64,
                                  color: secondaryColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Scanned Items',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start scanning cartons to see them here',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: mergedItems.length,
                              itemBuilder: (context, index) {
                                final item = mergedItems[index];
                                final duplicateCount =
                                    duplicateCounts[item.batchID ?? 'N/A'] ?? 1;

                                return _buildCartonCard(
                                  item,
                                  index,
                                  duplicateCount,
                                );
                              },
                            ),
                          ],
                        );
                },
              ),
        bottomNavigationBar: _buildBottomSubmitBar(),
      ),
    );
  }

  Widget _buildCartonCard(RoundDataModel item, int index, int duplicateCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            color: const Color(0xFF2D7FD9).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Theme(
            data: ThemeData(useMaterial3: true),
            child: Material(
              color: Colors.transparent,
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
                child: ExpansionTile(
                  backgroundColor: Colors.transparent,
                  collapsedBackgroundColor: Colors.transparent,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2D7FD9).withOpacity(0.9),
                          const Color(0xFF2D7FD9).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D7FD9).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.batchID?.toString() ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D7FD9),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 10,
                          //     vertical: 6,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     gradient: LinearGradient(
                          //       begin: Alignment.topLeft,
                          //       end: Alignment.bottomRight,
                          //       colors: [
                          //         const Color(0xFF2D7FD9).withOpacity(0.12),
                          //         const Color(0xFF2D7FD9).withOpacity(0.06),
                          //       ],
                          //     ),
                          //     borderRadius: BorderRadius.circular(8),
                          //     border: Border.all(
                          //       color: const Color(0xFF2D7FD9).withOpacity(0.2),
                          //       width: 1,
                          //     ),
                          //   ),
                          //   child: Text(
                          //     'Item ${index + 1}',
                          //     style: GoogleFonts.poppins(
                          //       fontSize: 11,
                          //       fontWeight: FontWeight.w700,
                          //       color: const Color(0xFF2D7FD9),
                          //       letterSpacing: 0.2,
                          //     ),
                          //   ),
                          // ),
                          if (duplicateCount > 1)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.2),
                                    Colors.orange.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.layers_rounded,
                                    size: 14,
                                    color: Colors.orange.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'x$duplicateCount',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange.shade600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      item.productType == 1
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'MIC:${item.micLabel}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Base:${item.baseLabel}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Length:${item.tapeLength}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'CutMMMeters:${item.cutMMMeter}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'NetWeight:50',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'GrossWeight:${item.stretchWeigh}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'FilmSize:${item.size}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Core:${item.operation}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Delete Item?',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              'Remove this scanned carton permanently. This action cannot be undone.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  'Keep',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _totalScannedCount = _totalScannedCount - 1;
                                  });
                                  Navigator.of(context).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (shouldDelete == true) {
                          item.delete();
                        }
                      },
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.red.shade500,
                        size: 22,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF2D7FD9).withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Details',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2D7FD9),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailGrid(item),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid(RoundDataModel item) {
    return Column(
      children: [
        _buildDetailRow2(
          'BatchCode',
          item.batchCode,

          item.productType == 1 ? 'Cut MM Meter' : 'Stretch Weight',
          item.productType == 1 ? item.cutMMMeter : item.stretchWeigh,
        ),
        const SizedBox(height: 12),
        _buildDetailRow2(
          'Mic Label',
          item.micLabel,
          'Base Label',
          item.baseLabel,
        ),
        // const SizedBox(height: 12),
        // _buildDetailRow2('Mic ID', item.micID),
        const SizedBox(height: 12),
        item.productType == 1
            ? _buildDetailRow2(
                item.showFor == '1' ? 'Tape Length' : 'Tape Weight',
                item.showFor == '1' ? item.tapeLength : item.tapeWeight,
                'Round Count',
                item.roundCount,
              )
            : _buildDetailRow2(
                'Operation',
                item.operation,
                'Round Count',
                item.roundCount,
              ),
        // const SizedBox(height: 12),
        // _buildDetailRow2(
        //   'So',
        //  ,
        //   'Tape Weight',
        //   ,
        // ),
        const SizedBox(height: 12),
        _buildDetailRow2(
          item.productType == 1 ? 'Pieces Per Carton' : 'Size',
          item.productType == 1 ? item.piecesPerCarton : item.size,

          'Display MFG',
          item.displayMFG,
        ),
        // const SizedBox(height: 12),
        // _buildDetailRow2('Unit', item.unitName, '', ''),

        // const SizedBox(height: 12),
      ],
    );
  }

  String _convertToString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value;
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  Widget _buildDetailRow2(
    String label1,
    dynamic value1,
    String label2,
    dynamic value2,
  ) {
    final displayValue1 = _convertToString(value1);
    final displayValue2 = _convertToString(value2);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D7FD9).withOpacity(0.12),
                  const Color(0xFF2D7FD9).withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2D7FD9).withOpacity(0.2),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D7FD9).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label1,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displayValue1,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D7FD9).withOpacity(0.12),
                  const Color(0xFF2D7FD9).withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2D7FD9).withOpacity(0.2),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D7FD9).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label2,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displayValue2,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSubmitBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: const Color(0xFF2D7FD9).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2D7FD9).withOpacity(0.08),
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2D7FD9).withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanned Items',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_totalScannedCount Cartons',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  if (isShowButton) submitButton,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get submitButton => BlocConsumer(
    bloc: _roundDetailsBloc,
    listener: (context, state) {
      if (state is SubmitRoundScannedDataSuccessStatus) {
        if (state.model.status == 1) {
          showToast(
            context,
            state.model.message.toString(),
            backgroundColor: Colors.green,
          );

          GoRouter.of(
            context,
          ).pushNamed(ChallanDetailsPage.routeName, extra: state.model);
          Future.delayed(Duration(seconds: 3), () {
            final box = Boxes.getData();
            box.clear();
          });
        } else {
          showToast(
            context,
            state.model.message.toString(),
            backgroundColor: Colors.redAccent,
          );
          GoRouter.of(
            context,
          ).pushNamed(ChallanDetailsPage.routeName, extra: state.model);
          // if (state.model.missedRecord != null &&
          //     state.model.missedRecord!.isNotEmpty) {
          //   GoRouter.of(
          //     context,
          //   ).pushNamed(MissRecordPanel.routeName, extra: state.model);
          // }
        }
      }
      if (state is SubmitRoundScannedDataFailureStatus) {
        showToast(
          context,
          state.errorMessage,
          backgroundColor: Colors.redAccent,
        );
      }
    },
    builder: (context, state) {
      if (state is RoundDetailsLoadingStatus) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2D7FD9).withOpacity(0.9),
                const Color(0xFF2D7FD9),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D7FD9).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D7FD9).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            _roundDetailsBloc.add(
              SubmitRoundScannedDataEvent(
                batchCodes: batchCodes,
                clientKey: widget.data.rKey,
                unitIndex: widget.data.unitIndex.toString(),
                batchQty: batchQty,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D7FD9),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          icon: Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          label: Text(
            'Submit',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    },
  );

  // Color _getRemarkColor(String remark) {
  //   switch (remark.toLowerCase()) {
  //     case 'good':
  //       return Colors.green;
  //     case 'damaged':
  //       return Colors.red;
  //     case 'pending':
  //       return Colors.orange;
  //     default:
  //       return Colors.blue;
  //   }
  // }
}
