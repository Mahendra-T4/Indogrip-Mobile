// // Directly access the box data (synchronous read)
// final box = Boxes.getData();
// final scannedData = box.values.toList().cast<RoundDataModel>();
// final scannedDataByKey = scannedData
//     .where((element) => element.rKey == widget.rKey)
//     .toList()
//     .reversed
//     .toList();

// // Check your condition (example: if there are scanned items)
// if (scannedDataByKey.isNotEmpty) {
//   // Perform your action, e.g., show a button or update state
//   setState(() {
//     isShowButton = true;
//     _scannedItemCount = scannedDataByKey.length;
//     batchCodes = scannedDataByKey
//         .map((element) => element.batchID?.split(',').join(',') ?? '')
//         .toList();
//   });
// } else {
//   // Handle the empty case, e.g., show a message
//   print('No scanned batches found.');
// }