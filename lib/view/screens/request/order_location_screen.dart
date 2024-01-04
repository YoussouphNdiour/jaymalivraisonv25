import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/order_controller.dart';
import 'package:sixam_mart_delivery/data/model/response/order_model.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/view/base/custom_app_bar.dart';
import 'package:sixam_mart_delivery/view/screens/request/widget/location_card.dart';

class OrderLocationScreen extends StatefulWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  final int index;
  final Function onTap;
  const OrderLocationScreen({Key? key, required this.orderModel, required this.orderController, required this.index, required this.onTap}) : super(key: key);

  @override
  State<OrderLocationScreen> createState() => _OrderLocationScreenState();
}

class _OrderLocationScreenState extends State<OrderLocationScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = HashSet<Marker>();

  @override
  Widget build(BuildContext context) {

    bool parcel = widget.orderModel.orderType == 'parcel';

    return Scaffold(
      appBar: CustomAppBar(title: 'order_location'.tr),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(
            double.parse(widget.orderModel.deliveryAddress?.latitude ?? '0'), double.parse(widget.orderModel.deliveryAddress?.longitude ?? '0'),
          ), zoom: 16),
          minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
          zoomControlsEnabled: false,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            setMarker(widget.orderModel, parcel);
          },
        ),

        Positioned(
          bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
          child: LocationCard(
            orderModel: widget.orderModel, orderController: widget.orderController,
            onTap: widget.onTap, index: widget.index,
          ),
        ),

      ]),

    );
  }

  void setMarker(OrderModel orderModel, bool parcel) async {
    try {
      Uint8List restaurantImageData = await convertAssetToUnit8List(parcel ? Images.userMarker : Images.restaurantMarker, width: parcel ? 70 : 100);
      Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.yourMarker, width: 100);
      Uint8List destinationImageData = await convertAssetToUnit8List(Images.customerMarker, width: 100);

      /// Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        if ((Get.find<AuthController>().recordLocationBody?.latitude ?? 0) < double.parse(parcel ? orderModel.receiverDetails?.latitude ?? '0' : orderModel.storeLat ?? '0')) {
          bounds = LatLngBounds(
            southwest: LatLng(Get.find<AuthController>().recordLocationBody?.latitude ?? 0, Get.find<AuthController>().recordLocationBody?.latitude ?? 0),
            northeast: LatLng(
              double.parse(parcel ? orderModel.receiverDetails?.latitude ?? '0' : orderModel.storeLat ?? '0'),
              double.parse(parcel ? orderModel.receiverDetails?.longitude ?? '0' : orderModel.storeLng ?? '0'),
            ),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(
              double.parse(parcel ? orderModel.receiverDetails?.latitude ?? '0' : orderModel.storeLat ?? '0'),
              double.parse(parcel ? orderModel.receiverDetails?.latitude ?? '0' : orderModel.storeLng ?? '0'),
            ),
            northeast: LatLng(Get.find<AuthController>().recordLocationBody?.latitude ?? 0, Get.find<AuthController>().recordLocationBody?.longitude ?? 0),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
      zoomToFit(_controller, bounds, centerBounds, padding: 1.5);

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();
      orderModel.deliveryAddress != null ? _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(double.parse(orderModel.deliveryAddress?.latitude ?? '0'), double.parse(orderModel.deliveryAddress?.longitude ?? '0')),
        infoWindow: InfoWindow(
          title: parcel ? 'Sender' : 'Destination',
          snippet: orderModel.deliveryAddress?.address,
        ),
        icon: BitmapDescriptor.fromBytes(destinationImageData),
      )) : const SizedBox();

      ///store for normal order , but receiver for parcel order
      orderModel.storeLat != null || orderModel.receiverDetails != null ? _markers.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: LatLng(
          double.parse(parcel ? orderModel.receiverDetails?.latitude ?? '0' : orderModel.storeLat ?? '0'),
          double.parse(parcel ? orderModel.receiverDetails?.longitude ?? '0' : orderModel.storeLng ?? '0'),
        ),
        infoWindow: InfoWindow(
          title: parcel ? 'Receiver' : orderModel.storeName,
          snippet: parcel ? orderModel.receiverDetails?.address : orderModel.storeAddress,
        ),
        icon: BitmapDescriptor.fromBytes(restaurantImageData),
      )) : const SizedBox();

      Get.find<AuthController>().recordLocationBody != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(Get.find<AuthController>().recordLocationBody?.latitude ?? 0, Get.find<AuthController>().recordLocationBody?.longitude ?? 0),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: Get.find<AuthController>().recordLocationBody?.location,
        ),
        // rotation: rotation,
        icon: BitmapDescriptor.fromBytes(deliveryBoyImageData),
      )) : const SizedBox();
    }catch(_) {}
    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }
}
