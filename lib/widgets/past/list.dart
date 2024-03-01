import 'package:flutter/material.dart';

import 'package:my24_flutter_orders/common/widgets.dart';
import 'package:my24_flutter_orders/widgets/list.dart';

import '../../models/order/models.dart';

class PastListWidget extends OrderListWidget {
  PastListWidget({
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
    PastOrdersAppBarFactory factory = PastOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo?.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  @override
  handleNew(BuildContext context) {
    navFormFunction(context, null, fetchEvent);
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if (isPlanning() || isBranchEmployee()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getDeleteButton(context, order.id!)
        ],
      );
    } else {
      row = const Row();
    }

    return row;
  }
}
