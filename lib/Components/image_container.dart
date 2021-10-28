import 'dart:io';

import 'package:flutter/material.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class CustomImageContainer extends StatefulWidget {
  final File localImage;
  final String urlImage;
  final Function onPressedAdd;
  final Function onPressedDelete;

  const CustomImageContainer({
    Key key,
    this.onPressedDelete,
    this.onPressedAdd,
    this.localImage,
    this.urlImage,
  }) : super(key: key);

  @override
  _CustomImageContainerState createState() => _CustomImageContainerState();
}

class _CustomImageContainerState extends State<CustomImageContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.bottomCenter, children: [
      Container(
          clipBehavior: Clip.antiAlias,
          height: MediaQuery.of(context).size.height / 3.5,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              ColorConstants.instance.secondaryColor,
              ColorConstants.instance.primaryColor,
            ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            color: ColorConstants.instance.primaryColor,
          ),
          child: (widget.localImage != null)
              ? Image.file(widget.localImage, fit: BoxFit.cover)
              : (widget.urlImage != null && widget.urlImage.isNotEmpty)
                  ? Image.network(
                      widget.urlImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.instance.iconOnColor,
                                ),
                              );
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            widget.onPressedAdd('gallery');
                          },
                          child: Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstants.instance.primaryColor,
                                  border: Border.all(
                                      width: 2.0,
                                      color: ColorConstants.instance.textGold)),
                              child: Icon(
                                Icons.photo_size_select_actual_rounded,
                                color: ColorConstants.instance.iconOnColor,
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onPressedAdd('photo');
                          },
                          child: Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstants.instance.primaryColor,
                                  border: Border.all(
                                      width: 2.0,
                                      color: ColorConstants.instance.textGold)),
                              child: Icon(
                                Icons.camera_alt,
                                color: ColorConstants.instance.iconOnColor,
                              )),
                        )
                      ],
                    )),
      Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: (widget.localImage != null || widget.urlImage != null),
              child: GestureDetector(
                onTap: widget.onPressedDelete,
                child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [
                              ColorConstants.instance.signBackButtonSecondary,
                              ColorConstants.instance.signBackButtonPrimary,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter)),
                    child: Icon(
                      Icons.delete,
                      color: ColorConstants.instance.iconOnColor,
                    )),
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
