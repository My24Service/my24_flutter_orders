import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_states.dart';
import 'package:my24_flutter_orders/pages/types.dart';
import 'package:my24_flutter_orders/widgets/error.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/widgets/past/empty.dart';
import 'package:my24_flutter_orders/widgets/past/error.dart';
import 'package:my24_flutter_orders/widgets/past/list.dart';
import 'package:my24_flutter_orders/widgets/unaccepted/empty.dart';
import 'package:my24_flutter_orders/widgets/unaccepted/error.dart';
import 'package:my24_flutter_orders/widgets/unaccepted/list.dart';

import '../widgets/empty.dart';
import '../widgets/list.dart';

final log = Logger('orders.pages.list');

abstract class BaseOrderListPage extends StatelessWidget {
  final i18n = My24i18n(basePath: "orders");
  final OrderEventStatus fetchMode;
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();
  final CoreUtils utils = CoreUtils();
  final NavFormFunction navFormFunction;
  final NavDetailFunction navDetailFunction;

  BaseOrderListPage({
    super.key,
    required this.bloc,
    required this.fetchMode,
    required this.navFormFunction,
    required this.navDetailFunction
  });

  Future<Widget?> getDrawerForUserWithSubmodel(
      BuildContext context, String? submodel);

  Future<OrderPageMetaData?> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    bool? hasBranches = await utils.getHasBranches();
    String? memberPicture = await utils.getMemberPicture();
    Widget? drawer = context.mounted ?
      await getDrawerForUserWithSubmodel(context, submodel) : null;

    return OrderPageMetaData(
        drawer: drawer,
        submodel: submodel,
        firstName: await utils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 20,
        hasBranches: hasBranches
    );
  }

  OrderBloc _initialCall() {
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: fetchMode));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    log.info("build");
    return FutureBuilder<OrderPageMetaData?>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                      _handleListener(context, state, orderListData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData!.drawer,
                          body: _getBody(context, state, orderListData)
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            log.severe("snapshot.hasError ${snapshot.error}");
            return Center(
                child: Text("An error occurred (${snapshot.error})"));
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  bool isPlanning(OrderPageMetaData orderListData) {
    return orderListData.submodel == 'planning_user';
  }

  void _handleListener(BuildContext context, state, OrderPageMetaData? orderPageMetaData) async {
    log.info("_handleListener state: $state");

    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

    if (state is OrderErrorSnackbarState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans(
            'error_arg', pathOverride: 'generic',
            namedArgs: {'error': "${state.message}"}
        ));
      }
    }

    if (state is OrderDeletedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_deleted'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(status: fetchMode));
    }
  }

  Widget? _getBody(context, state, OrderPageMetaData orderPageMetaData) {
    log.info("_getBody state: $state");

    if (state is OrderErrorState) {
      switch (fetchMode) {
        case OrderEventStatus.fetchAll: {
          return OrderListErrorWidget(
            widgetsIn: widgets,
            i18nIn: i18n,
            error: state.message!,
            orderPageMetaData: orderPageMetaData,
          );
        }

        case OrderEventStatus.fetchPast: {
          return PastListErrorWidget(
            widgetsIn: widgets,
            i18nIn: i18n,
            error: state.message!,
            orderPageMetaData: orderPageMetaData,
          );
        }

        case OrderEventStatus.fetchUnaccepted: {
          return UnacceptedListErrorWidget(
            widgetsIn: widgets,
            i18nIn: i18n,
            error: state.message!,
            orderPageMetaData: orderPageMetaData,
          );
        }

        default: {
          log.severe("error state, unknown fetch mode: $fetchMode");
          throw "error state, unknown fetch mode: $fetchMode";
        }
      }
    }

    if (state is OrdersLoadedState) {
      if (state.orders!.results!.isEmpty) {
        return OrderListEmptyWidget(
          fetchEvent: fetchMode,
          widgetsIn: widgets,
          i18nIn: i18n,
          navFormFunction: navFormFunction,
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.orders!.count,
          next: state.orders!.next,
          previous: state.orders!.previous,
          currentPage: state.page ?? 1,
          pageSize: orderPageMetaData.pageSize
      );

      return OrderListWidget(
        orderList: state.orders!.results,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        searchQuery: state.query,
        paginationInfo: paginationInfo,
        widgetsIn: widgets,
        i18nIn: i18n,
        navFormFunction: navFormFunction,
        navDetailFunction: navDetailFunction,
      );
    }

    if (state is OrdersUnacceptedLoadedState) {
      if (state.orders!.results!.isEmpty) {
        return UnacceptedListEmptyWidget(
          fetchEvent: fetchMode,
          widgetsIn: widgets,
          i18nIn: i18n,
          navFormFunction: navFormFunction,
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.orders!.count,
          next: state.orders!.next,
          previous: state.orders!.previous,
          currentPage: state.page ?? 1,
          pageSize: orderPageMetaData.pageSize
      );

      return UnacceptedListWidget(
        orderList: state.orders!.results,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        searchQuery: state.query,
        paginationInfo: paginationInfo,
        widgetsIn: widgets,
        i18nIn: i18n,
        navFormFunction: navFormFunction,
        navDetailFunction: navDetailFunction,
      );
    }

    if(state is OrdersPastLoadedState) {
      if (state.orders!.results!.isEmpty) {
        return PastListEmptyWidget(
          fetchEvent: fetchMode,
          widgetsIn: widgets,
          i18nIn: i18n,
          navFormFunction: navFormFunction,
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.orders!.count,
          next: state.orders!.next,
          previous: state.orders!.previous,
          currentPage: state.page ?? 1,
          pageSize: orderPageMetaData.pageSize
      );

      return PastListWidget(
        orderList: state.orders!.results,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        searchQuery: state.query,
        paginationInfo: paginationInfo,
        widgetsIn: widgets,
        i18nIn: i18n,
        navFormFunction: navFormFunction,
        navDetailFunction: navDetailFunction,
      );
    }

    if (state is OrderLoadingState) {
      return widgets.loadingNotice();
    }
    return null;
  }
}
