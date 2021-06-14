import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
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
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
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
          markerId: MarkerId('1'),
          position:
              LatLng(_storeProvider.storeLocLat, _storeProvider.storeLocLong)));
    }
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.red[600], Colors.purple[500]],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft)),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text('bulb',
            style: TextStyle(
                fontSize: 40.0, color: Colors.white, fontFamily: 'Dancing')),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.red[600], Colors.purple[500]],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        changeMapMode();
                        _controller = controller;
                      },
                      initialCameraPosition: CameraPosition(
                          target: LatLng(_storeProvider.curLocLat,
                              _storeProvider.curLocLong),
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
                                colors: [Colors.red[600], Colors.purple[500]],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft)),
                        child: TextButton(
                          onPressed: decidePick,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Konumu Kaydet',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Bebas',
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
