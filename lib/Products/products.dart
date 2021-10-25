import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/product_card.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/product_category_model.dart';
import 'package:papape_store/Models/product_model.dart';
import 'package:papape_store/Products/category.dart';
import 'package:papape_store/Products/product.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  StoreProvider _storeProvider;
  List<ProductCategory> category;
  List<Product> products;
  bool _isLoading = false;
  String _selectedCategoryId;
  String _selectedCategoryName;

  openCategoryDialog(ProductCategory category) async {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Yeni başlık eklemeden önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => CategorySingle(categoryData: category)))
        .whenComplete(() {});
  }

  openProductDialog(Product selectedProduct) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductSingle(
            productData: selectedProduct,
            selectedCategoryId: _selectedCategoryId)));
  }

  deleteCatYesNo(BuildContext _context, ProductCategory category) {
    CoolAlert.show(
        context: _context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Başlığı silmek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          deleteCategory(category);
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  deleteCategory(ProductCategory category) {
    setState(() {
      _isLoading = true;
    });
    FirestoreService()
        .removeCategory(category.categoryId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              _isLoading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading == false)
        ? StreamBuilder<List<ProductCategory>>(
            stream: FirestoreService().getProductCategories(),
            builder: (context, snapshotCategory) {
              switch (snapshotCategory.connectionState) {
                case ConnectionState.active:
                  switch (snapshotCategory.hasData &&
                      snapshotCategory.data.length > 0) {
                    case true:
                      if (_selectedCategoryId == null) {
                        _selectedCategoryId =
                            snapshotCategory.data[0].categoryId;
                        _selectedCategoryName =
                            snapshotCategory.data[0].categoryName;
                      }
                      return Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                color: ColorConstants.instance.primaryColor,
                                height: 60.0,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshotCategory.data.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: ColorConstants
                                                  .instance.whiteContainer,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedCategoryId =
                                                            snapshotCategory
                                                                .data[index]
                                                                .categoryId;
                                                        _selectedCategoryName =
                                                            snapshotCategory
                                                                .data[index]
                                                                .categoryName;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Text(
                                                        snapshotCategory
                                                            .data[index]
                                                            .categoryName,
                                                        style: TextStyle(
                                                            color: ColorConstants
                                                                .instance
                                                                .primaryColor,
                                                            fontFamily: 'Bebas',
                                                            fontSize: 16.0),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        openCategoryDialog(
                                                            snapshotCategory
                                                                .data[index]);
                                                      },
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: ColorConstants
                                                            .instance
                                                            .secondaryColor,
                                                        size: 25.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        deleteCatYesNo(
                                                            context,
                                                            snapshotCategory
                                                                .data[index]);
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: ColorConstants
                                                            .instance
                                                            .inactiveColor,
                                                        size: 25.0,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                                  },
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: StreamBuilder<List<Product>>(
                                stream: FirestoreService()
                                    .getProducts(_selectedCategoryId),
                                builder: (context, snapshotProduct) {
                                  switch (snapshotProduct.connectionState) {
                                    case ConnectionState.active:
                                      switch (snapshotProduct.hasData &&
                                          snapshotProduct.data.length > 0) {
                                        case true:
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: GradientButton(
                                                  buttonText: "Yeni Ürün Ekle",
                                                  onPressed: () {
                                                    openProductDialog(null);
                                                  },
                                                  end: ColorConstants
                                                      .instance.secondaryColor,
                                                  start: ColorConstants
                                                      .instance.primaryColor,
                                                  fontFamily: 'Bebas',
                                                  fontSize: 17.0,
                                                  widthMultiplier: 0.7,
                                                  icon: Icons.add,
                                                ),
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  itemCount: snapshotProduct
                                                      .data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10.0,
                                                              left: 5.0,
                                                              right: 5.0,
                                                              bottom: 10.0),
                                                      child: ProductCard(
                                                        product: snapshotProduct
                                                            .data[index],
                                                        onTapped: () {
                                                          openProductDialog(
                                                              snapshotProduct
                                                                  .data[index]);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                          break;
                                        default:
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: ColorConstants
                                                          .instance.activeColor,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  50.0))),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        openProductDialog(null);
                                                      },
                                                      icon: FaIcon(
                                                        FontAwesomeIcons.plus,
                                                        size: 25.0,
                                                        color: ColorConstants
                                                            .instance
                                                            .iconOnColor,
                                                      )),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0,
                                                    right: 20.0,
                                                    top: 10.0,
                                                    bottom: 15.0),
                                                child: Text(
                                                  "'$_selectedCategoryName' kategorisinin altına yeni ürün eklemek için dokunun !",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'Armatic',
                                                    fontSize: 25.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorConstants
                                                        .instance.primaryColor,
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                      }
                                      break;
                                    default:
                                      return ProgressWidget();
                                  }
                                }),
                          ),
                        ],
                      );
                      break;
                    default:
                      return NotFound(
                        notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                        notFoundIconColor: ColorConstants.instance.primaryColor,
                        notFoundIconSize: 50,
                        notFoundText:
                            'Şu an yayınlamış olduğunuz hiçbir başlık bulunmamaktadır.',
                        notFoundTextColor: ColorConstants.instance.hintColor,
                        notFoundTextSize: 30.0,
                      );
                  }
                  break;
                default:
                  return ProgressWidget();
              }
            },
          )
        : ProgressWidget();
  }
}
