import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './form_page.dart';
import './detail_page.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();

  String imageUrl = '';
  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
    }

    Future<void> _getImageFromCamera() async {
      ImagePicker imagePicker = ImagePicker();
      XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
      // print('${file?.path}');

      if (file == null) return;
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');

      //Create a reference for the image to be stored
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);
      // Reference referenceImageToUpload = referenceDirImages.child('name');

      try {
        await referenceImageToUpload.putFile(File(file.path));
        imageUrl = await referenceImageToUpload.getDownloadURL();
      } catch (error) {
        // print('Error uploading image: $error');
      }
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          // return StatefulBuilder(builder: builder)
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: Text(action == 'create' ? 'Create' : 'Update'),
                      onPressed: () async {
                        final String? name = _nameController.text;
                        if (name != null) {
                          if (action == 'update') {
                            // Update the product
                            await _productss
                                .doc(documentSnapshot!.id)
                                .update({"name": name});
                          }

                          // Clear the text fields
                          _nameController.text = '';

                          // Hide the bottom sheet
                          Navigator.of(context).pop();
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _productss.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Tulisan'),
      ),

      body: StreamBuilder(
        stream: _productss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailPage(documentSnapshot)),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          8.0), // Add padding to the entire ListTile
                      child: ListTile(
                        leading: SizedBox(
                          width: 80,
                          height: 50,
                          child: Image.network(
                            documentSnapshot['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(documentSnapshot['name']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              NeumorphicButton(
                                onPressed: () {
                                  _createOrUpdate(documentSnapshot);
                                },
                                style: const NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.circle(),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              NeumorphicButton(
                                onPressed: () {
                                  _deleteProduct(documentSnapshot.id);
                                },
                                style: const NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.circle(),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: NeumorphicFloatingActionButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormPage()),
          )
        },
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.circle(),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.amber,
        ),
      ),
    );
  }
}
