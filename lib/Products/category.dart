import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/product_category_model.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategorySingle extends StatefulWidget {
  final ProductCategory categoryData;

  const CategorySingle({Key key, this.categoryData}) : super(key: key);

  @override
  _CategorySingleState createState() => _CategorySingleState();
}

class _CategorySingleState extends State<CategorySingle> {
  final TextEditingController _categoryRow = TextEditingController();
  final TextEditingController _categoryName = TextEditingController();
  GlobalKey<FormState> formKeyCat = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInit = true;

  String _validateCatRow(String value) {
    if (value.isEmpty) {
      return '* Menü Kategori sırası boş olmamalıdır !';
    }
    if (value.contains(RegExp(r'[^\d]')) == true) {
      return '* Yalnızca rakam içerebilir !';
    }

    return null;
  }

  String _validateCatName(String value) {
    if (value.isEmpty) {
      return '* Menü Kategori adı boş olmamalıdır !';
    }

    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ\d]')) != true) {
      return '* Harf veya rakam içermelidir !';
    }

    return null;
  }

  saveCategory() {
    if (formKeyCat.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      ProductCategory category = ProductCategory(
        categoryId: const Uuid().v4(),
        categoryRow: int.parse(_categoryRow.text),
        categoryName: _categoryName.text,
      );

      FirestoreService()
          .saveCategory(category)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                _isLoading = false;
              }));
      setState(() {
        _categoryName.text = '';
        _categoryRow.text = '';
      });
    }
  }

  updateCategory() {
    setState(() {
      _isLoading = true;
    });
    ProductCategory updCategory = ProductCategory(
      categoryId: widget.categoryData.categoryId,
      categoryRow: int.parse(_categoryRow.text),
      categoryName: _categoryName.text,
    );

    FirestoreService()
        .updateCategory(updCategory)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              _isLoading = false;
            }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      if (widget.categoryData != null) {
        setState(() {
          _categoryName.text = widget.categoryData.categoryName;
          _categoryRow.text = widget.categoryData.categoryRow.toString();
          _isInit = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading == false)
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const TitleWidget(),
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                color: ColorConstants.instance.primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: ColorConstants.instance.whiteContainer,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0))),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Form(
                          key: formKeyCat,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Text(
                                    " * Menü kategori sırası örnek olarak 'Çorbalar' başlığının kaçıncı sırada olacağını belirler.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextFormField(
                                    controller: _categoryRow,
                                    maxLength: 3,
                                    validator: _validateCatRow,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: 'Menü Kategori Sırası',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Menü kategori adı örnek 'Çorbalar', 'Bileklikler', 'Elbiseler'",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextFormField(
                                    validator: _validateCatName,
                                    controller: _categoryName,
                                    maxLength: 50,
                                    decoration: const InputDecoration(
                                        labelText: 'Menü Kategori Adı',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 60.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        gradient: LinearGradient(
                                            colors: [
                                              ColorConstants
                                                  .instance.primaryColor,
                                              ColorConstants
                                                  .instance.secondaryColor,
                                            ],
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft)),
                                    child: TextButton(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Icon(
                                                (widget.categoryData == null)
                                                    ? Icons.save
                                                    : Icons.edit,
                                                color: ColorConstants
                                                    .instance.iconOnColor,
                                              ),
                                            ),
                                            Text(
                                                (widget.categoryData == null)
                                                    ? "Başlık Oluştur"
                                                    : "Başlığı Düzenle",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: ColorConstants
                                                        .instance.textOnColor,
                                                    fontFamily: 'Roboto')),
                                          ],
                                        ),
                                        onPressed: () {
                                          if (widget.categoryData != null) {
                                            updateCategory();
                                          } else {
                                            saveCategory();
                                          }
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ))
        : const ProgressWidget();
  }
}
