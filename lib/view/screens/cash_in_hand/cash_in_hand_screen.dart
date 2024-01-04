import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/view/base/custom_app_bar.dart';
import 'package:sixam_mart_delivery/view/base/custom_button.dart';
import 'package:sixam_mart_delivery/view/base/custom_image.dart';
import 'package:sixam_mart_delivery/view/screens/cash_in_hand/widget/payment_method_bottom_sheet.dart';
import 'package:sixam_mart_delivery/view/screens/cash_in_hand/widget/wallet_attention_alert.dart';

class CashInHandScreen extends StatefulWidget {
  const CashInHandScreen({Key? key}) : super(key: key);

  @override
  State<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends State<CashInHandScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<AuthController>().getProfile();
    Get.find<AuthController>().getWalletPaymentList();
    Get.find<AuthController>().getWalletProvidedEarningList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(Get.find<AuthController>().profileModel == null) {
      Get.find<AuthController>().getProfile();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'my_account'.tr,
        isBackButtonExist: true,
        actionWidget: GetBuilder<AuthController>(builder: (authController) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(200), border: Border.all(width: 1.5, color: Theme.of(context).primaryColor)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: CustomImage(
                image: '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}'
                    '/${(authController.profileModel != null && Get.find<AuthController>().isLoggedIn()) ? authController.profileModel!.image ?? '' : ''}',
                width: 35, height: 35, fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),

      body: GetBuilder<AuthController>(builder: (authController) {
        return (authController.profileModel != null && authController.transactions != null) ? RefreshIndicator(
          onRefresh: () async {
            authController.getProfile();
            Get.find<AuthController>().getWalletPaymentList();
            Get.find<AuthController>().getWalletProvidedEarningList();
            return await Future.delayed(const Duration(seconds: 1));
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(children: [

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    Container(
                      width: context.width, height: 129,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: const Color(0xff334257),
                        image: const DecorationImage(
                          image: AssetImage(Images.cashInHandBg),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Row(
                                children: [
                                  Image.asset(Images.walletIcon, width: 40, height: 40),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  Text('payable_amount'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              Text(PriceConverter.convertPrice(authController.profileModel!.payableBalance), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor)),
                            ]),
                          ),

                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                            authController.profileModel!.adjustable! ? InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return GetBuilder<AuthController>(builder: (controller) {
                                      return AlertDialog(
                                        title: Center(child: Text('cash_adjustment'.tr)),
                                        content: Text('cash_adjustment_description'.tr, textAlign: TextAlign.center),
                                        actions: [

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(children: [

                                              Expanded(
                                                child: SizedBox(
                                                  height: 45,
                                                  child: CustomButton(
                                                    onPressed: () => Get.back(),
                                                    backgroundColor: Theme.of(context).disabledColor.withOpacity(0.5),
                                                    buttonText: 'cancel'.tr,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    authController.makeWalletAdjustment();
                                                  },
                                                  child: Container(
                                                    height: 45,
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    child: !controller.isLoading ? Text('ok'.tr, style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeLarge),)
                                                      : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)),
                                                  ),
                                                ),
                                              ),

                                            ]),
                                          ),

                                        ],
                                      );
                                    });
                                  }
                                );
                              },
                              child: Container(
                                width: 115,
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Text('adjust_payments'.tr, textAlign: TextAlign.center, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                              ),
                            ) : const SizedBox(),
                            SizedBox(height: authController.profileModel!.adjustable! ? Dimensions.paddingSizeLarge : 0),

                            InkWell(
                              onTap: authController.profileModel!.cashInHands! > 0 ? () {
                                showModalBottomSheet(
                                  isScrollControlled: true, useRootNavigator: true, context: context,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                                  ),
                                  builder: (context) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                      child: const PaymentMethodBottomSheet(),
                                    );
                                  },
                                );
                              } : null,
                              child: Container(
                                width: authController.profileModel!.adjustable! ? 115 : null,
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: authController.profileModel!.cashInHands! > 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.8),
                                ),
                                child: Text('pay_now'.tr, textAlign: TextAlign.center, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                              ),
                            ),

                          ]),
                        ]),
                      ),

                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Row(children: [

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).cardColor,
                            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 0.5, blurRadius: 5)],
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                            Text(
                              PriceConverter.convertPrice(authController.profileModel!.cashInHands),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Text('cash_in_hand'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),

                          ]),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).cardColor,
                            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 0.5, blurRadius: 5)],
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                            Text(
                              PriceConverter.convertPrice(authController.profileModel!.totalWithdrawn),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Text('total_withdrawn'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),

                          ]),
                        ),
                      ),

                    ]),

                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                      child: Row(children: [

                        InkWell(
                          onTap: () {
                            if(authController.selectedIndex != 0) {
                              authController.setIndex(0);
                            }
                          },
                          hoverColor: Colors.transparent,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('payment_history'.tr, style: robotoMedium.copyWith(
                              color: authController.selectedIndex == 0 ? Colors.blue : Theme.of(context).disabledColor,
                            )),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Container(
                              height: 3, width: 110,
                              margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: authController.selectedIndex == 0 ? Colors.blue : null,
                              ),
                            ),

                          ]),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        InkWell(
                          onTap: () {
                            if(authController.selectedIndex != 1) {
                              authController.setIndex(1);
                            }
                          },
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('wallet_provided_earning'.tr, style: robotoMedium.copyWith(
                              color: authController.selectedIndex == 1 ? Colors.blue : Theme.of(context).disabledColor,
                            )),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Container(
                              height: 3, width: 150,
                              margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: authController.selectedIndex == 1 ? Colors.blue : null,
                              ),
                            ),

                          ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Text("transaction_history".tr, style: robotoMedium),

                      InkWell(
                        onTap: () {
                          if(authController.selectedIndex == 0) {
                            Get.toNamed(RouteHelper.getTransactionHistoryRoute());
                          }
                          if(authController.selectedIndex == 1) {
                            Get.toNamed(RouteHelper.getWalletProvidedEarningRoute());
                          }

                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Text('view_all'.tr, style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor,
                          )),
                        ),
                      ),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    if(authController.selectedIndex == 0)
                    authController.transactions != null ? authController.transactions!.isNotEmpty ? ListView.builder(
                      itemCount: authController.transactions!.length > 25 ? 25 : authController.transactions!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(children: [

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(PriceConverter.convertPrice(authController.transactions![index].amount), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), textDirection: TextDirection.ltr,),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text('${'paid_via'.tr} ${authController.transactions![index].method?.replaceAll('_', ' ').capitalize??''}', style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                  )),
                                ]),
                              ),
                              Text(authController.transactions![index].paymentTime.toString(),
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              ),
                            ]),
                          ),

                          const Divider(height: 1),
                        ]);
                      },
                    ) : Center(child: Padding(padding: const EdgeInsets.only(top: 250), child: Text('no_transaction_found'.tr)))
                        : const Center(child: Padding(padding: EdgeInsets.only(top: 250), child: CircularProgressIndicator())),

                    if(authController.selectedIndex == 1)
                      authController.walletProvidedTransactions != null ? authController.walletProvidedTransactions!.isNotEmpty ? ListView.builder(
                        itemCount: authController.walletProvidedTransactions!.length > 25 ? 25 : authController.walletProvidedTransactions!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                              child: Row(children: [
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(PriceConverter.convertPrice(authController.walletProvidedTransactions![index].amount), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), textDirection: TextDirection.ltr,),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Text('${'wallet'.tr} ${authController.walletProvidedTransactions![index].method?.replaceAll('_', ' ').capitalize??''}', style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                    )),
                                  ]),
                                ),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text(authController.walletProvidedTransactions![index].paymentTime.toString(),
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text(authController.walletProvidedTransactions![index].status!.tr, style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: authController.walletProvidedTransactions![index].status == 'approved' ? Theme.of(context).primaryColor : authController.walletProvidedTransactions![index].status == 'denied'
                                        ? Theme.of(context).colorScheme.error : Colors.blue,
                                  )),
                                ]),
                              ]),
                            ),

                            const Divider(height: 1),
                          ]);
                        },
                      ) : Center(child: Padding(padding: const EdgeInsets.only(top: 250), child: Text('no_transaction_found'.tr)))
                          : const Center(child: Padding(padding: EdgeInsets.only(top: 250), child: CircularProgressIndicator())),

                  ]),

                ),
              ),

              (authController.profileModel!.overFlowWarning! || authController.profileModel!.overFlowBlockWarning!)
                ? WalletAttentionAlert(isOverFlowBlockWarning: authController.profileModel!.overFlowBlockWarning!) : const SizedBox(),

            ]),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
