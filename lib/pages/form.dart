import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../blocs/order_form_bloc.dart';
import '../blocs/order_form_states.dart';
import '../widgets/form/error.dart';

final log = Logger('orders.pages.form');

Future sleep1() {
  return Future.delayed(const Duration(seconds: 1), () => "1");
}

abstract class BaseOrderFormPage<OrderFormBloc extends OrderFormBlocBase> extends StatelessWidget {
  final i18n = My24i18n(basePath: "orders");
  final CoreWidgets widgets = CoreWidgets();
  final CoreUtils utils = CoreUtils();
  final OrderFormBloc? bloc; // this bloc is here so we can use a custom bloc in tests
  final int? pk;
  final OrderEventStatus fetchMode;
  final NavListFunction navListFunction;

  BaseOrderFormPage({
    super.key,
    this.pk,
    this.bloc,
    required this.fetchMode,
    required this.navListFunction
  });

  Widget getOrderFormWidget({
    required dynamic formData,
    required OrderPageMetaData orderPageMetaData,
    required OrderEventStatus fetchEvent,
    required CoreWidgets widgets
  });

  Future<OrderPageMetaData?> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    bool? hasBranches = await utils.getHasBranches();
    String? memberPicture = await utils.getMemberPicture();

    return OrderPageMetaData(
        submodel: submodel,
        firstName: await utils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 20,
        hasBranches: hasBranches
    );
  }

  OrderFormBloc _initialCall(BuildContext context) {
    final OrderFormBloc useBloc = bloc == null ? BlocProvider.of<OrderFormBloc>(context) : bloc!;
    if (pk != null) {
      useBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      useBloc.add(OrderFormEvent(
          status: OrderFormEventStatus.fetchDetail,
          pk: pk
      ));
    } else {
      useBloc.add(const OrderFormEvent(
        status: OrderFormEventStatus.newOrder,
      ));
    }

    return useBloc;
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
                create: (context) => _initialCall(context),
                child: BlocConsumer<OrderFormBloc, OrderFormState>(
                    listener: (context, state) {
                      _handleListener(context, state, orderListData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: _getBody(context, state, orderListData!)
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            log.severe("snapshot.hasError ${snapshot.error}");
            return Center(
                child: Text("An error occurred (${snapshot.error})")
            );
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

    if (state is OrderInsertedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_added'));
        navListFunction(context, fetchMode);
      }
    }

    if (state is OrderUpdatedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_updated'));
        navListFunction(context, fetchMode);
      }
    }

    if (state is OrderFormErrorState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans(
            'error_arg', pathOverride: 'generic',
            namedArgs: {'error': "${state.message}"}
        ));
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

    if (state is OrderAcceptedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_accepted'));
        navListFunction(context, fetchMode);
      }
    }

    if (state is OrderRejectedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_rejected'));
        navListFunction(context, fetchMode);
      }
    }

    if (state is OrderLineAddedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_orderline_added'));
    }

    if (state is OrderLineRemovedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_orderline_removed'));
    }

    if (state is InfoLineAddedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_infoline_added'));
    }

    if (state is InfoLineRemovedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_infoline_removed'));
    }

    if (state is DocumentAddedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_document_added'));
    }

    if (state is DocumentRemovedState) {
      widgets.createSnackBar(context, i18n.$trans('list.snackbar_document_removed'));
    }
  }

  Widget? _getBody(context, state, OrderPageMetaData orderPageMetaData) {
    log.info("_getBody state: $state");

    if (state is OrderNewState) {
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

    if (state is OrderFormErrorState) {
      // TODO maybe we want to display the form again but with error messages?
      return OrderFormErrorWidget(
        widgetsIn: widgets,
        i18nIn: i18n,
        error: state.message!,
        orderPageMetaData: orderPageMetaData,
      );
    }

    if (state is OrderLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is OrderFormInitialState) {
      return widgets.loadingNotice();
    }

    // navs
    if (state is OrderInsertedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderUpdatedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderAcceptedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderRejectedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderFormLoadingState) {
      return widgets.loadingNotice();
    }

    return null;
  }
}
