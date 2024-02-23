import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'documents.dart';
import 'infolines.dart';
import 'orderlines.dart';

abstract class BaseOrderFormWidget<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends BaseSliverPlainStatelessWidget{
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "orders");
  final FormDataClass? formData;
  final OrderEventStatus fetchEvent;
  final OrderPageMetaData orderPageMetaData;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  BaseOrderFormWidget({
    Key? key,
    required this.orderPageMetaData,
    required this.formData,
    required this.fetchEvent,
    required this.widgetsIn,
  }) : super(
      key: key,
      mainMemberPicture: orderPageMetaData.memberPicture,
      widgets: widgetsIn,
      i18n: My24i18n(basePath: "orders")
  );

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ? i18nIn.$trans('form.app_bar_title_insert') : i18nIn.$trans('form.app_bar_title_update');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    widgetsIn.createHeader(i18nIn.$trans('header_order_details')),
                    _createOrderForm(context),
                    const SizedBox(height: 20),
                    OrderlinesWidget(
                      formData: formData!,
                      widgets: widgets,
                      isPlanning: isPlanning(),
                      hasBranches: orderPageMetaData.hasBranches!,
                    ),
                    const SizedBox(height: 20),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      InfolinesWidget(
                        formData: formData!,
                        widgets: widgets,
                      ),
                    const SizedBox(height: 20),
                    DocumentsWidget(
                        formData: formData!,
                        widgets: widgetsIn,
                        orderId: formData!.id,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (!isPlanning())
                      Text(
                        i18nIn.$trans('form.notification_order_date'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.red
                        ),
                      ),
                    widgetsIn.createSubmitSection(_getButtons(context) as Row)
                  ],
                )
            )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    if (!orderPageMetaData.hasBranches! && isPlanning() && formData!.id != null && !formData!.customerOrderAccepted!) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  widgetsIn.createDefaultElevatedButton(
                      context,
                      i18nIn.$trans('form.button_accept'),
                      () => _doAccept(context)
                  ),
                  const SizedBox(width: 10),
                  widgetsIn.createElevatedButtonColored(
                      i18nIn.$trans('form.button_reject'),
                      () => _doReject(context),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red
                  )
                ],
              ),
              widgetsIn.createElevatedButtonColored(
                  i18nIn.$trans('form.button_nav_orders'),
                      () => _fetchOrders(context)
              ),
            ],
          )
        ],
      );
    }

    return _createSubmitButton(context);
  }

  Widget _createSubmitButton(BuildContext context) {
    return Row(
        children: [
          const Spacer(),
          widgetsIn.createCancelButton(() => _fetchOrders(context)),
          const SizedBox(width: 10),
          widgetsIn.createSubmitButton(context, () => _doSubmit(context)),
          const Spacer(),
        ]
    );
  }

  _fetchOrders(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  void _doAccept(BuildContext context) {
    final BlocClass bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.accept, pk: formData!.id));
  }

  void _doReject(BuildContext context) {
    final BlocClass bloc = BlocProvider.of<BlocClass>(context);

    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(status: OrderEventStatus.reject, pk: formData!.id));
  }

  updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: formData
    ));
  }

  _selectStartDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.startDate = pickedDate;
      if (!formData!.changedEndDate!) {
        formData!.endDate = pickedDate;
      }
      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  _selectStartTime(BuildContext context) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 6, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime
    );

    if (pickedTime != null) {
      final DateTime startTime = DateTime(
          formData!.startDate!.year,
          formData!.startDate!.month,
          formData!.startDate!.day,
          pickedTime.hour,
          pickedTime.minute,
      );
      formData!.startTime = startTime;
      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  _selectEndDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.endDate = pickedDate;
      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  _selectEndTime(BuildContext context) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 4, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime
    );

    if (pickedTime != null) {
      final DateTime endTime = DateTime(
        formData!.startDate!.year,
        formData!.startDate!.month,
        formData!.startDate!.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      formData!.endTime = endTime;
      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  TableRow getFirstElement(BuildContext context) {
    // var firstElement;
    //
    // // only show the typeahead when creating a new order
    // if (!orderPageMetaData.hasBranches!) {
    //   if (isPlanning() && formData!.id == null) {
    //     firstElement = _getCustomerTypeAhead(context);
    //   } else {
    //     firstElement = _getCustomerNameTextField();
    //   }
    // } else {
    //   if (isPlanning() && formData!.id == null) {
    //     firstElement = _getBranchTypeAhead(context);
    //   } else {
    //     firstElement = _getBranchNameTextField();
    //   }
    // }
    // return TableRow(
    //     children: [
    //       SizedBox(height: 1),
    //       SizedBox(height: 1),
    //     ]
    // );
    throw UnimplementedError("getFirstElement should be implemented");
  }

  Widget _createOrderForm(BuildContext context) {
    return Form(key: formKey, child: Table(
        children: [
          getFirstElement(context),
          if (!orderPageMetaData.hasBranches!)
            TableRow(
                children: [
                  widgetsIn.wrapGestureDetector(
                      context,
                      Padding(padding: const EdgeInsets.only(top: 16),
                        child: Text(
                            i18nIn.$trans('info_customer_id', pathOverride: 'generic'),
                            style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                  ),
                  TextFormField(
                      readOnly: true,
                      controller: formData!.orderCustomerIdController,
                      validator: (value) {
                        return null;
                      }
                  ),
                ]
            ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          My24i18n.tr('generic.info_name'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_name', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_address', pathOverride: 'generic'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderAddressController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_address', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_postal', pathOverride: 'generic'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderPostalController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_postal', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_city', pathOverride: 'generic'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderCityController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_city', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_country_code', pathOverride: 'generic'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                DropdownButtonFormField<String>(
                  value: formData!.orderCountryCode,
                  items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    formData!.orderCountryCode = newValue;
                    updateFormData(context);
                  },
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_contact', pathOverride: 'generic'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      controller: formData!.orderContactController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
          const TableRow(
              children: [
                Divider(),
                SizedBox(height: 10,)
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_start_date'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                widgetsIn.createElevatedButtonColored(
                    coreUtils.formatDateDDMMYYYY(formData!.startDate!),
                    () => _selectStartDate(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_start_time'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                widgetsIn.createElevatedButtonColored(
                    formData!.startTime != null ? coreUtils.timeNoSeconds(coreUtils.formatTime(formData!.startTime!.toLocal())) : '',
                    () => _selectStartTime(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_end_date'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                widgetsIn.createElevatedButtonColored(
                    coreUtils.formatDateDDMMYYYY(formData!.endDate!),
                    () => _selectEndDate(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_end_time'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                widgetsIn.createElevatedButtonColored(
                    formData!.endTime != null ? coreUtils.timeNoSeconds(coreUtils.formatTime(formData!.endTime!.toLocal())) : '',
                    () => _selectEndTime(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_order_type'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                DropdownButtonFormField<String>(
                  value: formData!.orderType,
                  items: formData!.orderTypes == null ? [] : formData!.orderTypes!.orderTypes!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != formData!.orderType) {
                      formData!.orderType = newValue;
                      updateFormData(context);

                    }
                  },
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_order_reference'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderReferenceController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_order_email'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderEmailController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_order_mobile'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderMobileController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_order_tel'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                TextFormField(
                    controller: formData!.orderTelController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(
                    context,
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          i18nIn.$trans('info_order_customer_remarks'),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                    )
                ),
                SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      controller: formData!.customerRemarksController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
        ]
    ));
  }

  Future<void> _doSubmit(BuildContext context) async {
    if (this.formKey.currentState!.validate()) {
      if (!formData!.isValid()) {
        if (formData!.orderType == null) {
          widgetsIn.displayDialog(context,
              i18nIn.$trans('form.validator_ordertype_dialog_title'),
              i18nIn.$trans('form.validator_ordertype_dialog_content')
          );

          return;
        }
      }

      this.formKey.currentState!.save();

      final bloc = BlocProvider.of<BlocClass>(context);
      if (formData!.id != null) {
        Order updatedOrder = formData!.toModel();
        bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
        bloc.add(OrderEvent(
          pk: updatedOrder.id,
          status: OrderEventStatus.update,
          order: updatedOrder,
          orderLines: formData!.orderLines,
          infoLines: formData!.infoLines,
          documents: formData!.documents,
          deletedOrderLines: formData!.deletedOrderLines!,
          deletedInfoLines: formData!.deletedInfoLines!,
          deletedDocuments: formData!.deletedDocuments!,
          equipmentLocationUpdates: formData!.equipmentLocationUpdates
        ));
      } else {
        if (!orderPageMetaData.hasBranches! && orderPageMetaData.submodel == 'planning_user') {
          formData!.customerOrderAccepted = true;
        }
        Order newOrder = formData!.toModel();
        bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
        bloc.add(OrderEvent(
          status: OrderEventStatus.insert,
          order: newOrder,
          orderLines: formData!.orderLines,
          infoLines: formData!.infoLines,
          documents: formData!.documents,
          equipmentLocationUpdates: formData!.equipmentLocationUpdates
        ));
      }
    }
  }
}
