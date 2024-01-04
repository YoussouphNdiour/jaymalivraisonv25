import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/view/base/custom_app_bar.dart';

class WalletProvidedHistoryScreen extends StatefulWidget {
  const WalletProvidedHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WalletProvidedHistoryScreen> createState() => _WalletProvidedHistoryScreenState();
}

class _WalletProvidedHistoryScreenState extends State<WalletProvidedHistoryScreen> {

  @override
  void initState() {
    Get.find<AuthController>().getWalletProvidedEarningList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'wallet_provided_earning_history'.tr),

      body: GetBuilder<AuthController>(builder: (authController) {
        return authController.walletProvidedTransactions != null ? authController.walletProvidedTransactions!.isNotEmpty ? ListView.builder(
          itemCount: authController.walletProvidedTransactions!.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(PriceConverter.convertPrice(authController.walletProvidedTransactions![index].amount), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
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
        ) : Center(child: Text('no_transaction_found'.tr)) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
