import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/order_bloc.dart';
import '../empty.dart';

class PastListEmptyWidget extends BaseOrderListEmptyWidget {
  PastListEmptyWidget({
    super.key,
    super.memberPicture,
    required super.widgetsIn,
    required super.i18nIn,
    required super.fetchEvent,
  });

  @override
  String getEmptyMessage() {
    return i18nIn.$trans('past.notice_no_order');
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(const OrderEvent(status: OrderEventStatus.doRefresh));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return widgets.showPaginationSearchNewSection(
      context,
      null,
      searchController,
      () {  },
      () {  },
      doSearch,
      handleNew
    );
  }

  @override
  doSearch(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(const OrderEvent(status: OrderEventStatus.doSearch));
    bloc.add(OrderEvent(
        status: fetchEvent,
        query: searchController.text,
        page: 1
    ));
  }

  @override
  void navForm(BuildContext context, int? orderPk, OrderEventStatus fetchMode) {
    super.navOrderForm(context, orderPk, fetchMode: fetchEvent);
  }
}
