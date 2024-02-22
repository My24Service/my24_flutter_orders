import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/pages/detail.dart';
import 'package:my24_flutter_orders/pages/list.dart';
import 'package:my24_flutter_orders/widgets/form/order.dart';

class OrderBloc extends OrderBlocBase {
  OrderBloc() : super(OrderInitialState()) {
    on<OrderEvent>((event, emit) async {
      if (event.status == OrderEventStatus.newOrder) {
        await _handleNewFormDataState(event, emit);
      } else {
        await handleEvent(event, emit);
      }
    },
        transformer: sequential());
  }

  Future<void> _handleNewFormDataState(OrderEvent event, Emitter<OrderState> emit) async {
    final OrderTypes orderTypes = await api.fetchOrderTypes();
    OrderFormData orderFormData = OrderFormData.newFromOrderTypes(orderTypes);
    orderFormData = await addQuickCreateSettings(orderFormData) as OrderFormData;

    emit(OrderNewState(
        formData: orderFormData
    ));
  }

  @override
  OrderFormData createFromModel(Order order, OrderTypes orderTypes) {
    return OrderFormData.createFromModel(order, orderTypes);
  }

}

class OrderFormData extends BaseOrderFormData {
  OrderFormData({
    super.id,
    super.typeAheadControllerCustomer,
    super.typeAheadControllerBranch,
    super.customerPk,
    super.customerId,
    super.branch,

    super.orderCustomerIdController,
    super.orderNameController,
    super.orderAddressController,
    super.orderPostalController,
    super.orderCityController,
    super.orderContactController,
    super.orderReferenceController,
    super.customerRemarksController,
    super.orderEmailController,
    super.orderMobileController,
    super.orderTelController,

    super.orderLines,
    super.deletedOrderLines,
    super.infoLines,
    super.deletedInfoLines,
    super.documents,
    super.deletedDocuments,

    super.startDate,
    super.startTime,
    super.endDate,
    super.endTime,
    super.changedEndDate,
    super.orderTypes,
    super.orderType,
    super.orderCountryCode,
    super.customerOrderAccepted,
    super.error,
    super.isCreatingEquipment,
    super.isCreatingLocation,
    super.quickCreateSettings,
    super.customerBranchId
  });

  factory OrderFormData.newFromOrderTypes(OrderTypes orderTypes) {
    return OrderFormData(
      orderTypes: orderTypes,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      documents: [],
      orderLines: [],
      infoLines: []
    );
  }

  static OrderFormData createFromModel(Order order, OrderTypes orderTypes) {
    final TextEditingController typeAheadControllerCustomer = TextEditingController();
    final TextEditingController typeAheadControllerBranch = TextEditingController();

    final TextEditingController orderCustomerIdController = TextEditingController();
    orderCustomerIdController.text = checkNull(order.customerId);

    final TextEditingController orderNameController = TextEditingController();
    orderNameController.text = checkNull(order.orderName);

    final TextEditingController orderAddressController = TextEditingController();
    orderAddressController.text = checkNull(order.orderAddress);

    final TextEditingController orderPostalController = TextEditingController();
    orderPostalController.text = checkNull(order.orderPostal);

    final TextEditingController orderCityController = TextEditingController();
    orderCityController.text = checkNull(order.orderCity);

    final TextEditingController orderContactController = TextEditingController();
    orderContactController.text = checkNull(order.orderContact);

    final TextEditingController orderEmailController = TextEditingController();
    orderEmailController.text = checkNull(order.orderEmail);

    final TextEditingController orderTelController = TextEditingController();
    orderTelController.text = checkNull(order.orderTel);

    final TextEditingController orderMobileController = TextEditingController();
    orderMobileController.text = checkNull(order.orderMobile);

    final TextEditingController orderReferenceController = TextEditingController();
    orderReferenceController.text = checkNull(order.orderReference);

    final TextEditingController customerRemarksController = TextEditingController();
    customerRemarksController.text = checkNull(order.customerRemarks);

    DateTime? startTime;
    if (order.startTime != null) {
      startTime = DateFormat('d/M/yyyy H:m:s').parse(
          '${order.startDate} ${order.startTime}');
    }

    DateTime? endTime;
    if (order.endTime != null) {
      endTime = DateFormat('d/M/yyyy H:m:s').parse(
          '${order.endDate} ${order.endTime}');
    }

    return OrderFormData(
      id: order.id,
      customerId: order.customerId,
      branch: order.branch,
      typeAheadControllerCustomer: typeAheadControllerCustomer,
      typeAheadControllerBranch: typeAheadControllerBranch,
      orderCustomerIdController: orderCustomerIdController,
      orderNameController: orderNameController,
      orderAddressController: orderAddressController,
      orderPostalController: orderPostalController,
      orderCityController: orderCityController,
      orderCountryCode: order.orderCountryCode,
      orderContactController: orderContactController,
      orderEmailController: orderEmailController,
      orderTelController: orderTelController,
      orderMobileController: orderMobileController,
      orderReferenceController: orderReferenceController,
      customerRemarksController: customerRemarksController,
      orderType: order.orderType,
      orderTypes: orderTypes,
      // // "start_date": "26/10/2020"
      startDate: DateFormat('d/M/yyyy').parse(order.startDate!),
      startTime: startTime,
      // // "end_date": "26/10/2020",
      endDate: DateFormat('d/M/yyyy').parse(order.endDate!),
      endTime: endTime,
      customerOrderAccepted: order.customerOrderAccepted,

      orderLines: order.orderLines,
      infoLines: order.infoLines,
      documents: order.documents,
      deletedOrderLines: [],
      deletedInfoLines: [],
      deletedDocuments: [],

      isCreatingEquipment: false,
      isCreatingLocation: false,
      quickCreateSettings: null,
    );
  }

}

class OrderFormWidget<OrderBloc, OrderFormData> extends BaseOrderFormWidget {
  OrderFormWidget({
    super.key,
    required super.orderPageMetaData,
    required super.formData,
    required super.fetchEvent,
    required super.widgetsIn
  });

  @override
  TableRow getFirstElement(BuildContext context) {
    return const TableRow(
      children: [
        SizedBox(),
        SizedBox()
      ]
    );
  }
}

class OrderListPage<OrderBloc> extends BaseOrderListPage {
  OrderListPage({
    super.key,
    required super.bloc,
    required super.fetchMode,
    String? initialMode,
    int? pk
  }) : super(initialMode: initialMode, pk: pk);

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
    return null;
  }

  @override
  void navDetail(BuildContext context, int orderPk, dynamic bloc) {
    Navigator.of(context).pop();
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderId: orderPk,
              bloc: bloc,
            )
        )
    );
  }

  @override
  Widget getOrderFormWidget(
      {
        required dynamic formData,
        required OrderPageMetaData orderPageMetaData,
        required OrderEventStatus fetchEvent,
        required CoreWidgets widgets
      }
      ) {
    return OrderFormWidget(
      orderPageMetaData: orderPageMetaData,
      formData: formData,
      fetchEvent: fetchMode,
      widgetsIn: widgets,
    );
  }

}

class OrderDetailPage<OrderBloc> extends BaseOrderDetailPage {
  OrderDetailPage({
    super.key,
    required super.bloc,
    required super.orderId,
  });

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
    return null;
  }

}
