import 'package:papape_store/Components/category_card.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/product_category_model.dart';
import 'package:papape_store/Models/product_model.dart';
import 'package:papape_store/Products/category.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  const Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  StoreProvider _storeProvider;
  List<ProductCategory> category;
  List<Product> products;
  bool _isLoading = false;
  ProductCategory _selectedCategory;

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

  deleteCatYesNo(BuildContext _context, ProductCategory category) {
    CoolAlert.show(
        context: _context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Başlığı silmek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
            builder: (context, snapshot) {
              category = snapshot.data;
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                  switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                    case true:
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: CategoryCard(
                                category: snapshot.data[index],
                                onPressedEdit: () {
                                  setState(() {
                                    _selectedCategory = snapshot.data[index];
                                  });
                                  openCategoryDialog();
                                },
                                onPressedDelete: () {
                                  deleteCatYesNo(context, snapshot.data[index]);
                                },
                              ));
                        },
                      );

                      break;
                    default:
                      return NotFound(
                        notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                        notFoundIconColor: ColorConstants.instance.primaryColor,
                        notFoundText:
                            'Şu an yayınlamış olduğunuz hiçbir menü başlığı bulunmamaktadır.',
                        notFoundTextColor: ColorConstants.instance.hintColor,
                      );
                  }
                  break;
                default:
                  return const ProgressWidget();
              }
            },
          )
        : const ProgressWidget();
  }
}
