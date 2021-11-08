import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  const Maps({Key key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  List<Marker> picker = [];
  StoreProvider _storeProvider;
  LatLng position;
  GoogleMapController _controller;

  pick(LatLng point) {
    setState(() {
      picker = [];
      picker.add(Marker(markerId: MarkerId(point.toString()), position: point));
      position = point;
    });
  }

  decidePick() {
    if (position != null) {
      savePick();
    } else {
      savePickYesNo();
    }
    _storeProvider.changeChanged(true);
  }

  savePick() {
    _storeProvider.changeStoreLocLat(position.latitude);
    _storeProvider.changeStoreLocLong(position.longitude);
    ToastService().showSuccess('Konumunuz başarıyla kaydedilmiştir !', context);
  }

  saveCurrent() {
    _storeProvider.changeStoreLocLat(_storeProvider.curLocLat);
    _storeProvider.changeStoreLocLong(_storeProvider.curLocLong);
    ToastService().showSuccess('Konumunuz başarıyla kaydedilmiştir !', context);
  }

  savePickYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text:
            'Hiçbir konum seçmezseniz mevcut konumunuz, seçilen konum olarak alınacaktır. Onaylıyor musunuz ?',
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
        showCancelBtn: true,
        cancelBtnText: 'Hayır',
        barrierDismissible: false,
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          saveCurrent();
        },
        confirmBtnText: 'Evet');
  }

  changeMapMode() {
    getJsonFile("assets/standart.json").then((value) => setMapStyle(value));
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeLocLat != null &&
        _storeProvider.storeLocLong != null) {
      picker.add(Marker(
          markerId: const MarkerId('1'),
          position:
              LatLng(_storeProvider.storeLocLat, _storeProvider.storeLocLong)));
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const TitleWidget(),
        toolbarHeight: 70.0,
        flexibleSpace: Container(
          color: ColorConstants.instance.primaryColor,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: ColorConstants.instance.primaryColor,
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                changeMapMode();
                _controller = controller;
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _storeProvider.curLocLat, _storeProvider.curLocLong),
                  zoom: 17.0),
              markers: Set.from(picker),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onTap: pick,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    gradient: LinearGradient(
                        colors: [
                          ColorConstants.instance.primaryColor,
                          ColorConstants.instance.secondaryColor,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter)),
                child: TextButton(
                  onPressed: decidePick,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: ColorConstants.instance.iconOnColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          'Konumu Kaydet',
                          style: TextStyle(
                              color: ColorConstants.instance.textOnColor,
                              fontSize: 18.0),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
