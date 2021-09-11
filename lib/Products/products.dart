import 'package:bulb/Components/bordered_button.dart';
import 'package:bulb/Components/category_card.dart';
import 'package:bulb/Components/not_found.dart';
import 'package:bulb/Models/product_category_model.dart';
import 'package:bulb/Models/product_model.dart';
import 'package:bulb/Products/category.dart';
import 'package:bulb/Products/product.dart';
import 'package:bulb/Providers/store_provider.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
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
  String _selectedCatId;
  ProductCategory _selectedCategory;
  Product _selectedProduct;

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
            builder: (context) =>
                CategorySingle(categoryData: _selectedCategory)))
        .whenComplete(() {
      setState(() {
        _selectedCategory = null;
      });
    });
  }

  openProductDialog() async {
    if (_selectedProduct != null && _selectedProduct.productCatId != null) {
      int index = category.indexWhere(
          (element) => element.categoryId == _selectedProduct.productCatId);
      setState(() {
        _selectedCatId = category[index].categoryId;
      });
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ProductSingle(
                productData: _selectedProduct,
                selectedCategoryId: _selectedCatId)))
        .whenComplete(() {
      setState(() {
        _selectedProduct = null;
        _selectedCatId = null;
      });
    });
  }

  deleteCatYesNo(BuildContext _context, ProductCategory category) {
    CoolAlert.show(
        context: _context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Başlığı silmek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
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
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  'Menü',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30.0,
                      fontFamily: 'Armatic',
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: BorderedButton(
                    buttonText: 'Menü Kategorisi Ekle',
                    widthMultiplier: 0.7,
                    onPressed: () {
                      openCategoryDialog();
                    },
                    borderColor: Colors.amber[900],
                    textColor: Colors.amber[900],
                  )),
              Flexible(
                child: StreamBuilder<List<ProductCategory>>(
                  stream: FirestoreService().getProductCategories(),
                  builder: (context, snapshot) {
                    category = snapshot.data;
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                        switch (snapshot.hasData && snapshot.data.length > 0) {
                          case true:
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: CategoryCard(
                                      category: snapshot.data[index],
                                      onPressedEdit: () {
                                        setState(() {
                                          _selectedCategory =
                                              snapshot.data[index];
                                        });
                                        openCategoryDialog();
                                      },
                                      onPressedDelete: () {
                                        deleteCatYesNo(
                                            context, snapshot.data[index]);
                                      },
                                    ));
                              },
                            );

                            break;
                          default:
                            return NotFound(
                              notFoundIcon: FontAwesomeIcons.sadTear,
                              notFoundIconColor: Theme.of(context).primaryColor,
                              notFoundIconSize: 75,
                              notFoundText:
                                  'Şu an yayınlamış olduğunuz hiçbir başlık bulunmamaktadır.',
                              notFoundTextColor: Theme.of(context).primaryColor,
                              notFoundTextSize: 30.0,
                            );
                        }
                        break;
                      default:
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                    }
                  },
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
  }
}
