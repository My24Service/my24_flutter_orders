import 'package:flutter/material.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';

// order appbars have some more logic in them
import '../models/order/models.dart';

Widget getOrderHeaderKeyWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child:
      Text(text, style: TextStyle(fontSize: fontsize, color: Colors.grey)));
}

Widget getOrderHeaderValueWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black)));
}

Widget getOrderSubHeaderKeyWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(top: 1.0),
      child: Text(text, style: TextStyle(fontSize: fontsize)));
}

Widget getOrderSubHeaderValueWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
            fontSize: fontsize,
            // fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic
          )));
}

Widget createOrderListHeader2(Order order, String date) {
  double fontsizeKey = 14.0;
  double fontsizeValue = 20.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderHeaderKeyWidget(
          My24i18n.tr('orders.info_customer'), fontsizeKey),
      getOrderHeaderValueWidget(
          '${order.orderName}, ${order.orderCity}', fontsizeValue),
      SizedBox(height: 2),
      getOrderHeaderKeyWidget(
          My24i18n.tr('orders.info_order_date'), fontsizeKey),
      getOrderHeaderValueWidget(date, fontsizeValue),
    ],
  );
}

Widget createOrderHistoryListHeader2(String date) {
  double fontsizeKey = 14.0;
  double fontsizeValue = 20.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderHeaderKeyWidget(
          My24i18n.tr('orders.info_order_date'), fontsizeKey),
      getOrderHeaderValueWidget(date, fontsizeValue),
    ],
  );
}

Widget createOrderListSubtitle2(Order order) {
  double fontsizeKey = 12.0;
  double fontsizeValue = 16.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_order_id'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderId}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_address'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderAddress}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_postal_city'), fontsizeKey),
      getOrderSubHeaderValueWidget(
          '${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}',
          fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_order_type'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderType}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_last_status'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.lastStatusFull}', fontsizeValue)
    ],
  );
}

abstract class BaseOrdersAppBarFactory extends BaseGenericAppBarFactory {
  BuildContext context;
  List<dynamic>? orders;
  OrderPageMetaData orderPageMetaData;
  int? count;
  Function? onStretch;

  BaseOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    this.onStretch
  }): super(
      mainMemberPicture: orderPageMetaData.memberPicture,
      mainContext: context,
      mainSubtitle: '',
      mainTitle: ''
  );

  String? getBaseTranslateStringForUser() {
    if (orderPageMetaData.submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user';
    }
    if (orderPageMetaData.submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user';
    }
    if (orderPageMetaData.submodel == 'sales_user') {
      return 'orders.list.app_title_sales_user';
    }
    if (orderPageMetaData.submodel == 'branch_employee_user') {
      return 'orders.list.app_title_branch_employee_user';
    }

    return null;
  }

  List<dynamic> getCustomerNames(List<dynamic> orders) {
    return orders.map((order) => {
      order.orderName
    }).map((e) => e.first).toList().toSet().toList().take(3).toList();
  }

  Widget createTitle() {
    String? baseTranslateString = getBaseTranslateStringForUser();
    String title;
    if (orders!.length == 0) {
      final String firstName = orderPageMetaData.firstName == null ? "" : orderPageMetaData.firstName!;
      title = My24i18n.tr('${baseTranslateString}_no_orders', namedArgs: {
        'numOrders': "$count",
        'firstName': firstName
      }
      );
    } else if (orders!.length == 1) {
      final String firstName = orderPageMetaData.firstName == null ? "" : orderPageMetaData.firstName!;
      title = My24i18n.tr("${baseTranslateString}_one_order", namedArgs: {
        'numOrders': "$count",
        'firstName': firstName
      }
      );
    } else {
      final String firstName = orderPageMetaData.firstName == null ? "" : orderPageMetaData.firstName!;
      title = My24i18n.tr("$baseTranslateString", namedArgs: {
        'numOrders': "$count",
        'firstName': firstName
      }
      );
    }

    String subtitle = "";
    if (orders!.length > 1) {
      List<dynamic> copy = new List<dynamic>.from(orders!);
      copy.shuffle();
      List<dynamic> customerNames = getCustomerNames(copy);
      subtitle = My24i18n.tr("generic.orders_app_bar_subtitle",
          namedArgs: {'customers': "${customerNames.join(', ')}"});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: TextStyle(color: Colors.white, )),
        Text(subtitle, style: TextStyle(color: Colors.white, fontSize: 12.0)),
      ],
    );

    // return ListTile(
    //     contentPadding: contentPadding,
    //     textColor: Colors.white,
    //     title: Text(title),
    //     subtitle: Text(subtitle)
    // );
  }
}

class AssignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  AssignedOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'assigned_orders.list.app_bar_title';
  }

  List<dynamic> getCustomerNames(List<dynamic> orders) {
    return orders.map((assignedOrder) => {
      assignedOrder.order.orderName
    }).map((e) => e.first).toList().toSet().toList().take(3).toList();
  }

}

class PastOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  PastOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.past.app_bar_title';
  }
}

class SalesListOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  SalesListOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.sales_list.app_bar_title';
  }
}

class UnacceptedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  UnacceptedOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.unaccepted.app_bar_title';
  }
}

class UnassignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  UnassignedOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.unassigned.app_bar_title';
  }
}

class OrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  OrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );
}
