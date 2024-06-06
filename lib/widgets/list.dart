import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../common/widgets.dart';
import '../../models/order/models.dart';
import '../../blocs/order_bloc.dart';
import '../pages/types.dart';

class OrderListWidget extends BaseSliverListStatelessWidget {
  final OrderPageMetaData orderPageMetaData;
  final List<Order>? orderList;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;
  final TextEditingController searchController = TextEditingController();
  final NavFormFunction navFormFunction;
  final NavDetailFunction navDetailFunction;

  OrderListWidget({
    Key? key,
    required this.orderList,
    required this.orderPageMetaData,
    required this.fetchEvent,
    required this.searchQuery,
    required PaginationInfo paginationInfo,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn,
    required this.navFormFunction,
    required this.navDetailFunction
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
    return widgets.showPaginationSearchNewSection(
      context,
      paginationInfo,
      searchController,
      nextPage,
      previousPage,
      doSearch,
      handleNew
    );
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(const OrderEvent(status: OrderEventStatus.doRefresh));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
  }

  nextPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
      status: fetchEvent,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  previousPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
      status: fetchEvent,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
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
                title: OrderListHeaderWidget(
                    order: order,
                    date: order.orderDate!
                ),
                subtitle: OrderListSubtitleWidget(order: order),
                onTap: () {
                  navOrderDetail(context, order.id!);
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

  showDeleteDialog(BuildContext context, int orderPk) {
    widgets.showDeleteDialogWrapper(
        i18n.$trans('list.delete_dialog_title'),
        i18n.$trans('list.delete_dialog_content'),
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

  bool isBranchEmployee() {
    return orderPageMetaData.submodel == 'branch_employee_user' || (
        orderPageMetaData.submodel == 'employee_user' && orderPageMetaData.hasBranches!
    );
  }

  bool isCustomerUser() {
    return orderPageMetaData.submodel == 'customer_user' && !orderPageMetaData.hasBranches!;
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if (isPlanning() || isBranchEmployee() || isCustomerUser()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getEditButton(context, order.id!),
          const SizedBox(width: 10),
          getDeleteButton(context, order.id!)
        ],
      );
    } else {
      row = const Row();
    }

    return row;
  }

  handleNew(BuildContext context) {
    navFormFunction(context, null, fetchEvent);
  }

  doEdit(BuildContext context, int orderPk) {
    navFormFunction(context, orderPk, fetchEvent);
  }

  doDelete(BuildContext context, int orderPk) async {
    final bloc = BlocProvider.of<OrderBloc>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.delete,
        pk: orderPk
    ));
  }

  navOrderDetail(BuildContext context, int orderPk) {
    navDetailFunction(context, orderPk);
  }

  navOrderForm(BuildContext context, int? orderPk) {
    navFormFunction(context, orderPk, fetchEvent);
  }
}
