import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';

class OrderlineFormNoEquipment<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final OrderlineFormData orderlineFormData;
  final My24i18n i18n;

  const OrderlineFormNoEquipment({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.orderlineFormData,
    required this.i18n,
  });

  @override
  State<StatefulWidget> createState() => _OrderlineFormNoEquipmentState();
}

class _OrderlineFormNoEquipmentState<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<OrderlineFormNoEquipment> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: widget.formData
    ));
  }

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
            Text(widget.i18n.$trans('generic.info_equipment'))
        ),
        TextFormField(
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
            Text(widget.i18n.$trans('generic.info_remarks'))
        ),
        TextFormField(
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

  void _addOrderLine(BuildContext context) {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();

      Orderline orderline = widget.orderlineFormData.toModel();

      widget.formData.orderLines!.add(orderline);

      remarksController.text = '';
      locationController.text = '';
      productController.text = '';
      widget.orderlineFormData.reset(widget.formData.id);

      updateFormData(context);
    } else {
      widget.widgets.displayDialog(
          context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}