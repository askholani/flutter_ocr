import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  DetailPage(this.documentSnapshot);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Future<void> performOCR(String userId) async {
    final String apiUrl = 'http://192.168.56.60:5000/products/ocr/$userId';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('OCR performed successfully.');
        // Do something with the response if needed
      } else {
        print('Failed to perform OCR. Status code: ${response.statusCode}');
        // Handle error
      }
    } catch (e) {
      print('Error during OCR request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 8 / 10,
              height: screenWidth * 5 / 10,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.documentSnapshot['imageUrl']),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Name: ${widget.documentSnapshot['name']}',
              style: const TextStyle(fontSize: 14),
            ),
            if (widget.documentSnapshot['ocr']) // Tambahkan kondisi if di sini
              Expanded(
                child: ListView.builder(
                  itemCount: widget.documentSnapshot['ocr_text'].length,
                  itemBuilder: (context, index) {
                    String text = widget.documentSnapshot['ocr_text'][index];
                    return ListTile(
                      title: Text(
                        text,
                        style: const TextStyle(
                            fontSize: 12.0), // Set the desired font size
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeumorphicButton(
                  onPressed: () {
                    performOCR(widget.documentSnapshot['id']);
                  },
                  child: const Text('OCR Button'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
