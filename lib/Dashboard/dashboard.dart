import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Campaigns/campaign.dart';
import 'package:papape_store/Campaigns/campaigns.dart';
import 'package:papape_store/Components/app_title.dart';
import 'package:papape_store/Components/custom_drawer.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/store_model.dart';
import 'package:papape_store/Products/category.dart';
import 'package:papape_store/Products/products.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Qr/qr_scan.dart';
import 'package:papape_store/Reports/report.dart';
import 'package:papape_store/Reservations/reservations.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:papape_store/Wishes/wishes.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final int defPage;

  const Dashboard({Key key, this.defPage}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  TabController _tabController;
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
    FaIcon(
      FontAwesomeIcons.chartBar,
      color: ColorConstants.instance.iconOnColor,
    ),
  ];

  @override
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
      _tabController = TabController(length: 5, vsync: this);
      _selectedIndex = widget.defPage;
    });
    _tabController.animateTo(_selectedIndex);
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
    _tabController.animateTo(index);
  }

  openDialog() {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Kampanya yayınlamadan önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CampaignSingle(campaignData: null)));
  }

  openCategoryDialog() {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Yeni başlık eklemeden önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => const CategorySingle(categoryData: null)))
        .whenComplete(() {});
  }

  openQrScanner() {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Müşteriden gelen QR kodu okutmadan önce, işletme bilgilerinizi kayıt etmelisiniz !',
          context);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const QrScanner()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        flexibleSpace: Container(
          color: ColorConstants.instance.whiteContainer,
        ),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70.0,
        title: const AppTitleWidget(),
        iconTheme: IconThemeData(color: ColorConstants.instance.primaryColor),
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        height: 75.0,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeIn,
        animationDuration: const Duration(milliseconds: 500),
        onTap: onTapped,
        index: _selectedIndex,
        color: ColorConstants.instance.primaryColor,
        buttonBackgroundColor: ColorConstants.instance.textGold,
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
          SpeedDialChild(
              child: Icon(
                Icons.qr_code,
                color: ColorConstants.instance.primaryColor,
              ),
              onTap: () {
                openQrScanner();
              },
              backgroundColor: ColorConstants.instance.iconOnColor,
              label: 'QR Kod Okut'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FutureBuilder(
          future: getUserInfo,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return (snapshot.connectionState == ConnectionState.done)
                ? (isLoading == false)
                    ? TabBarView(
                        controller: _tabController,
                        children: const [
                          Campaigns(),
                          Menu(),
                          WishView(),
                          Reservation(),
                          ReportView()
                        ],
                      )
                    : const ProgressWidget()
                : const ProgressWidget();
          }),
    );
  }
}
