import 'package:flutter/material.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import '../../../common/widgets.dart';
import '../../../models/order/models.dart';
import '../../../widgets/order/list.dart';
import '../../../blocs/order_bloc.dart';

class PastListWidget extends OrderListWidget {
  PastListWidget({
    Key? key,
    required List<Order>? orderList,
    required OrderPageMetaData orderPageMetaData,
    required OrderEventStatus fetchEvent,
    required String? searchQuery,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn,
    required PaginationInfo paginationInfo,
  }): super(
    key: key,
      orderList: orderList,
      orderPageMetaData: orderPageMetaData,
      fetchEvent: fetchEvent,
      searchQuery: searchQuery,
      paginationInfo: paginationInfo,
      widgetsIn: widgetsIn,
      i18nIn: i18nIn
  );

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
}
