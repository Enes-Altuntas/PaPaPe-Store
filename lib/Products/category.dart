import 'package:bulb/Components/title.dart';
import 'package:bulb/Models/product_category_model.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategorySingle extends StatefulWidget {
  final ProductCategory categoryData;

  CategorySingle({Key key, this.categoryData}) : super(key: key);

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
      return '* Kategori sırası boş olmamalıdır !';
    }
    if (value.contains(RegExp(r'[^\d]')) == true) {
      return '* Yalnızca rakam içerebilir !';
    }

    return null;
  }

  String _validateCatName(String value) {
    if (value.isEmpty) {
      return '* Kategori adı boş olmamalıdır !';
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
        categoryId: Uuid().v4(),
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor
          ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
        ),
        elevation: 0,
        centerTitle: true,
        title: TitleWidget(),
      ),
      body: (_isLoading == false)
          ? Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0))),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Form(
                          key: formKeyCat,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Text(
                                    " * Başlık sırası örnek olarak 'Çorbalar' başlığının kaçıncı sırada olacağını belirler.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: 'Roboto',
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
                                    decoration: InputDecoration(
                                        labelText: 'Başlık Sırası',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Başlık adı örnek 'Çorbalar', 'Bileklikler', 'Elbiseler'",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: 'Roboto',
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextFormField(
                                    validator: _validateCatName,
                                    controller: _categoryName,
                                    maxLength: 50,
                                    decoration: InputDecoration(
                                        labelText: 'Başlık Adı',
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
                                              Theme.of(context).accentColor,
                                              Theme.of(context).primaryColor
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
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                                (widget.categoryData == null)
                                                    ? "Başlık Oluştur"
                                                        .toUpperCase()
                                                    : "Başlığı Düzenle"
                                                        .toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                    fontFamily: 'Bebas')),
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
            )
          : Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
