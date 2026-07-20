import 'package:flutter/foundation.dart';
class ShortListModel {
  final int id;
  final String wHouseAddress;
  final String wHouseName;
  final String totalArea;
  final String groundFloor;
  final int nOfFloors;
  final bool isAvailableForRent;
  final String wHouseType;
  final String wHouseConstructionType;
  final int constructionAge;
  final double wHouseRentPerSQFT;
  final String wHouseMaintenance;
  final int securityDeposit;
  final String wHouseTokenAdvance;
  final String wHouseLockInPeriod;
  final String currentAddress;
  final String filePath;
  final double warehouseCarpetArea;
  final String mobile;
  final String image;
  final String type;
  final String electricity;
  final bool powerBackup;
  final bool officeSpace;
  final bool dockLevelers;
  final int numberOfToilets;
  final int truckParkingSlot;
  final int bikeParkingSlot;
  final int numberOfFans;
  final int numberOfLights;
  final bool fireComplaints;
  final int numberOfDocks;
  final double length;
  final double width;
  final double sideHeight;
  final double centerHeight;
  final double docksOfHeight;
  final bool flexingModel;
  final String flooringType;
  final String furnishingType;
  final bool cluDocument;

  ShortListModel({
    this.id = 0,
    this.wHouseAddress = "",
    this.wHouseName = "",
    this.totalArea = "",
    this.groundFloor = "",
    this.nOfFloors = 0,
    this.isAvailableForRent = false,
    this.wHouseType = "",
    this.wHouseConstructionType = "",
    this.constructionAge = 0,
    this.wHouseRentPerSQFT = 0.0,
    this.wHouseMaintenance = "",
    this.securityDeposit = 0,
    this.wHouseTokenAdvance = "",
    this.wHouseLockInPeriod = "",
    this.currentAddress = "",
    this.filePath = "",
    this.warehouseCarpetArea = 0.0,
    this.mobile = "",
    this.image = "",
    this.type = "",
    this.electricity = "",
    this.powerBackup = false,
    this.officeSpace = false,
    this.dockLevelers = false,
    this.numberOfToilets = 0,
    this.truckParkingSlot = 0,
    this.bikeParkingSlot = 0,
    this.numberOfFans = 0,
    this.numberOfLights = 0,
    this.fireComplaints = false,
    this.numberOfDocks = 0,
    this.length = 0.0,
    this.width = 0.0,
    this.sideHeight = 0.0,
    this.centerHeight = 0.0,
    this.docksOfHeight = 0.0,
    this.flexingModel = false,
    this.flooringType = "",
    this.furnishingType = "",
    this.cluDocument = false,
  });

  factory ShortListModel.fromJson(Map<String, dynamic> json) {
    try {
      return ShortListModel(
        id: json['id'] ?? 0,
        wHouseAddress: json['whouse_address'] ?? "",
        wHouseName: json['whouse_name'] ?? "",
        totalArea: json['totalArea'] ?? "",
        groundFloor: json['graundFloor'] ?? "",
        nOfFloors: json['nOfFloors'] ?? 0,
        isAvailableForRent: json['isavilableForRent'] == 1,
        wHouseType: json['whouse_type'] ?? "",
        wHouseConstructionType: json['whouse_Cunstructiontype'] ?? "",
        constructionAge: json['cunstructiontAge'] ?? 0,
        wHouseRentPerSQFT: (json['whouse_rentPerSQFT'] != null)
            ? double.tryParse(json['whouse_rentPerSQFT'].toString()) ?? 0.0
            : 0.0,
        wHouseMaintenance: json['whouse_maintenance'] ?? "",
        securityDeposit: json['securityDeposit'] ?? 0,
        wHouseTokenAdvance: json['whouse_tokenAdvance'] ?? "",
        wHouseLockInPeriod: json['whouseLockinPeriod'] ?? "",
        currentAddress: json['current_address'] ?? "",
        filePath: json['filepath'] ?? "",
        warehouseCarpetArea: (json['warehouse_carpetarea'] != null)
            ? double.tryParse(json['warehouse_carpetarea'].toString()) ?? 0.0
            : 0.0,
        mobile: json['mobile'] ?? "",
        image: json['image'] ?? "",
        type: json['type'] ?? "",
        electricity: json['electricity'] ?? "",
        powerBackup: json['power_backup'] ?? false,
        officeSpace: json['office_space'] ?? false,
        dockLevelers: json['dock_levelers'] ?? false,
        numberOfToilets: json['numberOfToilets'] ?? 0,
        truckParkingSlot: json['truck_ParkingSlot'] ?? 0,
        bikeParkingSlot: json['bike_ParkingSlot'] ?? 0,
        numberOfFans: json['numberOfFans'] ?? 0,
        numberOfLights: json['numberOfLights'] ?? 0,
        fireComplaints: json['fireComplaints'] ?? false,
        numberOfDocks: int.tryParse(json['numberOfDocks'] ?? "0") ?? 0,
        length: (json['length'] != null)
            ? double.tryParse(json['length'].toString()) ?? 0.0
            : 0.0,
        width: (json['width'] != null)
            ? double.tryParse(json['width'].toString()) ?? 0.0
            : 0.0,
        sideHeight: (json['sideHeight'] != null)
            ? double.tryParse(json['sideHeight'].toString()) ?? 0.0
            : 0.0,
        centerHeight: (json['centerHeight'] != null)
            ? double.tryParse(json['centerHeight'].toString()) ?? 0.0
            : 0.0,
        docksOfHeight: (json['docksOfHeight'] != null)
            ? double.tryParse(json['docksOfHeight'].toString()) ?? 0.0
            : 0.0,
        flexingModel: json['flexiModel'] ?? false,
        flooringType: json['flooringType'] ?? "",
        furnishingType: json['furnishingType'] ?? "",
        cluDocument: json['cluDocument'] ?? false,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing warehouse data: $e");
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'whouse_address': wHouseAddress,
      'whouse_name': wHouseName,
      'totalArea': totalArea,
      'graundFloor': groundFloor,
      'nOfFloors': nOfFloors,
      'isavilableForRent': isAvailableForRent ? 1 : 0,
      'whouse_type': wHouseType,
      'whouse_Cunstructiontype': wHouseConstructionType,
      'cunstructiontAge': constructionAge,
      'whouse_rentPerSQFT': wHouseRentPerSQFT,
      'whouse_maintenance': wHouseMaintenance,
      'securityDeposit': securityDeposit,
      'whouse_tokenAdvance': wHouseTokenAdvance,
      'whouseLockinPeriod': wHouseLockInPeriod,
      'current_address': currentAddress,
      'filepath': filePath,
      'warehouse_carpetarea': warehouseCarpetArea,
      'mobile': mobile,
      'image': image,
      'type': type,
      'electricity': electricity,
      'power_backup': powerBackup,
      'office_space': officeSpace,
      'dock_levelers': dockLevelers,
      'numberOfToilets': numberOfToilets,
      'truck_ParkingSlot': truckParkingSlot,
      'bike_ParkingSlot': bikeParkingSlot,
      'numberOfFans': numberOfFans,
      'numberOfLights': numberOfLights,
      'fireComplaints': fireComplaints,
      'numberOfDocks': numberOfDocks,
      'length': length,
      'width': width,
      'sideHeight': sideHeight,
      'centerHeight': centerHeight,
      'docksOfHeight': docksOfHeight,
      'flexiModel': flexingModel,
      'flooringType': flooringType,
      'furnishingType': furnishingType,
      'cluDocument': cluDocument,
    };
  }
}
