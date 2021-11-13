import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/employee_model.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Employees extends StatefulWidget {
  const Employees({Key key}) : super(key: key);

  @override
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  UserProvider _userProvider;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  makePhoneCall(employeePhone) async {
    await launch("tel:+90$employeePhone");
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              toolbarHeight: 70.0,
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
              title: const TitleWidget(),
            ),
            body: StreamBuilder<List<EmployeeModel>>(
                stream:
                    FirestoreService().getStoreEmployees(_userProvider.storeId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                        case true:
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  height: 100,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: BorderSide(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Text(
                                                'Personel İsim-Soyisim: ${snapshot.data[index].name}',
                                                style: const TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Text(
                                                'Personel Telefon: +90${snapshot.data[index].phone}',
                                                style: const TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              makePhoneCall(
                                                  snapshot.data[index].phone);
                                            },
                                            icon: Icon(
                                              Icons.call,
                                              color: ColorConstants
                                                  .instance.primaryColor,
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              });
                          break;
                        default:
                          return NotFound(
                            notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                            notFoundIconColor:
                                ColorConstants.instance.primaryColor,
                            notFoundText:
                                'Şu anda hiç personeliniz bulunmamaktadır.',
                            notFoundTextColor:
                                ColorConstants.instance.hintColor,
                          );
                      }
                      break;
                    default:
                      return const ProgressWidget();
                  }
                }),
          )
        : const ProgressWidget();
  }
}
