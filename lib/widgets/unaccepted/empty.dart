import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/order_bloc.dart';
import '../empty.dart';

class UnacceptedListEmptyWidget extends OrderListEmptyWidget {
  UnacceptedListEmptyWidget({
    super.key,
    super.memberPicture,
    required super.widgetsIn,
    required super.i18nIn,
    required super.fetchEvent,
    required super.navFormFunction,
  });

  @override
  String getAppBarTitle(BuildContext context) {
    return i18n.$trans('unaccepted.app_bar_title_empty');
  }

  @override
  String getEmptyMessage() {
    return i18nIn.$trans('unaccepted.notice_no_order');
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
}
