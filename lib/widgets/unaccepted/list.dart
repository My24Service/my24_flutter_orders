import 'package:flutter/material.dart';

import 'package:my24_flutter_orders/common/widgets.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import '../list.dart';

class UnacceptedListWidget extends OrderListWidget {
  UnacceptedListWidget({
    super.key,
    required super.orderList,
    required super.orderPageMetaData,
    required super.fetchEvent,
    required super.searchQuery,
    required super.widgetsIn,
    required super.i18nIn,
    required super.paginationInfo,
    required super.navFormFunction,
    required super.navDetailFunction,
  });

  @override
  SliverAppBar getAppBar(BuildContext context) {
    UnacceptedOrdersAppBarFactory factory = UnacceptedOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo?.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getEditButton(context, order.id!),
        const SizedBox(width: 10),
        getDeleteButton(context, order.id!),
      ],
    );
  }

  @override
  handleNew(BuildContext context) {
    navFormFunction(context, null, fetchEvent);
  }

  @override
  doEdit(BuildContext context, int orderPk) {
    navFormFunction(context, orderPk, fetchEvent);
  }

}
