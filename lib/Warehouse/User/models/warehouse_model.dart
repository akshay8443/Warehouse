class WarehouseModel {
  final int id;
  final double distance;
  final double latitude;
  final double longitude;
  final String whouseAddress;
  final double? wHouseRentPerSQFT;
  final int? securityDeposit;
  final String? totalArea;
  final String? currentAddress;
  final int? constructionAge;
  final String groundFloor;
  final String? wHouseType1;
  final String wHouseType;
  final String? wHouseType2;
  final String wHouseConstructionType;
  final int wHouseFloor;
  final double? wHouseCarpetArea;
  final double? warehouseCarpetArea;
  final int? isAvailable;
  final int isAvailableForRent;
  final double? wHouseRent;
  final String? wHouseMaintenance;
  final String? wHouseTokenAdvance;
  final String? wHouseExpected;
  final String? wHouseToken;
  final int? wHouseLockinPeriod;
  final String wHouseName;
  final String status;
  final String filePath;
  final String mobile;
  final String? image;
  final int amenityId;
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
  final int whouseId;

  WarehouseModel({
    required this.id,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.whouseAddress,
    this.wHouseRentPerSQFT,
    this.securityDeposit,
    this.totalArea,
    this.currentAddress,
    this.constructionAge,
    required this.groundFloor,
    this.wHouseType1,
    required this.wHouseType,
    this.wHouseType2,
    required this.wHouseConstructionType,
    required this.wHouseFloor,
    this.wHouseCarpetArea,
    this.warehouseCarpetArea,
    this.isAvailable,
    required this.isAvailableForRent,
    this.wHouseRent,
    this.wHouseMaintenance,
    this.wHouseTokenAdvance,
    this.wHouseExpected,
    this.wHouseToken,
    this.wHouseLockinPeriod,
    required this.wHouseName,
    required this.status,
    required this.filePath,
    required this.mobile,
    this.image,
    required this.amenityId,
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
    required this.whouseId,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value == 1;
      final text = value?.toString().toLowerCase();
      return text == 'true' || text == '1';
    }

    return WarehouseModel(
      id: parseInt(json['id']),
      distance: parseDouble(json['distance']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      whouseAddress: json['whouse_address'] ?? '',
      wHouseRentPerSQFT: parseNullableDouble(json['whouse_rentPerSQFT']),
      securityDeposit: parseNullableInt(json['securityDeposit']),
      totalArea: json['totalArea'] ?? '',
      currentAddress: json['current_address'] ?? '',
      constructionAge: parseNullableInt(json['cunstructiontAge']),
      groundFloor: json['graundFloor'] ?? '',
      wHouseType1: json['whouse_type1'],
      wHouseType: json['whouse_type'] ?? '',
      wHouseType2: json['whouse_type2'],
      wHouseConstructionType: json['whouse_Cunstructiontype'] ?? '',
      wHouseFloor: parseInt(json['whouse_floor']),
      wHouseCarpetArea: parseNullableDouble(json['whouse_carperarea']),
      warehouseCarpetArea: parseNullableDouble(json['warehouse_carpetarea']),
      isAvailable: parseNullableInt(json['isavilable']),
      isAvailableForRent: parseInt(json['isavilableForRent']),
      wHouseRent: parseNullableDouble(json['whouse_rent']),
      wHouseMaintenance: json['whouse_maintenance'],
      wHouseTokenAdvance: json['whouse_tokenAdvance'],
      wHouseExpected: json['whouse_expected'],
      wHouseToken: json['whouse_token'],
      wHouseLockinPeriod: parseInt(json['whouseLockinPeriod']),
      wHouseName: json['whouse_name'] ?? '',
      status: json['status'] ?? '',
      filePath: json['filepath'] ?? '',
      mobile: json['mobile'] ?? '',
      image: json['image'],
      amenityId: parseInt(json['amenityId']),
      electricity: json['electricity'] ?? '',
      powerBackup: parseBool(json['power_backup']),
      officeSpace: parseBool(json['office_space']),
      dockLevelers: parseBool(json['dock_levelers']),
      numberOfToilets: parseInt(json['numberOfToilets']),
      truckParkingSlot: parseInt(json['truck_ParkingSlot']),
      bikeParkingSlot: parseInt(json['bike_ParkingSlot']),
      numberOfFans: parseInt(json['numberOfFans']),
      numberOfLights: parseInt(json['numberOfLights']),
      fireComplaints: parseBool(json['fireComplaints']),
      numberOfDocks: json['numberOfDocks'] ?? '',
      length: json['length'] ?? '',
      width: json['width'] ?? '',
      sideHeight: json['sideHeight'] ?? '',
      centerHeight: json['centerHeight'] ?? '',
      docksOfHeight: json['docksOfHeight'] ?? '',
      flexingModel: parseBool(json['flexiModel']),
      flooringType: json['flooringType'] ?? '',
      furnishingType: json['furnishingType'] ?? '',
      cluDocument: parseBool(json['cluDocument']),
      whouseId: parseInt(json['whouseId']),
    );
  }
}
