import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../blocs/order_bloc.dart';
import '../blocs/order_states.dart';
import '../widgets/order/detail.dart';
import '../widgets/order/error.dart';
import '../models/order/models.dart';

abstract class BaseOrderDetailPage<BlocClass extends OrderBlocBase> extends StatelessWidget {
  final int? orderId;
  final BlocClass bloc;
  final CoreWidgets widgets = CoreWidgets();
  final My24i18n i18nIn = My24i18n(basePath: "orders");
  final CoreUtils utils = CoreUtils();

  BaseOrderDetailPage({
    Key? key,
    required this.orderId,
    required this.bloc,
  }) : super(key: key);

  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel);

  BlocClass _initialBlocCall() {
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
    return FutureBuilder<OrderPageMetaData?>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;

            return BlocProvider<BlocClass>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<BlocClass, OrderState>(
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
