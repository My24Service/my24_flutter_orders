import 'package:flutter/material.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import '../../../common/widgets.dart';
import '../../../models/order/models.dart';
import '../../../blocs/order_bloc.dart';
import '../list.dart';

class UnacceptedListWidget extends OrderListWidget {
  UnacceptedListWidget({
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
        getDocumentsButton(context, order.id!),
        const SizedBox(width: 10),
        getDeleteButton(context, order.id!),
      ],
    );
  }
}
