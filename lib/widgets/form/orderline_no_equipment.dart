import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';

import '../../blocs/order_form_bloc.dart';
import '../../blocs/orderline_bloc.dart';
import '../../models/orderline/form_data.dart';

final log = Logger('orders.form.orderlines.no_equipment');

class OrderlineFormNoEquipment<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final My24i18n i18n;
  final OrderlineFormData orderlineFormData;

  const OrderlineFormNoEquipment({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.i18n,
    required this.orderlineFormData
  });

  @override
  State<StatefulWidget> createState() => _OrderlineFormNoEquipmentState();
}

class _OrderlineFormNoEquipmentState<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<OrderlineFormNoEquipment> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    locationController.dispose();
    productController.dispose();
    remarksController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Form(key: formKey, child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.widgets.wrapGestureDetector(
            context,
            Text(My24i18n.tr('generic.info_equipment'))
        ),
        TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
            controller: productController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty) {
                return widget.i18n.$trans('validator_equipment');
              }
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widget.widgets.wrapGestureDetector(
            context,
            Text(My24i18n.tr('generic.info_location'))
        ),
        TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
            controller: locationController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widget.widgets.wrapGestureDetector(
            context,
            Text(My24i18n.tr('generic.info_remarks'))
        ),
        TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
            controller: remarksController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widget.widgets.createElevatedButtonColored(
            widget.i18n.$trans('button_add'),
            () { _addOrderLine(context); }
        )
      ],
    ));
  }

  _addListeners() {
    locationController.addListener(_locationListen);
    productController.addListener(_productListen);
    remarksController.addListener(_remarksListen);
  }

  void _locationListen() {
    if (locationController.text.isEmpty) {
      widget.orderlineFormData.location = "";
    } else {
      widget.orderlineFormData.location = locationController.text;
    }
  }

  void _productListen() {
    if (productController.text.isEmpty) {
      widget.orderlineFormData.product = "";
    } else {
      widget.orderlineFormData.product = productController.text;
    }
  }

  void _remarksListen() {
    if (remarksController.text.isEmpty) {
      widget.orderlineFormData.remarks = "";
    } else {
      widget.orderlineFormData.remarks = remarksController.text;
    }
  }

  void _addOrderLine(BuildContext context) {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();

      Orderline orderline = widget.orderlineFormData.toModel();

      widget.formData.orderLines!.add(orderline);

      remarksController.text = '';
      locationController.text = '';
      productController.text = '';

      final bloc = BlocProvider.of<BlocClass>(context);
      bloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      bloc.add(OrderFormEvent(
        status: OrderFormEventStatus.addOrderLine,
        formData: widget.formData,
        orderline: orderline
      ));

      final orderLineBloc = BlocProvider.of<OrderLineBloc>(context);
      orderLineBloc.add(OrderLineEvent(
          status: OrderLineStatus.newFormData,
          order: widget.formData.id
      ));
    } else {
      log.severe("error adding orderline");
      widget.widgets.displayDialog(
          context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}