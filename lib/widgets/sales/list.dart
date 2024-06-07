import 'package:flutter/material.dart';

import 'package:my24_flutter_orders/common/widgets.dart';
import '../list.dart';

class SalesListWidget extends OrderListWidget {
  SalesListWidget({
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
    SalesListOrdersAppBarFactory factory = SalesListOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo!.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }
}
