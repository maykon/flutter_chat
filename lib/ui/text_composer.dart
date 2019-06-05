import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function onSubmited;
  final Function onSendImage;

  TextComposer({Key key, this.onSubmited, this.onSendImage}) : super(key: key);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _textController = TextEditingController();

  bool _isComposer = false;

  void _reset() {
    _textController.clear();
    setState(() {
      _isComposer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200])),
              )
            : null,
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () async {
                  File img = await ImagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  widget.onSendImage(img);
                },
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: () async {
                  File img = await ImagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  widget.onSendImage(img);
                },
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: "Enviar uma mensagem...",
                ),
                onChanged: (text) {
                  setState(() {
                    _isComposer = text.isNotEmpty;
                  });
                },
                controller: _textController,
                onSubmitted: (text) {
                  widget.onSubmited(_textController.text);
                  _reset();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text("Enviar"),
                      onPressed: _isComposer
                          ? () {
                              widget.onSubmited(_textController.text);
                              _reset();
                            }
                          : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isComposer
                          ? () {
                              widget.onSubmited(_textController.text);
                              _reset();
                            }
                          : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
