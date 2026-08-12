String _parseStringValue(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  return value.toString();
}

class ChallanDetailsResponse {
  final int? status;
  final ChallanInfo? challanInfo;
  final dynamic totalRequest;
  final dynamic missedRequest;
  final dynamic acceptRequest;
  final List<MissedRecordItem>? missedRecord;
  final String? message;

  ChallanDetailsResponse({
    this.status,
    this.challanInfo,
    this.totalRequest,
    this.missedRequest,
    this.acceptRequest,
    this.missedRecord,
    this.message,
  });

  factory ChallanDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ChallanDetailsResponse(
      status: json['status'] ?? 0,
      challanInfo: ChallanInfo.fromJson(json['challanInfo'] ?? {}),
      totalRequest: json['totalRequest'] ?? 0,
      missedRequest: json['missedRequest'] ?? 0,
      acceptRequest: json['acceptRequest'] ?? 0,
      missedRecord:
          (json['missedRecord'] as List<dynamic>?)
              ?.map((e) => MissedRecordItem.fromJson(e))
              .toList() ??
          [],
      message: _parseStringValue(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'challanInfo': challanInfo?.toJson(),
      'totalRequest': totalRequest,
      'missedRequest': missedRequest,
      'acceptRequest': acceptRequest,
      'missedRecord': missedRecord?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class ChallanInfo {
  final String challanNumber;
  final String challanDate;
  final String? consigneeeName;
  final String? unitName;
  final List<OutListItem> outList;

  ChallanInfo({
    required this.challanNumber,
    required this.challanDate,
    this.consigneeeName,
    this.unitName,
    required this.outList,
  });

  factory ChallanInfo.fromJson(Map<String, dynamic> json) {
    return ChallanInfo(
      challanNumber: _parseStringValue(json['challanNumber']),
      challanDate: _parseStringValue(json['challanDate']),
      consigneeeName: _parseStringValue(json['consigneeeName']),
      unitName: _parseStringValue(json['unitName']),
      outList:
          (json['outList'] as List<dynamic>?)
              ?.map((e) => OutListItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challanNumber': challanNumber,
      'challanDate': challanDate,
      'consigneeeName': consigneeeName,
      'unitName': unitName,
      'outList': outList.map((e) => e.toJson()).toList(),
    };
  }
}

class OutListItem {
  final dynamic batchStatus;
  final String batchCode;
  final dynamic batchQty;
  final dynamic requiredQty;
  final String batchMessage;

  OutListItem({
    required this.batchStatus,
    required this.batchCode,
    required this.batchQty,
    required this.requiredQty,
    required this.batchMessage,
  });

  factory OutListItem.fromJson(Map<String, dynamic> json) {
    return OutListItem(
      batchStatus: json['batchStatus'] ?? 0,
      batchCode: _parseStringValue(json['batchCode']),
      batchQty: json['batchQty'] ?? 0,
      requiredQty: json['requiredQty'] ?? 0,
      batchMessage: _parseStringValue(json['batchMessage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchStatus': batchStatus,
      'batchCode': batchCode,
      'batchQty': batchQty,
      'requiredQty': requiredQty,
      'batchMessage': batchMessage,
    };
  }
}

class MissedRecordItem {
  final dynamic batchID;
  final dynamic batchQuantity;
  final String query;
  final dynamic availableQuantity;
  final String reason;

  MissedRecordItem({
    required this.batchID,
    required this.batchQuantity,
    required this.query,
    required this.availableQuantity,
    required this.reason,
  });

  factory MissedRecordItem.fromJson(Map<String, dynamic> json) {
    return MissedRecordItem(
      batchID: json['batchID'] ?? '',
      batchQuantity: json['batchQuantity'] ?? 0,
      query: _parseStringValue(json['query']),
      availableQuantity: json['availableQuantity'] ?? 0,
      reason: _parseStringValue(json['reason']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchID': batchID,
      'batchQuantity': batchQuantity,
      'query': query,
      'availableQuantity': availableQuantity,
      'reason': reason,
    };
  }
}
