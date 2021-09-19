import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomImageContainer extends StatefulWidget {
  final bool buttonVis;
  final bool addable;
  final File localImage;
  final String urlImage;
  final String addText;
  final Function onPressedEdit;
  final Function onPressedDelete;
  final Function onPressedAdd;

  const CustomImageContainer({
    Key key,
    this.buttonVis,
    this.addable,
    this.onPressedAdd,
    this.onPressedDelete,
    this.onPressedEdit,
    this.localImage,
    this.urlImage,
    this.addText,
  }) : super(key: key);

  @override
  _CustomImageContainerState createState() => _CustomImageContainerState();
}

class _CustomImageContainerState extends State<CustomImageContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.bottomCenter, children: [
      InkWell(
        onTap: widget.onPressedAdd,
        child: Container(
            clipBehavior: Clip.antiAlias,
            height: MediaQuery.of(context).size.height / 3.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.white,
                border: Border.all(width: 2.0, color: Colors.grey)),
            child: (this.widget.localImage != null)
                ? Image.file(this.widget.localImage, fit: BoxFit.fitWidth)
                : (this.widget.urlImage != null &&
                        this.widget.urlImage.isNotEmpty)
                    ? Image.network(
                        this.widget.urlImage,
                        fit: BoxFit.fitWidth,
                        loadingBuilder: (context, child, loadingProgress) {
                          return loadingProgress == null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                );
                        },
                      )
                    : (this.widget.addable)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Icon(
                                  Icons.upload_file,
                                  color: Theme.of(context).primaryColor,
                                  size: 50.0,
                                ),
                              ),
                              Text(
                                widget.addText,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: 'Bebas',
                                    fontSize: 20.0),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: FaIcon(
                                  FontAwesomeIcons.sadTear,
                                  color: Theme.of(context).primaryColor,
                                  size: 50.0,
                                ),
                              ),
                              Text(
                                'Resim Yok',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: 'Bebas',
                                    fontSize: 20.0),
                              ),
                            ],
                          )),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.buttonVis,
            child: TextButton(
                onPressed: widget.onPressedEdit,
                child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        gradient: LinearGradient(
                            colors: [
                              Theme.of(context).accentColor,
                              Theme.of(context).primaryColor
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                      ],
                    ))),
          ),
          Visibility(
            visible: widget.buttonVis,
            child: TextButton(
                onPressed: widget.onPressedDelete,
                child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        gradient: LinearGradient(
                            colors: [
                              Theme.of(context).accentColor,
                              Theme.of(context).primaryColor
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ))),
          ),
        ],
      )
    ]);
  }
}
