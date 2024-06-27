import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_orders/common/widgets.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import '../../blocs/order_bloc.dart';
import '../../pages/types.dart';
import '../list.dart';

class UnAssignedListWidget extends OrderListWidget {
  final NavAssignFunction? navAssignFunction;

  UnAssignedListWidget({
    super.key,
    required super.orderList,
    required super.orderPageMetaData,
    required super.fetchEvent,
    required super.searchQuery,
    required super.widgetsIn,
    required super.i18nIn,
    required super.paginationInfo,
    required super.navFormFunction,
    required super.navDetailFunction,
    this.navAssignFunction
  });

  @override
  SliverAppBar getAppBar(BuildContext context) {
    UnassignedOrdersAppBarFactory factory = UnassignedOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo!.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    if (!orderPageMetaData.hasBranches! && orderPageMetaData.submodel == 'planning_user') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getEditButton(context, order.id!),
          const SizedBox(width: 10),
          widgets.createDefaultElevatedButton(
              context,
              i18n.$trans('button_assign'),
              () => _navAssignOrder(context, order.id!)
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widgets.createDefaultElevatedButton(
            context,
            i18n.$trans('button_assign_engineer'),
            () => _showDoAssignDialog(context, order.id!)
        ),
      ],
    );
  }

  _navAssignOrder(BuildContext context, int orderPk) {
    navAssignFunction!(context, orderPk);
  }

  _showDoAssignDialog(BuildContext context, int orderPk) {
    // set up the button
    Widget cancelButton = TextButton(
        child: Text(i18n.$trans('button_cancel', pathOverride: 'utils')),
        onPressed: () => Navigator.of(context).pop(false)
    );
    Widget assignButton = TextButton(
        child: Text(i18n.$trans('button_assign')),
        onPressed: () => Navigator.of(context).pop(true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(i18n.$trans('assign_to_me_header_confirm')),
      content: Text(i18n.$trans('assign_to_me_content_confirm')),
      actions: [
        cancelButton,
        assignButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) {
      if (dialogResult == null) return;

      if (dialogResult) {
        _doAssignOrderEngineer(context, orderPk);
      }
    });
  }

  _doAssignOrderEngineer(BuildContext context, int orderPk) {
    final bloc = BlocProvider.of<OrderBloc>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.assignMe,
        pk: orderPk
    ));
  }
}
