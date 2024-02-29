import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../blocs/order_bloc.dart';

abstract class BaseOrderListEmptyWidget extends BaseEmptyWidget {
  final OrderEventStatus fetchEvent;
  final TextEditingController searchController = TextEditingController();

  BaseOrderListEmptyWidget({
    Key? key,
    String? memberPicture,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn,
    required this.fetchEvent,
  }) : super(
    key: key,
    memberPicture: memberPicture,
    widgetsIn: widgetsIn,
    i18nIn: i18nIn
  );

  void navForm(BuildContext context, int? orderPk, OrderEventStatus fetchMode);

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

  navOrderForm(BuildContext context, int? orderPk, {OrderEventStatus? fetchMode}) {
    navForm(context, orderPk, fetchMode ?? fetchEvent);
  }

  handleNew(BuildContext context, {OrderEventStatus? fetchMode}) {
    navForm(context, null, fetchMode ?? fetchEvent);
  }
}
