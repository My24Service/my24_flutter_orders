import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/widgets/form/orderline_no_equipment.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import 'orderline_equipment.dart';

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
  BlocClass extends OrderBlocBase,
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

  updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: formData
    ));
  }

  _delete(BuildContext context, Orderline orderLine) {
    if (orderLine.id != null && !formData.deletedOrderLines!.contains(orderLine)) {
      formData.deletedOrderLines!.add(orderLine);
    }
    formData.orderLines!.removeAt(formData.orderLines!.indexOf(orderLine));
    updateFormData(context);
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
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final OrderlineFormData orderlineFormData = OrderlineFormData.createEmpty(null);
  final bool hasBranches;
  final My24i18n i18n;

  OrderlineForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.hasBranches,
    required this.i18n
  });

  @override
  State<StatefulWidget> createState() => _OrderlineFormState();
}

class _OrderlineFormState<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<OrderlineForm> {
  @override
  void initState() {
    widget.orderlineFormData.order = widget.formData.id;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasBranches || widget.formData.customerBranchId != null) {
      return OrderlineFormEquipment(
        formData: widget.formData,
        widgets: widget.widgets,
        isPlanning: widget.isPlanning,
        orderlineFormData: widget.orderlineFormData,
        i18n: widget.i18n,
      );
    }

    return OrderlineFormNoEquipment(
      formData: widget.formData,
      widgets: widget.widgets,
      isPlanning: widget.isPlanning,
      orderlineFormData: widget.orderlineFormData,
      i18n: widget.i18n,
    );
  }
}

