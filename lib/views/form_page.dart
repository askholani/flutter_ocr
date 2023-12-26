import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final uuid = Uuid();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _url = TextEditingController();

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  Future<void> _getImageFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

    if (file == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      _url.text = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      // print('Error uploading image: $error');
    }
  }

  Future<void> _uploadImage() async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    try {
      await referenceImageToUpload.putFile(File(file.path));
      _url.text = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      // print('Error uploading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folmulir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera),
                    onPressed: _getImageFromCamera,
                    iconSize: MediaQuery.of(context).size.width * 0.2,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 20), // Jarak antara ikon
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _uploadImage,
                    iconSize: MediaQuery.of(context).size.width * 0.2,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                labelStyle:
                    TextStyle(color: Colors.amber), // Change label color
                // You can also change the border color and focused border color if needed
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
              style: TextStyle(color: Colors.amber),
            ),
            TextField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: 'Url Gambar',
                labelStyle:
                    TextStyle(color: Colors.amber), // Change label color
                // You can also change the border color and focused border color if needed
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeumorphicButton(
                  style: const NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 8),
                      Text('Simpan'),
                    ],
                  ),
                  onPressed: () async {
                    final idItem = uuid.v4();

                    final String name = _nameController.text;
                    final String image = _url.text;
                    if (name != null && image != null) {
                      await _productss.add({
                        "id": idItem,
                        "name": name,
                        "imageUrl": image,
                        "ocr": false
                      });
                    }
                    // Clear the text fields
                    _nameController.text = '';
                    _url.text = '';
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
