import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Campaigns/campaign.dart';
import 'package:papape_store/Campaigns/campaigns.dart';
import 'package:papape_store/Components/custom_drawer.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/store_model.dart';
import 'package:papape_store/Products/category.dart';
import 'package:papape_store/Products/products.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Reservations/reservations.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:papape_store/Wishes/wishes.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final int defPage;

  Dashboard({Key key, this.defPage}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  PageController pageController = PageController();
  StoreProvider _storeProvider;
  int _selectedIndex = 0;
  Future getUserInfo;
  bool isInit = true;
  bool isLoading = false;
  List<FaIcon> items = [
    FaIcon(
      FontAwesomeIcons.tags,
      color: ColorConstants.instance.iconOnColor,
    ),
    FaIcon(
      FontAwesomeIcons.bookOpen,
      color: ColorConstants.instance.iconOnColor,
    ),
    FaIcon(
      FontAwesomeIcons.bullhorn,
      color: ColorConstants.instance.iconOnColor,
    ),
    FaIcon(
      FontAwesomeIcons.bell,
      color: ColorConstants.instance.iconOnColor,
    ),
  ];

  Future<void> didChangeDependencies() async {
    if (isInit) {
      _storeProvider = Provider.of<StoreProvider>(context);
      getUserInfo = _getStoreInfo();
      setState(() {
        isInit = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.defPage;
    });
  }

  Future<Store> _getStoreInfo() async {
    Store _store;
    setState(() {
      isLoading = true;
    });

    await FirestoreService()
        .getStore()
        .then((value) => {
              if (value != null && value.data() != null)
                {_store = Store.fromFirestore(value.data())}
            })
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));

    if (_store != null) {
      _storeProvider.loadStoreInfo(_store);
    }
    return _store;
  }

  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  openDialog() async {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Kampanya yayınlamadan önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CampaignSingle(campaignData: null)));
  }

  openCategoryDialog() async {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Yeni başlık eklemeden önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => CategorySingle(categoryData: null)))
        .whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        flexibleSpace: Container(
          color: ColorConstants.instance.primaryColor,
        ),
        elevation: 5,
        centerTitle: true,
        toolbarHeight: 70.0,
        title: TitleWidget(),
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        height: 60.0,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeIn,
        animationDuration: Duration(milliseconds: 500),
        onTap: onTapped,
        index: _selectedIndex,
        color: ColorConstants.instance.primaryColor,
        buttonBackgroundColor: ColorConstants.instance.primaryColor,
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(
          color: ColorConstants.instance.iconOnColor,
        ),
        backgroundColor: ColorConstants.instance.primaryColor,
        overlayColor: ColorConstants.instance.hintColor,
        overlayOpacity: 0.8,
        children: [
          SpeedDialChild(
              child: Icon(
                Icons.add,
                color: ColorConstants.instance.primaryColor,
              ),
              onTap: () {
                openCategoryDialog();
              },
              backgroundColor: ColorConstants.instance.whiteContainer,
              label: 'Menü Başlığı Ekle'),
          SpeedDialChild(
              child: Icon(
                Icons.add,
                color: ColorConstants.instance.iconOnColor,
              ),
              onTap: () {
                openDialog();
              },
              backgroundColor: ColorConstants.instance.primaryColor,
              label: 'Kampanya Yayınla'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FutureBuilder(
          future: getUserInfo,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return (snapshot.connectionState == ConnectionState.done)
                ? (isLoading == false)
                    ? PageView(
                        controller: pageController,
                        children: [
                          Campaigns(),
                          Menu(),
                          Reports(),
                          Reservation()
                        ],
                      )
                    : ProgressWidget()
                : ProgressWidget();
          }),
    );
  }
}
