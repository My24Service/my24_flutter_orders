import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_states.dart';
import 'package:my24_flutter_orders/widgets/list.dart';
import 'package:my24_flutter_orders/widgets/error.dart';
import 'package:my24_flutter_orders/widgets/empty.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/widgets/past/empty.dart';
import 'package:my24_flutter_orders/widgets/past/error.dart';
import 'package:my24_flutter_orders/widgets/past/list.dart';
import 'package:my24_flutter_orders/widgets/unaccepted/empty.dart';
import 'package:my24_flutter_orders/widgets/unaccepted/error.dart';
import 'package:my24_flutter_orders/widgets/unaccepted/list.dart';

final log = Logger('orders.list');

String? initialLoadMode;
int? loadId;

abstract class BaseOrderListPage<BlocClass extends OrderBlocBase> extends StatelessWidget {
  final i18n = My24i18n(basePath: "orders");
  final OrderEventStatus fetchMode;
  final BlocClass bloc;
  final CoreWidgets widgets = CoreWidgets();
  final CoreUtils utils = CoreUtils();

  BaseOrderListPage({
    super.key,
    required this.bloc,
    String? initialMode,
    int? pk,
    required this.fetchMode,
  }) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  Future<Widget?> getDrawerForUserWithSubmodel(
      BuildContext context, String? submodel);

  Widget getOrderFormWidget({
        required dynamic formData,
        required OrderPageMetaData orderPageMetaData,
        required OrderEventStatus fetchEvent,
        required CoreWidgets widgets
  });

  void navDetail(BuildContext context, int orderPk, BlocClass bloc);

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

  BlocClass _initialCall() {
    if (initialLoadMode == null) {
      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(status: fetchMode));
    } else if (initialLoadMode == 'form') {
      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(
          status: OrderEventStatus.fetchDetail,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(const OrderEvent(
        status: OrderEventStatus.newOrder,
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderPageMetaData?>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(),
                child: BlocConsumer<BlocClass, OrderState>(
                    listener: (context, state) {
                      _handleListener(context, state, orderListData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData!.drawer,
                          body: getBody(context, state, orderListData)
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
    final BlocClass bloc = BlocProvider.of<BlocClass>(context);

    if (state is OrderInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_added'));

      if (!orderPageMetaData!.hasBranches!) {
        bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
        bloc.add(const OrderEvent(status: OrderEventStatus.fetchAll));
      } else {
        bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
        bloc.add(const OrderEvent(status: OrderEventStatus.fetchUnaccepted));
      }
    }

    if (state is OrderNavDetailState) {
      if (context.mounted) {
        navDetail(context, state.orderPk, bloc);
      }
    }

    if (state is OrderUpdatedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_updated'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(status: fetchMode));
    }

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

    if (state is OrderAcceptedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_accepted'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(status: fetchMode));
    }

    if (state is OrderRejectedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_rejected'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(status: fetchMode));
    }
  }

  Widget getBody(context, state, OrderPageMetaData orderPageMetaData) {
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
      );
    }

    if (state is OrdersUnacceptedLoadedState) {
      if (state.orders!.results!.isEmpty) {
        return UnacceptedListEmptyWidget(
          fetchEvent: fetchMode,
          widgetsIn: widgets,
          i18nIn: i18n,
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
      );
    }

    if(state is OrdersPastLoadedState) {
      if (state.orders!.results!.isEmpty) {
        return PastListEmptyWidget(
          fetchEvent: fetchMode,
          widgetsIn: widgets,
          i18nIn: i18n,
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
      );
    }

    if (state is OrderNewState) {
      return getOrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        widgets: widgets,
      );
    }

    if (state is OrderNewEquipmentCreatedState) {
      return getOrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        widgets: widgets,
      );
    }

    if (state is OrderNewLocationCreatedState) {
      return getOrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        widgets: widgets,
      );
    }

    if (state is OrderLoadedState) {
      return getOrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData,
        fetchEvent: fetchMode,
        widgets: widgets,
      );
    }

    return widgets.loadingNotice();
  }
}
