import 'package:flutter/material.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';

import '../models/order/models.dart';

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

  @override
  Widget createTitle() {
    String? baseTranslateString = getBaseTranslateStringForUser();
    String title;
    if (orders!.isEmpty) {
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
      List<dynamic> copy = List<dynamic>.from(orders!);
      copy.shuffle();
      List<dynamic> customerNames = getCustomerNames(copy);
      subtitle = My24i18n.tr("generic.orders_app_bar_subtitle",
          namedArgs: {'customers': customerNames.join(', ')}
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: const TextStyle(color: Colors.white, )),
        Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12.0)),
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

class PastOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  PastOrdersAppBarFactory({
    required super.orderPageMetaData,
    required super.context,
    required super.orders,
    required super.count,
    super.onStretch
  });

  @override
  String getBaseTranslateStringForUser() {
    return 'orders.past.app_bar_title';
  }
}

class UnacceptedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  UnacceptedOrdersAppBarFactory({
    required super.orderPageMetaData,
    required super.context,
    super.orders,
    super.count,
    super.onStretch
  });

  @override
  String getBaseTranslateStringForUser() {
    return 'orders.unaccepted.app_bar_title';
  }
}

class OrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrdersAppBarFactory({
    required super.orderPageMetaData,
    required super.context,
    required super.orders,
    required super.count,
    super.onStretch
  });
}

class OrderInfoCard extends StatelessWidget {
  final dynamic formData;
  final CoreUtils coreUtils = CoreUtils();

  OrderInfoCard({
    super.key,
    required this.formData
  });

  @override
  Widget build(BuildContext context) {
    final String nameText = formData.orderNameController!.text;
    return SizedBox(
        width: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                    nameText,
                    style: const TextStyle(fontWeight: FontWeight.w500)
                ),
                subtitle: Text(
                    '${formData.orderAddressController!.text}\n'
                        '${formData.orderCountryCode}-${formData.orderPostalController!.text}\n'
                        '${formData.orderCityController!.text}'
                ),
                leading: Icon(
                  Icons.home,
                  color: Colors.blue[500],
                ),
              ),
              if (formData.orderTelController!.text != '')
                ListTile(
                  title: Text(
                      formData.orderTelController!.text,
                      style: const TextStyle(fontWeight: FontWeight.w500)
                  ),
                  leading: Icon(
                    Icons.contact_phone,
                    color: Colors.blue[500],
                  ),
                  onTap: () {
                    coreUtils.launchURL("tel://${formData.orderTelController!.text}");
                  },
                ),
              if (formData.orderMobileController!.text != '')
                ListTile(
                  title: Text(
                      formData.orderMobileController!.text,
                      style: const TextStyle(fontWeight: FontWeight.w500)
                  ),
                  leading: Icon(
                    Icons.send_to_mobile,
                    color: Colors.blue[500],
                  ),
                  onTap: () {
                    coreUtils.launchURL("tel://${formData.orderMobileController!.text}");
                  },
                ),
              if (formData.orderEmailController!.text != '')
                ListTile(
                  title: Text(
                      formData.orderEmailController!.text,
                      style: const TextStyle(fontWeight: FontWeight.w500)
                  ),
                  leading: Icon(
                    Icons.email,
                    color: Colors.blue[500],
                  ),
                  onTap: () {
                    coreUtils.launchURL("mailto://${formData.orderEmailController!.text}");
                  },
                ),
            ],
          ),
        )
    );
  }
}

class OrderHistoryListSubtitle extends StatelessWidget {
  final double fontsizeKey = 12.0;
  final double fontsizeValue = 16.0;
  final Order order;
  final Widget? workorderWidget;

  const OrderHistoryListSubtitle({
    super.key,
    required this.order,
    this.workorderWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderSubHeaderKeyWidget(
          text:My24i18n.tr('orders.info_order_id'),
          fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: "${order.orderId}",
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_order_type'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.orderType}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_last_status'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.lastStatusFull}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        if (workorderWidget != null)
          workorderWidget!,
      ],
    );
  }
}

