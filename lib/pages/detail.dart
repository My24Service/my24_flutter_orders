import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_states.dart';
import 'package:my24_flutter_orders/widgets/detail.dart';
import 'package:my24_flutter_orders/widgets/error.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

final log = Logger('orders.pages.detail');

abstract class BaseOrderDetailPage extends StatelessWidget {
  final int? orderId;
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();
  final My24i18n i18nIn = My24i18n(basePath: "orders");
  final CoreUtils utils = CoreUtils();

  BaseOrderDetailPage({
    Key? key,
    required this.orderId,
    required this.bloc,
  }) : super(key: key);

  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel);

  OrderBloc _initialBlocCall() {
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.fetchDetailView, pk: orderId));

    return bloc;
  }

  Future<OrderPageMetaData?> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    bool? hasBranches = await utils.getHasBranches();
    String? memberPicture = await utils.getMemberPicture();
    Widget? drawer = context.mounted ? await getDrawerForUserWithSubmodel(context, submodel) : null;

    if (context.mounted) {
      return OrderPageMetaData(
          drawer: drawer,
          submodel: submodel,
          firstName: await utils.getFirstName(),
          memberPicture: memberPicture,
          pageSize: 20,
          hasBranches: hasBranches
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    log.info("build");
    return FutureBuilder<OrderPageMetaData?>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;

            return BlocProvider<OrderBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: _getBody(context, state, orderListData)
                          )
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

  Widget _getBody(context, state, OrderPageMetaData? orderPageMetaData) {
    if (state is OrderErrorState) {
      return OrderListErrorWidget(
        error: state.message!,
        orderPageMetaData: orderPageMetaData!,
        widgetsIn: widgets,
        i18nIn: i18nIn,
      );
    }

    if (state is OrderLoadedViewState) {
      return OrderDetailWidget(
        order: state.order,
        orderPageMetaData: orderPageMetaData!,
        widgetsIn: widgets,
      );
    }

    return widgets.loadingNotice();
  }
}
