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
    return WarehouseModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      distance: (json['distance'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      whouseAddress: json['whouse_address'] ?? '',
      wHouseRentPerSQFT: json['whouse_rentPerSQFT'] != null
          ? (json['whouse_rentPerSQFT'] as num).toDouble()
          : null,
      securityDeposit: json['securityDeposit'] != null
          ? int.tryParse(json['securityDeposit'].toString())
          : null,
      totalArea: json['totalArea'] ?? '',
      currentAddress: json['current_address'] ?? '',
      constructionAge: json['cunstructiontAge'] != null
          ? int.tryParse(json['cunstructiontAge'].toString())
          : null,
      groundFloor: json['graundFloor'] ?? '',
      wHouseType1: json['whouse_type1'],
      wHouseType: json['whouse_type'] ?? '',
      wHouseType2: json['whouse_type2'],
      wHouseConstructionType: json['whouse_Cunstructiontype'] ?? '',
      wHouseFloor: int.tryParse(json['whouse_floor'].toString()) ?? 0,
      wHouseCarpetArea: json['whouse_carperarea'] != null
          ? (json['whouse_carperarea'] as num).toDouble()
          : null,
      warehouseCarpetArea: json['warehouse_carpetarea'] != null
          ? (json['warehouse_carpetarea'] as num).toDouble()
          : null,
      isAvailable: json['isavilable'],
      isAvailableForRent: int.tryParse(json['isavilableForRent'].toString()) ?? 0,
      wHouseRent: json['whouse_rent'] != null
          ? (json['whouse_rent'] as num).toDouble()
          : null,
      wHouseMaintenance: json['whouse_maintenance'],
      wHouseTokenAdvance: json['whouse_tokenAdvance'],
      wHouseExpected: json['whouse_expected'],
      wHouseToken: json['whouse_token'],
      wHouseLockinPeriod: int.tryParse(json['whouseLockinPeriod'].toString()) ?? 0,
      wHouseName: json['whouse_name'] ?? '',
      status: json['status'] ?? '',
      filePath: json['filepath'] ?? '',
      mobile: json['mobile'] ?? '',
      image: json['image'],
      amenityId: int.tryParse(json['amenityId'].toString()) ?? 0,
      electricity: json['electricity'] ?? '',
      powerBackup: json['power_backup'] ?? false,
      officeSpace: json['office_space'] ?? false,
      dockLevelers: json['dock_levelers'] ?? false,
      numberOfToilets: int.tryParse(json['numberOfToilets'].toString()) ?? 0,
      truckParkingSlot: int.tryParse(json['truck_ParkingSlot'].toString()) ?? 0,
      bikeParkingSlot: int.tryParse(json['bike_ParkingSlot'].toString()) ?? 0,
      numberOfFans: int.tryParse(json['numberOfFans'].toString()) ?? 0,
      numberOfLights: int.tryParse(json['numberOfLights'].toString()) ?? 0,
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
      whouseId: int.tryParse(json['whouseId'].toString()) ?? 0,
    );
  }
}
