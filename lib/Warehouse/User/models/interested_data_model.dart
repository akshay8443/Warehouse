class InterestedModel {
  final int id;
  final String name;
  final String email;
  final String companyName;
  final String designation;
  final String possessionDate;
  final String message;
  final String? mDate;
  final String? mTime;
  final String cDate;
  final String contact;
  final String type;
  final String wHouseAddress;
  final String wHouseName;
  final String totalArea;
  final String groundFloor;
  final int numberOfFloors;
  final bool isAvailableForRent;
  final String wHouseType;
  final String wHouseConstructionType;
  final int constructionAge;
  final double wHouseRentPerSQFT;
  final String wHouseMaintenance;
  final double securityDeposit;
  final String wHouseTokenAdvance;
  final String wHouseLockInPeriod;
  final String currentAddress;
  final String filePath;
  final double warehouseCarpetArea;
  final String mobile;
  final String image;
  final int isAvailable;
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

  InterestedModel({
    required this.id,
    required this.name,
    required this.email,
    required this.companyName,
    required this.designation,
    required this.possessionDate,
    required this.message,
    this.mDate,
    this.mTime,
    required this.cDate,
    required this.contact,
    required this.type,
    required this.wHouseAddress,
    required this.wHouseName,
    required this.totalArea,
    required this.groundFloor,
    required this.numberOfFloors,
    required this.isAvailableForRent,
    required this.wHouseType,
    required this.wHouseConstructionType,
    required this.constructionAge,
    required this.wHouseRentPerSQFT,
    required this.wHouseMaintenance,
    required this.securityDeposit,
    required this.wHouseTokenAdvance,
    required this.wHouseLockInPeriod,
    required this.currentAddress,
    required this.filePath,
    required this.warehouseCarpetArea,
    required this.mobile,
    required this.image,
    required this.isAvailable,
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
  });

  factory InterestedModel.fromJson(Map<String, dynamic> json) {
    return InterestedModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      companyName: json['company_Name'] ?? '',
      designation: json['designation'] ?? '',
      possessionDate: json['possession_date'] ?? '',
      message: json['message'] ?? '',
      mDate: json['mDate'],
      mTime: json['mTime'],
      cDate: json['cDate'] ?? '',
      contact: json['contact'] ?? '',
      type: json['type'] ?? '',
      wHouseAddress: json['whouse_address'] ?? '',
      wHouseName: json['whouse_name'] ?? '',
      totalArea: json['totalArea'] ?? '',
      groundFloor: json['graundFloor'] ?? '',
      numberOfFloors: json['nOfFloors'] ?? 0,
      isAvailableForRent: json['isavilableForRent'] == 1,
      wHouseType: json['whouse_type'] ?? '',
      wHouseConstructionType: json['whouse_Cunstructiontype'] ?? '',
      constructionAge: json['cunstructiontAge'] ?? 0,
      wHouseRentPerSQFT: (json['whouse_rentPerSQFT'] as num?)?.toDouble() ?? 0.0,
      wHouseMaintenance: json['whouse_maintenance'] ?? '',
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      wHouseTokenAdvance: json['whouse_tokenAdvance'] ?? '',
      wHouseLockInPeriod: json['whouseLockinPeriod'] ?? '',
      currentAddress: json['current_address'] ?? '',
      filePath: (json['filepath'] ?? ''),
      warehouseCarpetArea: (json['warehouse_carpetarea'] as num?)?.toDouble() ?? 0.0,
      mobile: json['mobile'] ?? '',
      image: json['image'] ?? '',
      isAvailable: json['isavilable'] ?? 0,
      electricity: json['electricity'] ?? '',
      powerBackup: json['power_backup'] ?? false,
      officeSpace: json['office_space'] ?? false,
      dockLevelers: json['dock_levelers'] ?? false,
      numberOfToilets: json['numberOfToilets'] ?? 0,
      truckParkingSlot: (json['truck_ParkingSlot'] as num?)?.toInt() ?? 0,
      bikeParkingSlot: (json['bike_ParkingSlot'] as num?)?.toInt() ?? 0,
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
    );
  }
}
