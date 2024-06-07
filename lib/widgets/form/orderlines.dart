import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/widgets/form/orderline_no_equipment.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import '../../blocs/order_form_bloc.dart';
import '../../blocs/orderline_bloc.dart';
import '../../blocs/orderline_states.dart';
import 'orderline_equipment.dart';

final log = Logger('orders.form.orderlines');

class OrderlinesWidget<
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final My24i18n i18n = My24i18n(basePath: "orders.form.orderlines");
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final bool hasBranches;

  OrderlinesWidget({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.hasBranches
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            )
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            widgets.createHeader(i18n.$trans('header')),
            OrderlineList(
            widgets: widgets,
            formData: formData,
            i18n: i18n,
            ),
            widgets.createHeader(i18n.$trans('header_new')),
            OrderlineForm(
              formData: formData,
              widgets: widgets,
              isPlanning: isPlanning,
              hasBranches: hasBranches,
              i18n: i18n,
            ),
          ],
        ),
      );
  }
}

class OrderlineList<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final CoreWidgets widgets;
  final FormDataClass formData;
  final CoreUtils utils = CoreUtils();
  final My24i18n i18n;

  OrderlineList({
    super.key,
    required this.widgets,
    required this.formData,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    if (formData.orderLines!.isEmpty) {
      return Column(
        children: [
          Text(i18n.$trans("no_items"))
        ],
      );
    }

    return widgets.buildItemsSection(
        context,
        "",
        formData.orderLines,
        (item) {
          String equipmentLocationTitle = "${My24i18n.tr('generic.info_equipment')} / ${My24i18n.tr('generic.info_location')}";
          String equipmentLocationValue = "${item.product} / ${item.location}";
          return <Widget>[
            ...widgets.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
            ...widgets.buildItemListKeyValueList(My24i18n.tr('generic.info_remarks'), item.remarks)
          ];
        },
        (Orderline item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widgets.createDeleteButton(
                  () { _showDeleteDialog(context, item); }
                )
              ],
            )
          ];
        }
    );
  }

  _delete(BuildContext context, Orderline orderLine) {
    final bloc = BlocProvider.of<BlocClass>(context);
    bloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
    bloc.add(OrderFormEvent(
      status: OrderFormEventStatus.removeOrderline,
      formData: formData,
      orderline: orderLine
    ));
  }

  _showDeleteDialog(BuildContext context, Orderline orderLine) {
    widgets.showDeleteDialogWrapper(
        i18n.$trans('delete_dialog_title'),
        i18n.$trans('delete_dialog_content'),
        () => _delete(context, orderLine),
        context
    );
  }
}

class OrderlineForm<
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final bool hasBranches;
  final My24i18n i18n;

  const OrderlineForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.hasBranches,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    log.info("build form");

    return BlocProvider(
        create: (context) =>  _initialCall(context),
        child: BlocConsumer<OrderLineBloc, OrderLineBaseState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return _getBody(context, state);
          }
        )
    );
  }

  OrderLineBloc _initialCall(BuildContext context) {
    final bloc = OrderLineBloc();
    bloc.add(OrderLineEvent(
      status: OrderLineStatus.newFormData,
      order: formData.id
    ));

    return bloc;
  }

  _handleListeners(context, state) {
    log.info("form _handleListeners state: $state");

    if (state is OrderLineErrorSnackbarState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans(
            'error_arg', pathOverride: 'generic',
            namedArgs: {'error': "${state.message}"}
        ));
      }
    }

    if (state is OrderLineNewEquipmentCreatedState) {
      widgets.createSnackBar(context, i18n.$trans('equipment_created'));
    }

    if (state is OrderLineNewLocationCreatedState) {
      widgets.createSnackBar(context, i18n.$trans('location_created'));
    }
  }

  Widget _getBody(context, state) {
    log.info("form _getBody state: $state");

    if (state is OrderLineLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is OrderLineNewFormDataState || state is OrderLineLoadedState ||
        state is OrderLineNewEquipmentCreatedState || state is OrderLineNewLocationCreatedState
    ) {
      if (hasBranches || formData.customerBranchId != null) {
        return OrderlineFormEquipment(
          formData: formData,
          widgets: widgets,
          isPlanning: isPlanning,
          orderlineFormData: state.formData,
        );
      }

      return OrderlineFormNoEquipment(
        formData: formData,
        widgets: widgets,
        isPlanning: isPlanning,
        i18n: i18n,
        orderlineFormData: state.formData,
      );
    }

    return widgets.loadingNotice();
  }
}

