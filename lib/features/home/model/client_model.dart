class ClientModel {
  int? status;
  String? message;
  List<Record>? record;
  int? pageQty;

  ClientModel({this.status, this.message, this.record, this.pageQty});

  ClientModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['record'] != null) {
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(new Record.fromJson(v));
      });
    }
    pageQty = json['pageQty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.record != null) {
      data['record'] = this.record!.map((v) => v.toJson()).toList();
    }
    data['pageQty'] = this.pageQty;
    return data;
  }
}

class Record {
  int? sNo;
  String? cCode;
  String? cConsigneeName;
  String? cMobileNumber;
  String? cAlternateNumber;
  String? cGSTIN;
  String? cOwnerName;
  String? cOwnerMobileNumber;
  String? cOwnerAlternateNumber;
  String? cPurchaseManagerName;
  String? cPurchaseManagerNumber;
  String? cPurchaseManagerAlternateNumber;
  List<UnitList>? unitList;
  String? rKey;
  int? rStatus;

  Record(
      {this.sNo,
      this.cCode,
      this.cConsigneeName,
      this.cMobileNumber,
      this.cAlternateNumber,
      this.cGSTIN,
      this.cOwnerName,
      this.cOwnerMobileNumber,
      this.cOwnerAlternateNumber,
      this.cPurchaseManagerName,
      this.cPurchaseManagerNumber,
      this.cPurchaseManagerAlternateNumber,
      this.unitList,
      this.rKey,
      this.rStatus});

  Record.fromJson(Map<String, dynamic> json) {
    sNo = json['SNo'];
    cCode = json['cCode'];
    cConsigneeName = json['cConsigneeName'];
    cMobileNumber = json['cMobileNumber'];
    cAlternateNumber = json['cAlternateNumber'];
    cGSTIN = json['cGSTIN'];
    cOwnerName = json['cOwnerName'];
    cOwnerMobileNumber = json['cOwnerMobileNumber'];
    cOwnerAlternateNumber = json['cOwnerAlternateNumber'];
    cPurchaseManagerName = json['cPurchaseManagerName'];
    cPurchaseManagerNumber = json['cPurchaseManagerNumber'];
    cPurchaseManagerAlternateNumber = json['cPurchaseManagerAlternateNumber'];
    if (json['unitList'] != null) {
      unitList = <UnitList>[];
      json['unitList'].forEach((v) {
        unitList!.add(new UnitList.fromJson(v));
      });
    }
    rKey = json['rKey'];
    rStatus = json['rStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SNo'] = this.sNo;
    data['cCode'] = this.cCode;
    data['cConsigneeName'] = this.cConsigneeName;
    data['cMobileNumber'] = this.cMobileNumber;
    data['cAlternateNumber'] = this.cAlternateNumber;
    data['cGSTIN'] = this.cGSTIN;
    data['cOwnerName'] = this.cOwnerName;
    data['cOwnerMobileNumber'] = this.cOwnerMobileNumber;
    data['cOwnerAlternateNumber'] = this.cOwnerAlternateNumber;
    data['cPurchaseManagerName'] = this.cPurchaseManagerName;
    data['cPurchaseManagerNumber'] = this.cPurchaseManagerNumber;
    data['cPurchaseManagerAlternateNumber'] =
        this.cPurchaseManagerAlternateNumber;
    if (this.unitList != null) {
      data['unitList'] = this.unitList!.map((v) => v.toJson()).toList();
    }
    data['rKey'] = this.rKey;
    data['rStatus'] = this.rStatus;
    return data;
  }
}

class UnitList {
  String? unitName;
  int? unitIndex;

  UnitList({this.unitName, this.unitIndex});

  UnitList.fromJson(Map<String, dynamic> json) {
    unitName = json['unitName'];
    unitIndex = json['unitIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unitName'] = this.unitName;
    data['unitIndex'] = this.unitIndex;
    return data;
  }
}