import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_orders/widgets/order/shared.dart';

import '../../common/widgets.dart';
import '../../models/order/models.dart';
import '../../blocs/order_bloc.dart';

class OrderListWidget<BlocClass extends OrderBlocBase> extends BaseSliverListStatelessWidget {
  final OrderPageMetaData orderPageMetaData;
  final List<Order>? orderList;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;
  final TextEditingController searchController = TextEditingController();

  OrderListWidget({
    Key? key,
    required this.orderList,
    required this.orderPageMetaData,
    required this.fetchEvent,
    required this.searchQuery,
    required PaginationInfo paginationInfo,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn
  }) : super(
    key: key,
    paginationInfo: paginationInfo,
    memberPicture: orderPageMetaData.memberPicture,
    widgets: widgetsIn,
    i18n: i18nIn
  ) {
    searchController.text = searchQuery ?? '';
  }

  @override
  Widget getBottomSection(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    return widgets.showPaginationSearchNewSection(
      context,
      paginationInfo,
      searchController,
      () { nextPage(bloc, fetchEvent, paginationInfo!, searchController.text); },
      () { previousPage(bloc, fetchEvent, paginationInfo!, searchController.text); },
      () { doSearch(bloc, fetchEvent, searchController.text); },
      () { handleNew(bloc); },
    );
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    doRefreshCommon(bloc, fetchEvent);
  }

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
  }

  @override
  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList ?? [],
        count: paginationInfo!.count,
        onStretch: doRefresh);
    return factory.createAppBar();
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          Order order = orderList![index];

          return Column(
            children: [
              ListTile(
                title: createOrderListHeader2(order, order.orderDate!),
                subtitle: createOrderListSubtitle2(order),
                onTap: () {
                  _navOrderDetail(context, order.id!);
                } // onTab
              ),
              const SizedBox(height: 4),
              getButtonRow(context, order),
              if (index < orderList!.length - 1) widgets.getMy24Divider(context)
            ],
          );
        },
        childCount: orderList!.length
      )
    );
  }

  navDocuments(BuildContext context, int orderPk) {
    final bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.navDocuments, pk: orderPk));
  }

  showDeleteDialog(BuildContext context, int orderPk) {
    widgets.showDeleteDialogWrapper(
        i18n.$trans('delete_dialog_title'),
        i18n.$trans('delete_dialog_content'),
        () => doDelete(context, orderPk),
        context);
  }

  Widget getEditButton(BuildContext context, int orderPk) {
    return widgets.createEditButton(() => doEdit(context, orderPk));
  }

  Widget getDeleteButton(BuildContext context, int orderPk) {
    return widgets.createDeleteButton(
        () => showDeleteDialog(context, orderPk)
    );
  }

  Widget getDocumentsButton(BuildContext context, int orderPk) {
    return widgets.createElevatedButtonColored(
        i18n.$trans('button_documents'), () => navDocuments(context, orderPk));
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if (!orderPageMetaData.hasBranches! && isPlanning()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getEditButton(context, order.id!),
          const SizedBox(width: 10),
          getDocumentsButton(context, order.id!),
          const SizedBox(width: 10),
          getDeleteButton(context, order.id!)
        ],
      );
    } else {
      row = const Row();
    }

    return row;
  }

  doEdit(BuildContext context, int orderPk) {
    final bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.fetchDetail, pk: orderPk));
  }

  doDelete(BuildContext context, int orderPk) async {
    final bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.delete, pk: orderPk));
  }

  void _navOrderDetail(BuildContext context, int orderPk) {
    final bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.navDetail, pk: orderPk));
  }
}
