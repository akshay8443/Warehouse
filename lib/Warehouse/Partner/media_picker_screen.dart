import 'package:Lisofy/resources/app_theme.dart';
import 'dart:io';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaPickerPage extends StatefulWidget {
  final bool isImagePicker;
  final List<XFile> initialMedia;
  const MediaPickerPage({
    super.key,
    required this.isImagePicker,
    required this.initialMedia,
  });

  @override
  MediaPickerPageState createState() => MediaPickerPageState();
}

class MediaPickerPageState extends State<MediaPickerPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _mediaFiles = [];

  @override
  void initState() {
    super.initState();
    _mediaFiles = widget.initialMedia;
  }

  Future<void> _pickMedia() async {
    List<XFile>? pickedFiles;
    if (widget.isImagePicker) {
      pickedFiles = await _picker.pickMultiImage();
    } else {
      final XFile? videoFile =
          await _picker.pickVideo(source: ImageSource.gallery);
      if (videoFile != null) {
        pickedFiles = [videoFile];
      }
    }

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      if (mounted) {
        if (widget.isImagePicker) {
          _showImageTypeSelector(context);
        }

        setState(() {
          _mediaFiles.addAll(pickedFiles!);
        });
      }
    }
  }

  void _deleteMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  Future<Widget> _generateVideoThumbnail(XFile video) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: video.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 75,
    );

    if (thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(thumbnail), fit: BoxFit.cover),
      );
    } else {
      return const Center(child: Text("Unable to generate thumbnail"));
    }
  }

  Widget _loadImage(int index) {
    final file = File(_mediaFiles[index].path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(file, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double itemWidth = width / 2 - 16;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isImagePicker
              ? S.of(context).pick_images
              : S.of(context).pick_videos,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primary,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: GridView.builder(
                key: ValueKey<int>(_mediaFiles.length),
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: itemWidth / itemWidth,
                ),
                itemCount: _mediaFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: widget.isImagePicker
                            ? _loadImage(index)
                            : FutureBuilder<Widget>(
                                future:
                                    _generateVideoThumbnail(_mediaFiles[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return snapshot.data!;
                                  } else {
                                    return const Center(
                                        child: SpinKitCircle(
                                            color: AppTheme.primary));
                                  }
                                },
                              ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _deleteMedia(index),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.close,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton.icon(
                    onPressed: _pickMedia,
                    icon: const Icon(Icons.add_a_photo_rounded,
                        color: Colors.white),
                    label: Text(
                      'Pick ${widget.isImagePicker ? 'Images' : 'Videos'}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _mediaFiles);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Text(
                      S.of(context).select_media,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showImageTypeSelector(BuildContext context) async {
    return await showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(S.of(context).select_image_types,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          message: Text(S.of(context).choose_image_type),
          actions: [
            for (String type in [
              'Interior',
              'Outer',
              'Side',
              'Parking',
              'Other'
            ])
              CupertinoActionSheetAction(
                child: Text(type, style: const TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context, type);
                },
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text(S.of(context).cancel,
                style: const TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
        );
      },
    );
  }
}
