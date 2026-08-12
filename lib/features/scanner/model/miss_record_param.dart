class MissRecordParam {
  final int batchID;
  final int batchQuantity;
  final String query;
  final dynamic availableQuantity;
  final String reason;

  MissRecordParam({
    required this.batchID,
    required this.batchQuantity,
    required this.query,
    required this.availableQuantity,
    required this.reason,
  });
}
