class Warehouse {
  final int id;
  final String wHouseAddress;
  final String wHouseName;
  final String totalArea;
  final String groundFloor;
  final int nOfFloors;
  final bool isAvailableForRent;
  final bool isAvailable;
  final String wHouseType;
  final String wHouseConstructionType;
  final int constructionAge;
  final double wHouseRentPerSQFT;
  final int securityDeposit;
  final String wHouseMaintenance;
  final String wHouseTokenAdvance;
  final String wHouseLockingPeriod;
  final String currentAddress;
  final String mobile;
  final double warehouseCarpetArea;
  final String? wHouseType1;
  final String? wHouseType2;
  final String? wHouseRent;
  final String? wHouseToken;
  final String filePath;
  final String image;
  final String dateTime;
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
  final String numberOfDocks;
  final String length;
  final String width;
  final String sideHeight;
  final String centerHeight;
  final String docksOfHeight;
  final bool flexingModel;
  final String flooringType;
  final String furnishingType;
  final bool cluDocument;
  final int wHouseId;
  final String status;

  Warehouse({
    required this.id,
    required this.wHouseAddress,
    required this.wHouseName,
    required this.totalArea,
    required this.groundFloor,
    required this.nOfFloors,
    required this.isAvailableForRent,
    required this.isAvailable,
    required this.wHouseType,
    required this.wHouseConstructionType,
    required this.constructionAge,
    required this.wHouseRentPerSQFT,
    required this.securityDeposit,
    required this.wHouseMaintenance,
    required this.wHouseTokenAdvance,
    required this.wHouseLockingPeriod,
    required this.currentAddress,
    required this.mobile,
    required this.warehouseCarpetArea,
    this.wHouseType1,
    this.wHouseType2,
    this.wHouseRent,
    this.wHouseToken,
    required this.filePath,
    required this.image,
    required this.dateTime,
    required this.electricity,
    required this.powerBackup,
    required this.officeSpace,
    required this.dockLevelers,
    required this.numberOfToilets,
    required this.truckParkingSlot,
    required this.bikeParkingSlot,
    required this.numberOfFans,
    required this.numberOfLights,
    required this.fireComplaints,
    required this.numberOfDocks,
    required this.length,
    required this.width,
    required this.sideHeight,
    required this.centerHeight,
    required this.docksOfHeight,
    required this.flexingModel,
    required this.flooringType,
    required this.furnishingType,
    required this.cluDocument,
    required this.wHouseId,
    required this.status,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? 0,
      wHouseAddress: json['whouse_address'] ?? '',
      wHouseName: json['whouse_name'] ?? '',
      totalArea: json['totalArea'] ?? '',
      groundFloor: json['graundFloor'] ?? '',
      nOfFloors: json['nOfFloors'] ?? 0,
      isAvailableForRent: (json['isavilableForRent'] ?? 0) == 1,
      isAvailable: (json['isavilable'] ?? 0) == 1,
      wHouseType: json['whouse_type'] ?? '',
      wHouseConstructionType: json['whouse_Cunstructiontype'] ?? '',
      constructionAge: json['cunstructiontAge'] ?? 0,
      wHouseRentPerSQFT: (json['whouse_rentPerSQFT'] ?? 0).toDouble(),
      securityDeposit: json['securityDeposit'] ?? 0,
      wHouseMaintenance: json['whouse_maintenance'] ?? '',
      wHouseTokenAdvance: json['whouse_tokenAdvance'] ?? '',
      wHouseLockingPeriod: json['whouseLockinPeriod'] ?? '',
      currentAddress: json['current_address'] ?? '',
      mobile: json['mobile'] ?? '',
      warehouseCarpetArea: (json['warehouse_carpetarea'] ?? 0).toDouble(),
      wHouseType1: json['whouse_type1'],
      wHouseType2: json['whouse_type2'],
      wHouseRent: json['whouse_rent'],
      wHouseToken: json['whouse_token'],
      filePath: json['filepath'] ?? '',
      image: json['image'] ?? '',
      dateTime: json['dateTime'] ?? '',
      electricity: json['electricity'] ?? '',
      powerBackup: json['power_backup'] ?? false,
      officeSpace: json['office_space'] ?? false,
      dockLevelers: json['dock_levelers'] ?? false,
      numberOfToilets: json['numberOfToilets'] ?? 0,
      truckParkingSlot: json['truck_ParkingSlot'] ?? 0,
      bikeParkingSlot: json['bike_ParkingSlot'] ?? 0,
      numberOfFans: json['numberOfFans'] ?? 0,
      numberOfLights: json['numberOfLights'] ?? 0,
      fireComplaints: json['fireComplaints'] ?? false,
      numberOfDocks: json['numberOfDocks'] ?? '',
      length: json['length'] ?? '',
      width: json['width'] ?? '',
      sideHeight: json['sideHeight'] ?? '',
      centerHeight: json['centerHeight'] ?? '',
      docksOfHeight: json['docksOfHeight'] ?? '',
      flexingModel: json['flexiModel'] ?? false,
      flooringType: json['flooringType'] ?? '',
      furnishingType: json['furnishingType'] ?? '',
      cluDocument: json['cluDocument'] ?? false,
      wHouseId: json['whouseId'] ?? 0,
      status: json['status'] ?? '',
    );
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
      'isavilable': isAvailable ? 1 : 0,
      'whouse_type': wHouseType,
      'whouse_Cunstructiontype': wHouseConstructionType,
      'cunstructiontAge': constructionAge,
      'whouse_rentPerSQFT': wHouseRentPerSQFT,
      'securityDeposit': securityDeposit,
      'whouse_maintenance': wHouseMaintenance,
      'whouse_tokenAdvance': wHouseTokenAdvance,
      'whouseLockinPeriod': wHouseLockingPeriod,
      'current_address': currentAddress,
      'mobile': mobile,
      'warehouse_carpetarea': warehouseCarpetArea,
      'whouse_type1': wHouseType1,
      'whouse_type2': wHouseType2,
      'whouse_rent': wHouseRent,
      'whouse_token': wHouseToken,
      'filepath': filePath,
      'image': image,
      'dateTime': dateTime,
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
      'whouseId': wHouseId,
      'status': status,
    };
  }
}

class WarehouseResponse {
  final int status;
  final String message;
  final List<Warehouse> data;

  WarehouseResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WarehouseResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['data'] as List<dynamic>? ?? [])
        .map((item) => Warehouse.fromJson(item as Map<String, dynamic>))
        .toList();

    return WarehouseResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((warehouse) => warehouse.toJson()).toList(),
    };
  }
}



















