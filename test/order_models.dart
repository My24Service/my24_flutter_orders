import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_form_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_form_states.dart';
import 'package:my24_flutter_orders/models/infoline/form_data.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/pages/detail.dart';
import 'package:my24_flutter_orders/pages/form.dart';
import 'package:my24_flutter_orders/pages/list.dart';
import 'package:my24_flutter_orders/widgets/empty.dart';
import 'package:my24_flutter_orders/widgets/form/order.dart';
import 'package:my24_flutter_orders/widgets/list.dart';

class OrderFormBloc extends OrderFormBlocBase {
  OrderFormBloc() : super(OrderFormInitialState()) {
    on<OrderFormEvent>((event, emit) async {
      if (event.status == OrderFormEventStatus.newOrder) {
        await _handleNewFormDataState(event, emit);
      } else {
        await handleEvent(event, emit);
      }
    },
        transformer: sequential());
  }

  Future<void> _handleNewFormDataState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
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

    super.infolineFormData,

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
    super.quickCreateSettings,
    super.customerBranchId,
    super.equipmentLocationUpdates
  });

  factory OrderFormData.newFromOrderTypes(OrderTypes orderTypes) {
    return OrderFormData(
      orderTypes: orderTypes,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      documents: [],
      orderLines: [],
      infoLines: [],
      equipmentLocationUpdates: [],
      infolineFormData: InfolineFormData.createEmpty(null)
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

      quickCreateSettings: null,
      equipmentLocationUpdates: [],

      infolineFormData: InfolineFormData.createEmpty(null)
    );
  }
}

class OrderFormWidget<OrderFormBloc, OrderFormData> extends BaseOrderFormWidget {
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

class OrderFormPageClass<OrderFormBloc> extends BaseOrderFormPage {
  OrderFormPageClass({
    super.key,
    super.bloc,
    required super.fetchMode,
    required super.pk
  });

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

  @override
  void navList(BuildContext context, OrderEventStatus fetchMode) {
    // TODO: implement navList
  }

}

class OrderListWidget extends BaseOrderListWidget {
  OrderListWidget({super.key, required super.orderList, required super.orderPageMetaData, required super.fetchEvent, required super.searchQuery, required super.paginationInfo, required super.widgetsIn, required super.i18nIn});

  @override
  void navDetail(BuildContext context, int orderPk) {
    // TODO: implement navDetail
  }

  @override
  void navForm(BuildContext context, int? orderPk, OrderEventStatus fetchMode) {
    // TODO: implement navForm
  }

}

class OrderListEmptyWidget extends BaseOrderListEmptyWidget {
  OrderListEmptyWidget({super.key, required super.widgetsIn, required super.i18nIn, required super.fetchEvent});

  @override
  void navForm(BuildContext context, int? orderPk, OrderEventStatus fetchMode) {
    // TODO: implement navForm
  }

}

class OrderListPage<OrderFormBloc> extends BaseOrderListPage {
  OrderListPage({
    super.key,
    required super.bloc,
    required super.fetchMode,
    String? initialMode,
    int? pk
  });

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
    return null;
  }

  @override
  Widget getOrderListWidget({
    List<Order>? orderList,
    required OrderPageMetaData orderPageMetaData,
    required OrderEventStatus fetchEvent,
    String? searchQuery,
    required PaginationInfo paginationInfo,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn
  }) {
    return OrderListWidget(
      orderList: orderList,
      orderPageMetaData: orderPageMetaData,
      fetchEvent: fetchMode,
      searchQuery: searchQuery,
      paginationInfo: paginationInfo,
      widgetsIn: widgets,
      i18nIn: i18n,
    );
  }

  @override
  Widget getOrderListEmptyWidget({required widgetsIn, required i18nIn, required fetchEvent}) {
    return OrderListEmptyWidget(
      widgetsIn: widgetsIn,
      i18nIn: i18nIn,
      fetchEvent: fetchEvent
    );
  }

}

class OrderDetailPage extends BaseOrderDetailPage {
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
