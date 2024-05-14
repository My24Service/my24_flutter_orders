import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import '../../blocs/order_bloc.dart';
import '../pages/types.dart';

class OrderListEmptyWidget extends BaseEmptyWidget {
  final OrderEventStatus fetchEvent;
  final TextEditingController searchController = TextEditingController();
  final NavFormFunction navFormFunction;

  OrderListEmptyWidget({
    super.key,
    super.memberPicture,
    required super.widgetsIn,
    required super.i18nIn,
    required this.fetchEvent,
    required this.navFormFunction
  });

  @override
  String getAppBarTitle(BuildContext context) {
    return i18n.$trans('list.app_bar_title_empty');
  }

  @override
  String getEmptyMessage() {
    return i18nIn.$trans('list.notice_no_order');
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

  handleNew(BuildContext context, {OrderEventStatus? fetchMode}) {
    navFormFunction(context, null, fetchMode ?? fetchEvent);
  }
}
