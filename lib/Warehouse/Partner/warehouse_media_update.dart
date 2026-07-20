import 'package:Lisofy/resources/app_theme.dart';
import 'dart:io';
import 'package:Lisofy/Warehouse/Partner/home_screen.dart';
import 'package:Lisofy/Warehouse/Partner/amenities_update.dart';
import 'package:Lisofy/Warehouse/Partner/models/warehouses_model.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class WarehouseMediaUpdate extends StatefulWidget {
  final Warehouse warehouse;
  const WarehouseMediaUpdate({required this.warehouse, super.key});
  @override
  State<WarehouseMediaUpdate> createState() => _WarehouseMediaUpdateState();
}

class _WarehouseMediaUpdateState extends State<WarehouseMediaUpdate> {
  int totalMedia = 0;
  int _photoCount = 0;
  int _videoCount = 0;
  double _progress = 0.0;
  final List<XFile> _pickedImages = [];
  final List<XFile> _pickedVideos = [];
  final List<String> _uploadedImages = [];
  final List<String> _uploadedVideos = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    String filePath = widget.warehouse.filePath;
    processMediaFilePath(filePath);
  }

  void processMediaFilePath(String filePath) {
    List<String> filePaths = filePath.split(',');
    List<String> photos = [];
    List<String> videos = [];
    for (var path in filePaths) {
      if (path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png')) {
        photos.add(path);
      } else if (path.endsWith('.mp4') ||
          path.endsWith('.avi') ||
          path.endsWith('.mov')) {
        videos.add(path);
      }
    }

    setState(() {
      _uploadedImages.addAll(photos);
      _uploadedVideos.addAll(videos);
      _photoCount = photos.length;
      _videoCount = videos.length;
      totalMedia = photos.length + videos.length;
      _progress = totalMedia * 5.0;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photoCount >= 10) return;

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          totalMedia++;
          _photoCount++;
          _pickedImages.add(pickedFile);
          _progress += 5;
        });
        if (kDebugMode) {
          print("Picked image: ${pickedFile.path}");
        } // Debug print
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking image: $e");
      }
    }
  }

  Future<void> _pickVideo() async {
    if (_videoCount >= 10) return;

    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          totalMedia++;
          _videoCount++;
          _pickedVideos.add(pickedFile);
          _progress += 5;
        });
        if (kDebugMode) {
          print("Picked video: ${pickedFile.path}");
        } // Debug print
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking video: $e");
      }
    }
  }

  Future<void> _uploadMedia(BuildContext context) async {
    if (_pickedImages.isEmpty &&
        _pickedVideos.isEmpty &&
        _uploadedImages.isEmpty &&
        _uploadedVideos.isEmpty) {
      if (kDebugMode) {
        print("No media to upload.");
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://xpacesphere.com/api/Wherehousedt/Upd_whousefile'),
      );

      List<File> mediaFiles = [];
      mediaFiles.addAll(_pickedImages.map((xFile) => File(xFile.path)));
      mediaFiles.addAll(_pickedVideos.map((xFile) => File(xFile.path)));

      if (mediaFiles.isNotEmpty) {
        for (var mediaFile in mediaFiles) {
          if (await mediaFile.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              'Filedata',
              mediaFile.path,
              filename: basename(mediaFile.path),
            ));
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AmenitiesUpdate(warehouse: widget.warehouse),
            ),
          );
        }
        if (kDebugMode) {
          print("No new media files to upload.");
        }
      }

      if (_uploadedImages.isNotEmpty) {
        for (var imagePath in _uploadedImages) {
          request.fields['uploadedImages[]'] = imagePath;
        }
      }

      if (_uploadedVideos.isNotEmpty) {
        for (var videoPath in _uploadedVideos) {
          request.fields['uploadedVideos[]'] = videoPath;
        }
      }

      request.fields['Id'] = widget.warehouse.id.toString();

      if (kDebugMode) {
        print("Request files count: ${request.files.length}");
      }
      if (kDebugMode) {
        print("Request fields: ${request.fields}");
      }

      var response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isUploading = false;
        });

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AmenitiesUpdate(warehouse: widget.warehouse),
            ),
          );
        }

        _clearAllFields();
      } else {
        setState(() {
          _isUploading = false;
        });

        final responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print(
              "Failed to upload files: ${response.statusCode}, $responseBody");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (kDebugMode) {
          print("Error uploading files: $e");
        }
      }
    }
  }

  Future<Uint8List?> _generateThumbnail(
      String videoPath, bool isLocalFile) async {
    if (isLocalFile) {
      return await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );
    } else {
      return await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );
    }
  }

  Widget _buildVideoThumbnail(String videoPath, bool isLocalFile) {
    return FutureBuilder<Uint8List?>(
      future: _generateThumbnail(videoPath, isLocalFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black26,
            ),
            child: const Icon(Icons.play_circle_filled,
                color: Colors.white, size: 50),
          );
        } else if (snapshot.hasData) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(snapshot.data!, fit: BoxFit.cover),
              ),
              const Icon(Icons.play_circle_filled,
                  color: Colors.white, size: 50),
            ],
          );
        } else {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.black26,
                ),
                child: const Icon(Icons.play_circle_filled,
                    color: Colors.white, size: 50),
              ),
            ],
          );
        }
      },
    );
  }

  void _removeMedia(String mediaType, int index) {
    setState(() {
      if (mediaType == 'Photos') {
        if (index < _uploadedImages.length) {
          _uploadedImages.removeAt(index);
          _photoCount--;
        } else {
          _pickedImages.removeAt(index - _uploadedImages.length);
          _photoCount--;
        }
      } else if (mediaType == 'Videos') {
        if (index < _uploadedVideos.length) {
          _uploadedVideos.removeAt(index);
          _videoCount--;
        } else {
          _pickedVideos.removeAt(index - _uploadedVideos.length);
          _videoCount--;
        }
      }
      totalMedia = _photoCount + _videoCount;
      _progress = totalMedia * 5.0;
    });
  }

  void _showMediaDialog(BuildContext context, String mediaType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Manage $mediaType'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (mediaType == 'Photos') ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                                itemCount: _uploadedImages.length +
                                    _pickedImages.length,
                                itemBuilder: (context, index) {
                                  if (index < _uploadedImages.length) {
                                    String imageUrl =
                                        "http://3.110.172.156:8083${_uploadedImages[index]}";
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Image.asset(
                                                    ImageAssets.defaultImage,
                                                    fit: BoxFit.cover),
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red),
                                            onPressed: () {
                                              _removeMedia('Photos', index);
                                              Navigator.of(context).pop();
                                              _showMediaDialog(
                                                  context, 'Photos');
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.file(
                                            File(_pickedImages[index -
                                                    _uploadedImages.length]
                                                .path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red),
                                            onPressed: () {
                                              _removeMedia('Photos', index);
                                              Navigator.of(context).pop();
                                              _showMediaDialog(
                                                  context, 'Photos');
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _pickImage(ImageSource.gallery);
                                },
                                child: Text(S.of(context).add_more_photos),
                              ),
                            ] else if (mediaType == 'Videos') ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                                itemCount: _uploadedVideos.length +
                                    _pickedVideos.length,
                                itemBuilder: (context, index) {
                                  if (index < _uploadedVideos.length) {
                                    String videoUrl =
                                        "https://xpacesphere.com${_uploadedVideos[index]}";
                                    return Stack(
                                      children: [
                                        _buildVideoThumbnail(videoUrl, false),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red),
                                            onPressed: () {
                                              _removeMedia('Videos', index);
                                              Navigator.of(context).pop();
                                              _showMediaDialog(
                                                  context, 'Videos');
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    String videoPath = _pickedVideos[
                                            index - _uploadedVideos.length]
                                        .path;
                                    return Stack(
                                      children: [
                                        _buildVideoThumbnail(videoPath, true),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red),
                                            onPressed: () {
                                              _removeMedia('Videos', index);
                                              Navigator.of(context).pop();
                                              _showMediaDialog(
                                                  context, 'Videos');
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _pickVideo();
                                },
                                child: Text(S.of(context).add_more_videos),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearAllFields() {
    setState(() {
      totalMedia = 0;
      _photoCount = 0;
      _videoCount = 0;
      _progress = 0.0;
      _pickedImages.clear();
      _pickedVideos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.primary,
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: AppTheme.primary,
                      height: screenHeight * 0.18,
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
                                InkWell(
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                Text(
                                  S.of(context).add_warehouse,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                const Spacer(),
                                const SizedBox(width: 5),
                              ],
                            ),
                            SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: screenHeight * 0.08, left: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.of(context).add_additional_details,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.005),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${S.of(context).warehouse_images} $totalMedia/20',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 15,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  child: LinearProgressIndicator(
                                    value: _progress / 100,
                                    backgroundColor: Colors.grey.shade300,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () =>
                                          _pickImage(ImageSource.gallery),
                                      child: Image.asset(
                                          "assets/images/addphotos.png"),
                                    ),
                                    GestureDetector(
                                      onTap: _pickVideo,
                                      child: Image.asset(
                                          "assets/images/addvideo.png"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () =>
                                          _showMediaDialog(context, 'Photos'),
                                      child: _buildCounter(
                                          'Photos',
                                          _photoCount,
                                          S.of(context).upload_media),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _showMediaDialog(context, 'Videos'),
                                      child: _buildCounter(
                                          'Videos', _videoCount, ""),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const SizedBox(height: 36),
                                _isUploading
                                    ? const SpinKitCircle(
                                        color: AppTheme.primary,
                                        size: 50.0,
                                      )
                                    : InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: AppTheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          height: screenHeight * 0.055,
                                          width: screenWidth * 0.47,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.03),
                                          child: Center(
                                              child: Text(
                                                  S.of(context).update_and_next,
                                                  style: const TextStyle(
                                                      color: Colors.white))),
                                        ),
                                        onTap: () {
                                          _uploadMedia(context);
                                        },
                                      ),
                                const SizedBox(
                                  height: 30,
                                ),
                                InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: BorderRadius.circular(6)),
                                    height: screenHeight * 0.04,
                                    width: screenWidth * 0.45,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                            child: Text(
                                                S.of(context).skip_for_now,
                                                style: const TextStyle(
                                                    color: Colors.white))),
                                        const Icon(
                                          Icons.skip_next_outlined,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int count, String name) {
    return Column(
      children: <Widget>[
        Text(name,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(color: AppTheme.primary),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, color: Colors.grey),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
