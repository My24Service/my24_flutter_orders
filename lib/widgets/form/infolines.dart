import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/infoline/models.dart';

class InfolinesWidget<
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final My24i18n i18n = My24i18n(basePath: "orders.form.infolines");
  final FormDataClass formData;
  final CoreWidgets widgets;

  InfolinesWidget({
    super.key,
    required this.formData,
    required this.widgets,
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
          InfolineList(
            widgets: widgets,
            formData: formData,
            i18n: i18n,
          ),
          widgets.createHeader(i18n.$trans('header_new')),
          InfolineForm(
            formData: formData,
            widgets: widgets,
            i18n: i18n,
          ),
        ],
      ),
    );
  }
}

class InfolineList<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final CoreWidgets widgets;
  final FormDataClass formData;
  final CoreUtils utils = CoreUtils();
  final My24i18n i18n;

  InfolineList({
    super.key,
    required this.widgets,
    required this.formData,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    if (formData.infoLines!.isEmpty) {
      return Column(
        children: [
          Text(i18n.$trans("no_items"))
        ],
      );
    }

    return widgets.buildItemsSection(
        context,
        "",
        formData.infoLines,
        (Infoline item) {
          return widgets.buildItemListKeyValueList(
              i18n.$trans('info_infoline'),
              item.info
          );
        },
        (Infoline item) {
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

  _delete(BuildContext context, Infoline infoline) {
    if (infoline.id != null && !formData.deletedInfoLines!.contains(infoline)) {
      formData.deletedInfoLines!.add(infoline);
    }
    formData.infoLines!.removeAt(formData.infoLines!.indexOf(infoline));
    updateFormData(context);
  }

  _showDeleteDialog(BuildContext context, Infoline infoline) {
    widgets.showDeleteDialogWrapper(
        i18n.$trans('delete_dialog_title'),
        i18n.$trans('delete_dialog_content'),
        () => _delete(context, infoline),
        context
    );
  }
}

class InfolineForm<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;

  const InfolineForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n
  });

  @override
  State<StatefulWidget> createState() => _InfolineFormState();
}

class _InfolineFormState<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<InfolineForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController infoController = TextEditingController();

  void _infoListen() {
    if (infoController.text.isEmpty) {
      widget.formData.infolineFormData!.info = "";
    } else {
      widget.formData.infolineFormData!.info = infoController.text;
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
  void initState() {
    _infoListen();
    widget.formData.infolineFormData!.order = widget.formData.id;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    infoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.widgets.wrapGestureDetector(
                context,
                Text(widget.i18n.$trans('info_infoline'))
            ),
            TextFormField(
                controller: infoController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return widget.i18n.$trans('validator_infoline');
                  }

                  return null;
                }
            ),
            const SizedBox(
              height: 10.0,
            ),
            widget.widgets.createElevatedButtonColored(
                widget.i18n.$trans('button_add'),
                () { _addInfoLine(context); }
            )
          ],
        )
    );
  }

  void _addInfoLine(BuildContext context) {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();

      Infoline infoline = widget.formData.infolineFormData!.toModel();

      widget.formData.infoLines!.add(infoline);

      // reset fields
      infoController.text = '';
      widget.formData.infolineFormData!.reset(widget.formData.id);

      updateFormData(context);
      widget.widgets.createSnackBar(context, widget.i18n.$trans('snackbar_added'));
    } else {
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}
