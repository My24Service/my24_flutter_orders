import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';

import '../infoline/form_data.dart';
import '../infoline/models.dart';
import '../orderline/form_data.dart';
import '../orderline/models.dart';
import 'models.dart';

abstract class BaseOrderFormData extends BaseFormData<Order> {
  TextEditingController? typeAheadControllerCustomer = TextEditingController();
  TextEditingController? typeAheadControllerBranch = TextEditingController();

  int? id;
  int? branch;
  int? customerPk;
  String? customerId;
  int? customerBranchId;

  TextEditingController? orderCustomerIdController = TextEditingController();
  TextEditingController? orderNameController = TextEditingController();
  TextEditingController? orderAddressController = TextEditingController();
  TextEditingController? orderPostalController = TextEditingController();
  TextEditingController? orderCityController = TextEditingController();
  TextEditingController? orderContactController = TextEditingController();
  TextEditingController? orderReferenceController = TextEditingController();
  TextEditingController? customerRemarksController = TextEditingController();
  TextEditingController? orderEmailController = TextEditingController();
  TextEditingController? orderMobileController = TextEditingController();
  TextEditingController? orderTelController = TextEditingController();

  OrderlineFormData? orderlineFormData = OrderlineFormData();
  InfolineFormData? infolineFormData = InfolineFormData();

  List<Orderline>? orderLines = [];
  List<Infoline>? infoLines = [];

  List<Orderline>? deletedOrderLines = [];
  List<Infoline>? deletedInfoLines = [];

  DateTime? startDate = DateTime.now();
  DateTime? startTime; // = DateTime.now();
  DateTime? endDate = DateTime.now();
  DateTime? endTime; // = DateTime.now();
  bool? changedEndDate = false;

  OrderTypes? orderTypes;
  String? orderType;
  String? orderCountryCode = 'NL';
  bool? customerOrderAccepted = false;

  List<EquipmentLocation>? locations = [];

  String? error;
  bool? isCreatingEquipment = false;
  bool? isCreatingLocation = false;

  QuickCreateSettings? quickCreateSettings;

  String _formatTime(DateTime time) {
    String timePart = '$time'.split(' ')[1];
    List<String> hoursMinutes = timePart.split(':');

    return '${hoursMinutes[0]}:${hoursMinutes[1]}';
  }

  bool isValid() {
    if (orderType == null) {
      return false;
    }

    return true;
  }

  @override
  Order toModel() {
    Order order = Order(
        id: id,
        branch: branch,
        customerId: orderCustomerIdController!.text,
        customerRelation: customerPk,
        orderReference: orderReferenceController!.text,
        orderType: orderType,
        customerRemarks: customerRemarksController!.text,
        startDate: coreUtils.formatDate(startDate!),
        startTime: startTime != null ? _formatTime(startTime!.toLocal()) : null,
        endDate: coreUtils.formatDate(endDate!),
        endTime: endTime != null ? _formatTime(endTime!.toLocal()) : null,
        orderName: orderNameController!.text,
        orderAddress: orderAddressController!.text,
        orderPostal: orderPostalController!.text,
        orderCity: orderCityController!.text,
        orderCountryCode: orderCountryCode,
        orderTel: orderTelController!.text,
        orderMobile: orderMobileController!.text,
        orderEmail: orderEmailController!.text,
        orderContact: orderContactController!.text,
        orderLines: orderLines,
        infoLines: infoLines,
        customerOrderAccepted: customerOrderAccepted,
    );

    return order;
  }

  BaseOrderFormData({
      this.id,
      this.typeAheadControllerCustomer,
      this.typeAheadControllerBranch,
      this.customerPk,
      this.customerId,
      this.branch,
      this.orderlineFormData,
      this.infolineFormData,
      this.orderCustomerIdController,
      this.orderNameController,
      this.orderAddressController,
      this.orderPostalController,
      this.orderCityController,
      this.orderContactController,
      this.orderReferenceController,
      this.customerRemarksController,
      this.orderEmailController,
      this.orderMobileController,
      this.orderTelController,

      this.orderLines,
      this.deletedOrderLines,
      this.infoLines,
      this.deletedInfoLines,

      this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      this.changedEndDate,
      this.orderTypes,
      this.orderType,
      this.orderCountryCode,
      this.customerOrderAccepted,
      this.locations,
      this.error,
      this.isCreatingEquipment,
      this.isCreatingLocation,
      this.quickCreateSettings,
      this.customerBranchId
  });
}