class OrderSubHeaderKeyWidget extends StatelessWidget {
  final String text;
  final double fontsize;

  const OrderSubHeaderKeyWidget({
    super.key,
    required this.text,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Text(text, style: TextStyle(fontSize: fontsize))
    );
  }
}

class OrderSubHeaderValueWidget extends StatelessWidget {
  final String text;
  final double fontsize;

  const OrderSubHeaderValueWidget({
    super.key,
    required this.text,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
        child: Text(text,
            style: TextStyle(
              fontSize: fontsize,
              // fontWeight: FontWeight.bold,
              // fontStyle: FontStyle.italic
            )
        )
    );
  }
}

class OrderHistoryListHeader extends StatelessWidget {
  final double fontsizeKey = 14.0;
  final double fontsizeValue = 20.0;
  final String date;

  const OrderHistoryListHeader({
    super.key,
    required this.date
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderHeaderKeyWidget(
            text: My24i18n.tr('orders.info_order_date'),
            fontsize: fontsizeKey
        ),
        OrderHeaderValueWidget(
            text: date,
            fontsize: fontsizeValue
        ),
      ],
    );
  }
}

class OrderHistoryWithAcceptedListHeader extends StatelessWidget {
  final double fontsizeKey = 14.0;
  final double fontsizeValue = 20.0;
  final String date;
  final bool customerOrderAccepted;

  const OrderHistoryWithAcceptedListHeader({
    super.key,
    required this.date,
    required this.customerOrderAccepted
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderHeaderKeyWidget(
            text: My24i18n.tr('orders.info_order_date'),
            fontsize: fontsizeKey
        ),
        OrderHeaderValueWidget(
            text: date,
            fontsize: fontsizeValue
        ),
        if (!customerOrderAccepted)
          Text(
              My24i18n.tr('orders.info_not_yet_accepted'),
              style: TextStyle(
                  fontSize: fontsizeValue,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
              )
          )
      ],
    );
  }
}

class OrderListSubtitleWidget extends StatelessWidget {
  final double fontsizeKey = 12.0;
  final double fontsizeValue = 16.0;
  final Order order;

  const OrderListSubtitleWidget({
    super.key,
    required this.order
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_order_id'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.orderId}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_address'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.orderAddress}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_postal_city'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_order_type'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.orderType}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 3),
        OrderSubHeaderKeyWidget(
            text: My24i18n.tr('orders.info_last_status'),
            fontsize: fontsizeKey
        ),
        OrderSubHeaderValueWidget(
            text: '${order.lastStatusFull}',
            fontsize: fontsizeValue
        )
      ],
    );
  }
}

class OrderHeaderKeyWidget extends StatelessWidget {
  final String text;
  final double fontsize;

  const OrderHeaderKeyWidget({
    super.key,
    required this.text,
    required this.fontsize
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child:
        Text(text, style: TextStyle(fontSize: fontsize, color: Colors.grey))
    );
  }
}

class OrderHeaderValueWidget extends StatelessWidget {
  final String text;
  final double fontsize;

  const OrderHeaderValueWidget({
    super.key,
    required this.text,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
        child: Text(text,
            style: TextStyle(
                fontSize: fontsize,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.black
            )
        )
    );
  }
}

class OrderListHeaderWidget extends StatelessWidget {
  final double fontsizeKey = 14.0;
  final double fontsizeValue = 20.0;
  final Order order;
  final String date;

  const OrderListHeaderWidget({
    super.key,
    required this.order,
    required this.date
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderHeaderKeyWidget(
            text: My24i18n.tr('generic.info_name'),
            fontsize: fontsizeKey
        ),
        OrderHeaderValueWidget(
            text: '${order.orderName}, ${order.orderCity}',
            fontsize: fontsizeValue
        ),
        const SizedBox(height: 2),
        OrderHeaderKeyWidget(
            text: My24i18n.tr('orders.info_order_date'),
            fontsize: fontsizeKey
        ),
        OrderHeaderValueWidget(
            text: date,
            fontsize: fontsizeValue
        ),
      ],
    );
  }
}

