import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/menu_drawer.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _promptController = TextEditingController();
  List<String> textQuerysResponse = [];
  List<String> imageQueryResponse = [];

  bool _isTextQuery = false;
  bool _isImageProcessingQuery = false;

  //API Key for integrating OpenAI API
  String apiKey = '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';

  //Urls for Services provided by OpenAI
  String imageCreationUrl = 'https://api.openai.com/v1/images/generations';
  String textCompletionUrl = 'https://api.openai.com/v1/completions';

  //Function to get Text Query Response
  Future<void> _getTextQueryResponse() async {
    String text = _promptController.text;
    _promptController.text = "";
    FocusScope.of(context).unfocus();
    if (_isTextQuery) {
      final response = await http.post(
        Uri.parse(textCompletionUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": text,
          "n": 1,
          "max_tokens": 7,
          "temperature": 0,
        }),
      );
      var decodedResponse = jsonDecode(response.body);
      print(decodedResponse);
      setState(() {
        textQuerysResponse.add(decodedResponse['choices'][0]['text']);
      });
    }
  }

  //Function to get Image Creation Query Response
  Future<void> _getImageCreationQueryResponse() async {
    String prompt = _promptController.text;
    _promptController.text = "";
    FocusScope.of(context).unfocus();
    if (prompt.isNotEmpty) {
      final response = await http.post(
        Uri.parse(imageCreationUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"prompt": prompt, "n": 1, "size": "256x256"}),
      );
      var decodedBody = jsonDecode(response.body);
      var imageUrlResponse = decodedBody['data'][0]['url'];
      setState(() {
        imageQueryResponse.add(imageUrlResponse);
      });
    }
  }

  Widget buildContainer(Widget childWidget) {
    return Container(
      width: MediaQuery.of(context).size.width - 10,
      height: MediaQuery.of(context).size.height * 0.69,
      child: childWidget,
    );
  }

  Widget buildListView(bool _isText, bool _isImage, bool _isCode,) {
    if(_isText) {
      return ListView.builder(
        reverse: true,
        itemBuilder: (context, index) =>
            Text('${textQuerysResponse[index]}'),
        itemCount: textQuerysResponse.length,
      );
      } else if(_isImage) {
        return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                  margin: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: Image.network(
                    imageQueryResponse[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
          },
          itemCount: imageQueryResponse.length,
        );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        title: const Text('ChatGPT'),
      ),
      drawer: MenuDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_isTextQuery)
              buildContainer(buildListView(true, false, false)),
            if (_isImageProcessingQuery)
              buildContainer(buildListView(false, true, false)),
            Divider(
              thickness: 2,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select Type of Your Query!!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _isTextQuery = true;
                        _isImageProcessingQuery = false;
                      }),
                      icon: Icon(Icons.text_fields),
                      label: Text('Text Query!'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _isTextQuery = false;
                        _isImageProcessingQuery = true;
                      }),
                      icon: Icon(Icons.image),
                      label: Text('Image Creation Query!'),
                    ),
                  ],
                ),
              ],
            ),
            Divider(thickness: 2,),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        labelText: 'Enter your Query',
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_isTextQuery) {
                      _getTextQueryResponse();
                    } else if (_isImageProcessingQuery) {
                      _getImageCreationQueryResponse();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
