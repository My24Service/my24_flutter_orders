import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import '../blocs/document_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_states.dart';
import '../widgets/order/form.dart';
import '../widgets/order/list.dart';
import '../widgets/order/error.dart';
import '../widgets/order/empty.dart';
import '../models/order/models.dart';
import '../widgets/order/past/empty.dart';
import '../widgets/order/past/error.dart';
import '../widgets/order/past/list.dart';
import '../widgets/order/unaccepted/empty.dart';
import '../widgets/order/unaccepted/error.dart';
import '../widgets/order/unaccepted/list.dart';
import 'documents.dart';

final log = Logger('orders.list');

String? initialLoadMode;
int? loadId;

class OrderListPage<
  BlocClass extends OrderBlocBase,
  FormWidget extends BaseOrderFormWidget
> extends StatelessWidget {
  final i18n = My24i18n(basePath: "orders");
  final OrderEventStatus fetchMode;
  final BlocClass bloc;
  final CoreWidgets widgets = CoreWidgets();
  final CoreUtils utils = CoreUtils();

  OrderListPage({
    Key? key,
    required this.bloc,
    String? initialMode,
    int? pk,
    required this.fetchMode,
  });

  Future<Widget?> getDrawerForUserWithSubmodel(
      BuildContext context, String? submodel) async {
    throw UnimplementedError("This should be implemented");
  }

  Future<OrderPageMetaData?> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    bool? hasBranches = await utils.getHasBranches();
    String? memberPicture = await utils.getMemberPicture();

    if (context.mounted) {
      return OrderPageMetaData(
          drawer: await getDrawerForUserWithSubmodel(context, submodel),
          submodel: submodel,
          firstName: await utils.getFirstName(),
          memberPicture: memberPicture,
          pageSize: 20,
          hasBranches: hasBranches
      );
    }

    return null;
  }

  BlocClass _initialCall() {
    if (initialLoadMode == null) {
      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: fetchMode));
    } else if (initialLoadMode == 'form') {
      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(const OrderEvent(
        status: OrderEventStatus.NEW,
      ));
    }

    return bloc;
  }

  FormWidget getOrderFormWidget<FormData>(
  {
    required FormData formData,
    required OrderPageMetaData orderPageMetaData,
    required OrderEventStatus fetchEvent,
    required CoreWidgets widgets
  }
  ) {
    throw UnimplementedError("get order form needs to be implemented");
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

  bool _isPlanning(OrderPageMetaData orderListData) {
    return orderListData.submodel == 'planning_user';
  }

  void _handleListener(BuildContext context, state, OrderPageMetaData? orderPageMetaData) async {
    final BlocClass bloc = BlocProvider.of<BlocClass>(context);

    if (state is OrderInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      // ask if we want to add documents after insert
      await showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(i18n.$trans('dialog_add_documents_title')),
              content: Text(i18n.$trans('dialog_add_documents_content')),
              actions: <Widget>[
                TextButton(
                  child: Text(i18n.$trans('dialog_add_documents_button_yes')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (context) => OrderDocumentsPage(
                              orderId: state.order!.id,
                              bloc: OrderDocumentBloc(),
                            )
                        )
                    );
                  },
                ),
                TextButton(
                  child: Text(i18n.$trans('dialog_add_documents_button_no')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_isPlanning(orderPageMetaData!) && !orderPageMetaData.hasBranches!) {
                      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
                      bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_ALL));
                    } else {
                      final BlocClass bloc = BlocProvider.of<BlocClass>(context);
                      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
                      bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_UNACCEPTED));
                    }
                  },
                ),
              ],
            );
          }
      );
    }

    if (state is OrderUpdatedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('snackbar_updated'));
      }

      if (_isPlanning(orderPageMetaData!)) {
        bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
        bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_ALL));
      } else {
        if (context.mounted) {
          final BlocClass bloc = BlocProvider.of<BlocClass>(context);
          bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
          bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_UNACCEPTED));
        }
      }
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
        widgets.createSnackBar(context, i18n.$trans('snackbar_deleted'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    if (state is OrderAcceptedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('snackbar_accepted'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    if (state is OrderRejectedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('snackbar_rejected'));
      }

      bloc.add(const OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(const OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    // if (state is AssignedMeState) {
    //   createSnackBar(context, i18n.$trans('snackbar_assigned'));
    //
    //   bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    //   bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    // }
  }

  Widget getBody(context, state, OrderPageMetaData orderPageMetaData) {
    if (state is OrderErrorState) {
      switch (fetchMode) {
        case OrderEventStatus.FETCH_ALL: {
          return OrderListErrorWidget(
            widgetsIn: widgets,
            i18nIn: i18n,
            error: state.message!,
            orderPageMetaData: orderPageMetaData,
          );
        }

        case OrderEventStatus.FETCH_PAST: {
          return PastListErrorWidget(
            widgetsIn: widgets,
            i18nIn: i18n,
            error: state.message!,
            orderPageMetaData: orderPageMetaData,
          );
        }

        case OrderEventStatus.FETCH_UNACCEPTED: {
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
