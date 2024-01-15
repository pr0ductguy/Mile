import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/dash_board_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<DashBoardController>(
        init: DashBoardController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: controller.selectedDrawerIndex.value == 0
                  ? StreamBuilder(
                      stream: FireStoreUtils.fireStore
                          .collection(CollectionName.driverUsers)
                          .doc(FireStoreUtils.getCurrentUid())
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong'.tr);
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Constant.loader(context);
                        }
                        DriverUserModel driverModel =
                            DriverUserModel.fromJson(snapshot.data!.data()!);
                        return Container(
                          width: Responsive.width(50, context),
                          height: Responsive.height(5.5, context),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50.0),
                            ),
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                alignment: Alignment(
                                    driverModel.isOnline == true ? -1 : 1, 0),
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  width: Responsive.width(26, context),
                                  height: Responsive.height(8, context),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0A0A0A),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50.0),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  ShowToastDialog.showLoader("Please wait");
                                  if (driverModel.documentVerification ==
                                      false) {
                                    ShowToastDialog.closeLoader();
                                    _showAlertDialog(context, "document");
                                  } else if (driverModel.vehicleInformation ==
                                          null ||
                                      driverModel.serviceId == null) {
                                    ShowToastDialog.closeLoader();
                                    _showAlertDialog(
                                        context, "vehicleInformation");
                                  } else {
                                    driverModel.isOnline = true;
                                    await FireStoreUtils.updateDriverUser(
                                        driverModel);

                                    ShowToastDialog.closeLoader();
                                  }
                                },
                                child: Align(
                                  alignment: const Alignment(-1, 0),
                                  child: Container(
                                    width: Responsive.width(26, context),
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Online'.tr,
                                      style: GoogleFonts.poppins(
                                          color: driverModel.isOnline == true
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  driverModel.isOnline = false;
                                  await FireStoreUtils.updateDriverUser(
                                      driverModel);

                                  ShowToastDialog.closeLoader();
                                },
                                child: Align(
                                  alignment: const Alignment(1, 0),
                                  child: Container(
                                    width: Responsive.width(26, context),
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Offline'.tr,
                                      style: GoogleFonts.poppins(
                                          color: driverModel.isOnline == false
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                  : Text(
                      controller
                          .drawerItems[controller.selectedDrawerIndex.value]
                          .title,
                      style: const TextStyle(
                        color: Color(0xFF1D2939),
                        fontSize: 20,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.20,
                      ),
                    ),
              centerTitle: true,
              leading: Builder(builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 20, top: 20, bottom: 20),
                    child: SvgPicture.asset(
                      'assets/icons/ic_humber.svg',
                      width: 24,
                    ),
                  ),
                );
              }),
            ),
            drawer: buildAppDrawer(context, controller),
            body: WillPopScope(
                onWillPop: controller.onWillPop,
                child: controller
                    .getDrawerItemWidget(controller.selectedDrawerIndex.value)),
          );
        });
  }

  Future<void> _showAlertDialog(BuildContext context, String type) async {
    final controllerDashBoard = Get.put(DashBoardController());

    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: Text('Information'.tr),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'To start earning with Mile you need to fill in your vehicle information'
                        .tr),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'.tr),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text('Yes'.tr),
              onPressed: () {
                if (type == "document") {
                  controllerDashBoard.onSelectItem(5);
                } else {
                  controllerDashBoard.onSelectItem(4);
                }
              },
            ),
          ],
        );
      },
    );
  }

  buildAppDrawer(BuildContext context, DashBoardController controller) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < controller.drawerItems.length; i++) {
      var d = controller.drawerItems[i];
      drawerOptions.add(InkWell(
        onTap: () {
          controller.onSelectItem(i);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SvgPicture.asset(
                  d.icon,
                  width: 20,
                  color: i == controller.drawerItems.length - 1
                      ? const Color(0xFFFF4646)
                      : AppColors.primary,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  d.title,
                  style: GoogleFonts.poppins(
                      color: i == controller.drawerItems.length - 1
                          ? const Color(0xFFFF4646)
                          : AppColors.primary,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
      ));
    }
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: FutureBuilder<DriverUserModel?>(
                future: FireStoreUtils.getDriverProfile(
                    FireStoreUtils.getCurrentUid()),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Constant.loader(context);
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        DriverUserModel driverModel = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                height: Responsive.width(20, context),
                                width: Responsive.width(20, context),
                                imageUrl: driverModel.profilePic.toString(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Constant.loader(context),
                                errorWidget: (context, url, error) =>
                                    Image.network(Constant.userPlaceHolder),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                driverModel.fullName.toString(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontFamily: 'Instrument Sans',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.20,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                driverModel.email.toString(),
                                style: const TextStyle(
                                  color: Color(0xFFE7E7E7),
                                  fontSize: 10,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.20,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    default:
                      return Text('Error'.tr);
                  }
                }),
          ),
          Column(children: drawerOptions),
        ],
      ),
    );
  }
}
