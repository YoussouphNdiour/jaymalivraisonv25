import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/helper/price_converter.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class DisbursementStatusCard extends StatelessWidget {
  final double amount;
  final String text;
  final bool isPending;
  final bool isCompleted;
  final bool isCanceled;
  final JustTheController? pendingToolTip;
  final JustTheController? completeToolTip;
  final JustTheController? canceledToolTip;
  const DisbursementStatusCard({Key? key, required this.amount, this.isPending = false, this.isCompleted = false, this.isCanceled = false, required this.text,
    this.pendingToolTip, this.completeToolTip, this.canceledToolTip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160, width: context.width * 0.65,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 500 : 200]!, spreadRadius: 0.5, blurRadius: 0.5)],
      ),
      child: Column(children: [

        Align(
          alignment: Alignment.topRight,
          child: JustTheTooltip(
            backgroundColor: Colors.black87,
            controller: isPending ? pendingToolTip : isCompleted ? completeToolTip : canceledToolTip,
            preferredDirection: AxisDirection.right,
            tailLength: 14,
            tailBaseWidth: 20,
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                isPending ? 'pending_message'.tr : isCompleted ? 'completed_message'.tr : 'cancellation_message'.tr,
                style: robotoRegular.copyWith(color: Colors.white),
              ),
            ),
            child: InkWell(
              onTap: () {
                if(isPending) {
                  pendingToolTip!.showTooltip();
                } else if(isCompleted) {
                  completeToolTip!.showTooltip();
                } else {
                  canceledToolTip!.showTooltip();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: isPending ? Colors.blue : isCompleted ? Colors.green : Colors.red, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                  child: Icon(Icons.info, color: isPending ? Colors.blue : isCompleted ? Colors.green : Colors.red, size: 15,),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Stack(
              children: [

                Container(
                  height: 50, width: 50,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: isPending ? Colors.blue : isCompleted ? Colors.green : Colors.red, shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(Images.transactionReportIcon),
                  ),
                ),

                Positioned(
                  right: 10, top: 10,
                  child: Image.asset(Images.onHoldTransactionIcon, height: 15, width: 15),
                ),
              ],
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                PriceConverter.convertPrice(amount),
                style: robotoBold.copyWith(
                  fontSize: 20, color: isPending ? Colors.blue : isCompleted ? Colors.green : Colors.red,
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                text,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
