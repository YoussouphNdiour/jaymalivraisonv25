import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/order_controller.dart';
import 'package:sixam_mart_delivery/controller/splash_controller.dart';
import 'package:sixam_mart_delivery/data/model/response/order_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter.dart';
import 'package:sixam_mart_delivery/helper/price_converter.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/view/base/confirmation_dialog.dart';
import 'package:sixam_mart_delivery/view/base/custom_button.dart';
import 'package:sixam_mart_delivery/view/base/custom_image.dart';
import 'package:sixam_mart_delivery/view/base/custom_snackbar.dart';
import 'package:sixam_mart_delivery/view/screens/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/view/screens/request/order_location_screen.dart';

class OrderRequestWidget extends StatelessWidget {
  final OrderModel orderModel;
  final int index;
  final bool fromDetailsPage;
  final Function onTap;
  const OrderRequestWidget({Key? key, required this.orderModel, required this.index, required this.onTap, this.fromDetailsPage = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';
    double distance = Get.find<AuthController>().getRestaurantDistance(
      LatLng(double.parse(parcel ? orderModel.deliveryAddress?.latitude ?? '0' : orderModel.storeLat ?? '0'), double.parse(parcel ? orderModel.deliveryAddress?.longitude ?? '0' : orderModel.storeLng ?? '0')),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Column(children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  height: 45, width: 45, alignment: Alignment.center,
                  decoration: parcel ? BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ) : null,
                  child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), child: CustomImage(
                    image: parcel ? '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${orderModel.parcelCategory != null
                        ? orderModel.parcelCategory!.image : ''}' : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${orderModel.storeLogo ?? ''}',
                    height: parcel ? 30 : 45, width: parcel ? 30 : 45, fit: BoxFit.cover,
                  )),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    parcel ? orderModel.parcelCategory != null ? orderModel.parcelCategory!.name ?? ''
                      : '' : orderModel.storeName ?? 'no_store_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    parcel ? 'parcel'.tr : '${orderModel.detailsCount} ${orderModel.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    parcel ? orderModel.parcelCategory != null ? orderModel.parcelCategory!.description ?? '' : '' : orderModel.storeAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ])),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                  Text(
                    '${DateConverter.timeDistanceInMin(orderModel.createdAt!)} ${'mins_ago'.tr}',
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  orderModel.deliveryAddress != null ? Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    child: Text(
                      '${distance > 1000 ? '1000+' : distance.toStringAsFixed(2)} ${'km_away_from_you'.tr}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,
                    ),
                  ) : Container(
                    height: 20, width: 30,
                    color: Colors.green,
                  ),
                ]),
              ]),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 5,
                  margin: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                  child: ListView.builder(
                    itemCount: 4,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                        height: 5, width: 10, color: Colors.blue,
                      );
                    },
                  ),
                ),
              ),

              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(Images.dmAvatar, height: 45, width: 45, fit: BoxFit.contain),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    'deliver_to'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style:  robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    parcel ? orderModel.receiverDetails?.address ?? '' : orderModel.deliveryAddress?.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ])),

                InkWell(
                  onTap: () => Get.to(()=> OrderLocationScreen(orderModel: orderModel, orderController: orderController, index: index, onTap: onTap,)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Colors.blue, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Text(
                      'view_on_map'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                    ),
                  ),
                ),
              ]),

            ]),
          ),

          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            margin: const EdgeInsets.all(0.2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                  (Get.find<SplashController>().configModel!.showDmEarning! && Get.find<AuthController>().profileModel != null
                      && Get.find<AuthController>().profileModel!.earnings == 1) ? Text(
                    PriceConverter.convertPrice(orderModel.originalDeliveryCharge! + orderModel.dmTips!),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    child: Text(
                      '${'payment'.tr} - ${orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'wallet' ? 'wallet'.tr : 'digitally_paid'.tr}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    ),
                  ),
                ]),
              ),

              Expanded(
                child: Row(children: [
                  Expanded(child: TextButton(
                    onPressed: () => Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_ignore'.tr,
                      description: parcel ? 'you_want_to_ignore_this_delivery'.tr : 'you_want_to_ignore_this_order'.tr,
                      onYesPressed: ()  {
                        if(Get.isSnackbarOpen){
                          Get.back();
                        }
                        orderController.ignoreOrder(index);
                        Get.back();
                        showCustomSnackBar('order_ignored'.tr, isError: false);
                      },
                    ), barrierDismissible: false),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        side: BorderSide(width: 1, color: Theme.of(context).disabledColor),
                      ),
                    ),
                    child: Text('ignore'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    )),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomButton(
                    height: 40,
                    radius: Dimensions.radiusDefault,
                    buttonText: 'accept'.tr,
                    fontSize: Dimensions.fontSizeDefault,
                    onPressed: () => Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_accept'.tr,
                      description: parcel ? 'you_want_to_accept_this_delivery'.tr : 'you_want_to_accept_this_order'.tr,
                      onYesPressed: () {
                        orderController.acceptOrder(orderModel.id, index, orderModel).then((isSuccess) {
                          if(isSuccess) {
                            onTap();
                            orderModel.orderStatus = (orderModel.orderStatus == 'pending' || orderModel.orderStatus == 'confirmed')
                                ? 'accepted' : orderModel.orderStatus;
                            Get.toNamed(
                              RouteHelper.getOrderDetailsRoute(orderModel.id),
                              arguments: OrderDetailsScreen(
                                orderId: orderModel.id, isRunningOrder: true, orderIndex: orderController.currentOrderList!.length-1,
                              ),
                            );
                          }else {
                            Get.find<OrderController>().getLatestOrders();
                          }
                        });
                      },
                    ), barrierDismissible: false),
                  )),
                ]),
              ),

            ]),
          ),

        ]);
      }),
    );
  }
}
