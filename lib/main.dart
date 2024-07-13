import 'dart:js' as js;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:async'; // Import for Completer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScribeOCR(),
    );
  }
}

class ScribeOCR extends StatefulWidget {
  @override
  _ScribeOCRState createState() => _ScribeOCRState();
}

class _ScribeOCRState extends State<ScribeOCR> {
  String ocrResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(
          'Scribe OCR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF252526),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                uploadInput.accept = 'image/*';
                uploadInput.click();

                uploadInput.onChange.listen((e) {
                  final files = uploadInput.files;
                  if (files!.isEmpty) return;

                  final reader = html.FileReader();
                  reader.readAsDataUrl(files[0]);
                  reader.onLoadEnd.listen((e) async {
                    final imageDataUrl = reader.result as String;
                    try {
                      var promise = js.context.callMethod('performOCR', [imageDataUrl]);
                      var result = await promiseToFuture(promise);
                      setState(() {
                        ocrResult = result;
                      });
                    } catch (error) {
                      print('Promise Error: $error');
                    }
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF007ACC),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Upload and Process Image',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.8,
              constraints: BoxConstraints(
                minHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF252526),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF007ACC)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  ocrResult,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> promiseToFuture(js.JsObject promise) {
    final completer = Completer();
    promise.callMethod('then', [
      (result) {
        completer.complete(result);
      }
    ]);
    promise.callMethod('catch', [
      (error) {
        completer.completeError(error);
      }
    ]);
    return completer.future;
  }
}
