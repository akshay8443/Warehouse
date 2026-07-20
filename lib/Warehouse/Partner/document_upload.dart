import 'package:Lisofy/resources/app_theme.dart';
import 'dart:io';
import 'package:Lisofy/Warehouse/User/UserProvider/document_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/rating_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentUpload extends StatefulWidget {
  const DocumentUpload({super.key});
  @override
  State<DocumentUpload> createState() => DocumentUploadState();
}

class DocumentUploadState extends State<DocumentUpload> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final String? phone;
  late final String? name;
  @override
  void initState() {
    super.initState();
    getSharedData();
  }

  void getSharedData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    phone = pref.getString("phone");
    name = pref.getString("name");
    if (kDebugMode) {
      print("Phone${phone!}");
    }
    _phoneController.text = phone ?? "";
    _nameController.text = name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final providerPhoto = Provider.of<PhotoProvider>(context);
    return Scaffold(
        body: Column(children: [
      Expanded(
          child: Container(
              color: AppTheme.primary,
              width: double.infinity,
              child: SafeArea(
                  child: Column(children: [
                Container(
                  color: AppTheme.primary,
                  height: screenHeight * 0.13,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.025,
                      left: screenWidth * 0.025,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      child: const Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.04,
                                    ),
                                    const Text(
                                      "Complete KYC",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.005),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(screenWidth * 0.1),
                          ),
                        ),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.03),
                            child: SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                child: Form(
                                    key: _formKey,
                                    child: Column(children: [
                                      SizedBox(
                                        height: screenHeight * 0.006,
                                      ),
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          enabled: false,
                                          labelStyle: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.1),
                                            borderSide: const BorderSide(
                                                color: Colors.grey, width: 1.5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                color: AppTheme.primary,
                                                width: 1.5),
                                          ),
                                        ),
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your name';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      TextFormField(
                                        maxLength: 10,
                                        enabled: false,
                                        controller: _phoneController,
                                        decoration: InputDecoration(
                                          labelText: 'Mobile No.',
                                          labelStyle: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey, width: 1.5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                color: AppTheme.primary,
                                                width: 1.5),
                                          ),
                                        ),
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your Mobile No.';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      Consumer2<PhotoProvider, RatingProvider>(
                                        builder: (context, photoProvider,
                                            ratingProvider, child) {
                                          bool isPanCardUploaded = photoProvider
                                                  .arepancardPhotosUploaded ||
                                              ratingProvider.panCardStatus == 1;
                                          return Container(
                                            height: screenHeight * 0.07,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: isPanCardUploaded
                                                    ? Colors.green
                                                    : Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (!isPanCardUploaded)
                                                  Container(
                                                    height: double.infinity,
                                                    width: screenWidth * 0.3,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (!isPanCardUploaded) {
                                                          showCameraDialog(
                                                              context);
                                                        }
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                              Icons.camera_alt,
                                                              color: AppTheme
                                                                  .primary),
                                                          SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.02),
                                                          const Text(
                                                            "Upload",
                                                            style: TextStyle(
                                                              color: AppTheme
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      isPanCardUploaded
                                                          ? "Pan Card Uploaded*"
                                                          : "Owner PAN CARD*",
                                                      style: TextStyle(
                                                        color: isPanCardUploaded
                                                            ? Colors.green
                                                            : Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.1),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      Consumer2<PhotoProvider, RatingProvider>(
                                        builder: (context, photoProvider,
                                            ratingProvider, child) {
                                          bool isSelfieUploaded = photoProvider
                                                  .areselfiePhotosUploaded ||
                                              ratingProvider.selfiStatus == 1;
                                          return Container(
                                            height: screenHeight * 0.07,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: isSelfieUploaded
                                                    ? Colors.green
                                                    : Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (!isSelfieUploaded)
                                                  Container(
                                                    height: double.infinity,
                                                    width: screenWidth * 0.3,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (!isSelfieUploaded) {
                                                          showSelfieCameraDialog(
                                                              context);
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                              Icons.camera_alt,
                                                              color: AppTheme
                                                                  .primary),
                                                          SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.02),
                                                          const Text(
                                                            "Upload",
                                                            style: TextStyle(
                                                              color: AppTheme
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      isSelfieUploaded
                                                          ? "Selfie Uploaded*"
                                                          : "Selfie Of Owner*",
                                                      style: TextStyle(
                                                        color: isSelfieUploaded
                                                            ? Colors.green
                                                            : Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.1),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      Consumer2<PhotoProvider, RatingProvider>(
                                        builder: (context, aadharPhotoProvider,
                                            ratingProvider, child) {
                                          bool areBothUploaded =
                                              aadharPhotoProvider
                                                      .areFrontAadharUploaded &&
                                                  aadharPhotoProvider
                                                      .areBackAadharUploaded;
                                          bool isAadharApproved =
                                              ratingProvider.aadharCardStatus ==
                                                  1;

                                          return Container(
                                            height: screenHeight * 0.2,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: (areBothUploaded ||
                                                        isAadharApproved)
                                                    ? Colors.green
                                                    : Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Front Photo
                                                _photoUploadSection(
                                                  context,
                                                  aadharPhotoProvider
                                                      .aadharPhotoFront,
                                                  "Upload Front Side",
                                                  () {
                                                    if (!areBothUploaded &&
                                                        !isAadharApproved) {
                                                      _pickAadharPhoto(context,
                                                          ImageSource.gallery,
                                                          isFront: true);
                                                    }
                                                  },
                                                  isClickable:
                                                      !areBothUploaded &&
                                                          !isAadharApproved,
                                                ),
                                                SizedBox(
                                                    height:
                                                        screenHeight * 0.013),
                                                _photoUploadSection(
                                                  context,
                                                  aadharPhotoProvider
                                                      .aadharPhotoBack,
                                                  "Upload Back Side",
                                                  () {
                                                    if (!areBothUploaded &&
                                                        !isAadharApproved) {
                                                      _pickAadharPhoto(context,
                                                          ImageSource.gallery,
                                                          isFront: false);
                                                    }
                                                  },
                                                  isClickable:
                                                      !areBothUploaded &&
                                                          !isAadharApproved,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.04,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final navigator =
                                              Navigator.of(context);
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          bool success = await providerPhoto
                                              .uploadPhotos(phone!);
                                          if (!context.mounted) return;
                                          if (success) {
                                            Fluttertoast.showToast(
                                              msg: "Uploaded!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.grey,
                                            );
                                            navigator.pop();
                                          } else {
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Upload failed. Please try again.")),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: AppTheme.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            side: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          elevation: 5, // Shadow effect
                                          shadowColor: Colors.black
                                              .withValues(alpha: 0.2),
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.01,
                                              horizontal: screenWidth * 0.1),
                                          minimumSize: Size(screenWidth * 0.85,
                                              screenWidth * 0.1),
                                        ),
                                        child: const Text(
                                          "Upload",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ]))))))
              ]))))
    ]));
  }

  Future<void> _pickSelfiePhotoGallery(
      BuildContext context, ImageSource source) async {
    final navigator = Navigator.of(context);
    final provider = Provider.of<PhotoProvider>(context, listen: false);
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (!context.mounted) return;
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool isConfirmed =
            await _showImagePreviewDialog(navigator.context, file);
        if (!context.mounted) return;
        if (isConfirmed) {
          provider.selfieOfOwnerPhotoUpdate(file);
        }
      });
    }
  }

  Future<void> _pickPhotoGallery(
      BuildContext context, ImageSource source) async {
    final navigator = Navigator.of(context);
    final provider = Provider.of<PhotoProvider>(context, listen: false);
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (!context.mounted) return;
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool isConfirmed =
            await _showImagePreviewDialog(navigator.context, file);
        if (!context.mounted) return;
        if (isConfirmed) {
          provider.updatePanPhoto(file);
        }
      });
    }
  }

  void showCameraDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.2)),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () {
                      _pickPhotoGallery(context, ImageSource.gallery);
                      Navigator.of(ctx).pop();
                    },
                    title: const Text(
                      "Choose from Gallery",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                    trailing: const Icon(
                      Icons.photo_camera_back,
                      color: Colors.grey,
                      size: 35,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: screenWidth,
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      _pickPhotoGallery(context, ImageSource.camera);
                      Navigator.of(ctx).pop();
                    },
                    title: const Text(
                      "Capture from Camera",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                    trailing: const Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 35,
                    ),
                  )
                ],
              ),
            ));
  }

  void showSelfieCameraDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.5)),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () {
                      _pickSelfiePhotoGallery(context, ImageSource.gallery);
                      Navigator.of(ctx).pop();
                    },
                    title: const Text(
                      "Choose from Gallery",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                    trailing: const Icon(
                      Icons.photo_camera_back,
                      color: Colors.grey,
                      size: 35,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: screenWidth,
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      _pickSelfiePhotoGallery(context, ImageSource.camera);
                      Navigator.of(ctx).pop();
                    },
                    title: const Text(
                      "Capture from Camera",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                    trailing: const Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 35,
                    ),
                  )
                ],
              ),
            ));
  }

  Future<bool> _showImagePreviewDialog(
      BuildContext context, File imageFile) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            backgroundColor: Colors.white,
            title: const Text(
              'Image Preview',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    child: Image.file(
                      imageFile,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                const Text(
                  'Are you sure you want to use this photo?',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _photoUploadSection(
      BuildContext context, File? photo, String label, VoidCallback onTap,
      {bool isClickable = true}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        height: screenHeight * 0.078,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          color: Colors.white,
          border: Border.all(
              color: photo != null ? Colors.green : Colors.grey, width: 1),
        ),
        child: photo != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: Image.file(photo, fit: BoxFit.cover),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt,
                      color: isClickable ? AppTheme.primary : Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isClickable ? AppTheme.primary : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickAadharPhoto(BuildContext context, ImageSource source,
      {required bool isFront}) async {
    final navigator = Navigator.of(context);
    final provider = Provider.of<PhotoProvider>(context, listen: false);
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (!context.mounted) return;
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool isConfirmed =
            await _showImagePreviewDialog(navigator.context, file);
        if (!context.mounted) return;
        if (isConfirmed) {
          if (isFront) {
            provider.aadharCardPhotoFront(file);
          } else {
            provider.aadharCardPhotoback(file);
          }
        }
      });
    }
  }

  void showAadharCameraDialog(BuildContext context, {required bool isFront}) {
    final screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: screenHeight * 0.2,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                _pickAadharPhoto(context, ImageSource.gallery,
                    isFront: isFront);
                Navigator.of(ctx).pop();
              },
              title: const Text("Choose from Gallery"),
              trailing: const Icon(Icons.photo_library, size: 30),
            ),
            ListTile(
              onTap: () {
                _pickAadharPhoto(context, ImageSource.camera, isFront: isFront);
                Navigator.of(ctx).pop();
              },
              title: const Text("Capture from Camera"),
              trailing: const Icon(Icons.camera_alt, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
