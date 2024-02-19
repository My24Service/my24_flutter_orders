import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/location/api.dart';

import '../../models/order/form_data.dart';
import '../../blocs/order_bloc.dart';
import '../../models/order/models.dart';
import '../../models/infoline/models.dart';
import '../../models/orderline/models.dart';

abstract class BaseOrderFormWidget<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends BaseSliverPlainStatelessWidget{
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "orders");
  final FormDataClass? formData;
  final OrderEventStatus fetchEvent;
  final OrderPageMetaData orderPageMetaData;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  final EquipmentApi equipmentApi = EquipmentApi();
  final EquipmentLocationApi equipmentLocationApi = EquipmentLocationApi();

  final FocusNode equipmentCreateFocusNode = FocusNode();
  final FocusNode equipmentLocationCreateFocusNode = FocusNode();

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
                    const Divider(),
                    widgetsIn.createHeader(i18nIn.$trans('header_orderline_form')),
                    _buildOrderlineForm(context),
                    _buildOrderlineSection(context),
                    const Divider(),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      widgetsIn.createHeader(i18nIn.$trans('header_infoline_form')),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      _buildInfolineForm(context),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      _buildInfolineSection(context),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      const Divider(),
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

  _createSelectEquipment(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);

    formData!.isCreatingEquipment = true;
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: formData
    ));

    bloc.add(OrderEvent(
        status: OrderEventStatus.createSelectEquipment,
        formData: formData
    ));
  }

  _createSelectEquipmentLocation(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);

    formData!.isCreatingLocation = true;
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: formData
    ));

    bloc.add(OrderEvent(
        status: OrderEventStatus.createSelectEquipmentLocation,
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
    print("HAS BRANCHES? ${!orderPageMetaData.hasBranches!}");
    return Form(key: _formKeys[0], child: Table(
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

  Widget _buildOrderlineForm(BuildContext context) {
    if (orderPageMetaData.hasBranches! || formData!.customerBranchId != null) {
      return _buildOrderlineFormEquipment(context);
    }

    return _buildOrderlineFormNoBranch(context);
  }

  Widget _getLocationsPart(BuildContext context) {
    if ((isPlanning() && formData!.quickCreateSettings!.equipmentLocationPlanningQuickCreate) ||
        (!isPlanning() && formData!.quickCreateSettings!.equipmentLocationQuickCreate)) {
      return Column(
        children: [
          TypeAheadFormField<EquipmentLocationTypeAheadModel>(
            minCharsForSuggestions: 2,
            textFieldConfiguration: TextFieldConfiguration(
                controller: formData!.orderlineFormData!.typeAheadControllerEquipmentLocation,
                decoration: InputDecoration(
                    labelText:
                    i18nIn.$trans('form.typeahead_label_search_location')
                )
            ),
            suggestionsCallback: (String pattern) async {
              return await equipmentLocationApi.locationTypeAhead(pattern, formData!.branch);
            },
            itemBuilder: (context, suggestion) {
              String text = suggestion.identifier != null && suggestion.identifier != '' ?
              '${suggestion.name} (${suggestion.identifier})' :
              '${suggestion.name}';
              return ListTile(
                title: Text(text),
              );
            },
            noItemsFoundBuilder: (context) {
              return Expanded(
                  child: Column(
                    children: [
                      Text(i18nIn.$trans('form.location_not_found'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey
                          )
                      ),
                      TextButton(
                        child: Text(
                            i18nIn.$trans('form.create_new_location'),
                            style: const TextStyle(
                              fontSize: 12,
                            )
                        ),
                        onPressed: () {
                          // create new location
                          FocusScope.of(context).requestFocus(equipmentLocationCreateFocusNode);
                          _createSelectEquipmentLocation(context);
                        },
                      )
                    ]
                )
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (EquipmentLocationTypeAheadModel suggestion) {
              formData!.orderlineFormData!.equipmentLocation = suggestion.id;
              formData!.orderlineFormData!.locationController!.text = suggestion.name!;
              updateFormData(context);
            },
            validator: (value) {
              return null;
            },
          ),
          widgetsIn.wrapGestureDetector(context, const SizedBox(
            height: 10.0,
          )),

          Visibility(
              visible: formData!.isCreatingLocation!,
              child: Text(
                i18nIn.$trans('form.adding_location'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.red
                ),
              )
          ),
          Visibility(
              visible: !formData!.isCreatingLocation!,
              child:
              SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 290,
                        child: TextFormField(
                          controller: formData!.orderlineFormData!.locationController,
                          keyboardType: TextInputType.text,
                          focusNode: equipmentLocationCreateFocusNode,
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return i18nIn.$trans('form.validator_location');
                            }
                            return null;
                          }
                        )
                      ),
                      const SizedBox(width: 10),
                      Visibility(
                        visible: formData!.orderlineFormData!.equipmentLocation != null,
                        child: const Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 24.0,
                        ),
                      )
                    ],
                  )
              )
          ),

        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: "${formData!.orderlineFormData!.equipmentLocation}",
      items: formData!.locations == null
          ? []
          : formData!.locations!.map((EquipmentLocation location) {
        return DropdownMenuItem<String>(
          value: "${location.id}",
          child: Text(location.name!),
        );
      }).toList(),
      onChanged: (String? locationId) {
        formData!.orderlineFormData!.equipmentLocation = int.parse(locationId!);
        EquipmentLocation location = formData!.locations!.firstWhere(
                (location) => location.id == formData!.orderlineFormData!.equipmentLocation);
        formData!.orderlineFormData!.locationController!.text = location.name!;
        updateFormData(context);
      }
    );
  }

  Widget _buildOrderlineFormEquipment(BuildContext context) {
    return Form(key: _formKeys[1], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_equipment', pathOverride: 'generic'))),
        TypeAheadFormField<EquipmentTypeAheadModel>(
          minCharsForSuggestions: 2,
          textFieldConfiguration: TextFieldConfiguration(
              controller: formData!.orderlineFormData!.typeAheadControllerEquipment,
              decoration: InputDecoration(
                  labelText:
                  i18nIn.$trans('form.typeahead_label_search_equipment')
              )
          ),
          suggestionsCallback: (String pattern) async {
            return await equipmentApi.equipmentTypeAhead(pattern, formData!.branch);
          },
          itemBuilder: (context, suggestion) {
            String text = suggestion.identifier != null && suggestion.identifier != '' ?
              '${suggestion.name} (${suggestion.identifier})' :
              '${suggestion.name}';
            return ListTile(
              title: Text(text),
            );
          },
          noItemsFoundBuilder: (context) {
            return Expanded(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(i18nIn.$trans('form.equipment_not_found'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey
                      )
                  ),
                  if ((isPlanning() && formData!.quickCreateSettings!.equipmentPlanningQuickCreate) ||
                    (!isPlanning() && formData!.quickCreateSettings!.equipmentQuickCreate))
                    TextButton(
                      child: Text(
                          i18nIn.$trans('form.create_new_equipment'),
                          style: const TextStyle(
                            fontSize: 12,
                          )
                      ),
                      onPressed: () {
                        // create new equipment
                        FocusScope.of(context).requestFocus(equipmentCreateFocusNode);
                        _createSelectEquipment(context);
                      },
                    )
                ]
              )
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (EquipmentTypeAheadModel suggestion) {
            formData!.orderlineFormData!.equipment = suggestion.id!;
            formData!.orderlineFormData!.productController!.text = suggestion.name!;

            // fill location if this is set and known
            if (suggestion.location != null) {
              formData!.orderlineFormData!.equipmentLocation = suggestion.location!.id;
              formData!.orderlineFormData!.locationController!.text = suggestion.location!.name!;
            }
            updateFormData(context);
          },
          validator: (value) {
            return null;
          },
        ),

        widgetsIn.wrapGestureDetector(context, const SizedBox(
          height: 10.0,
        )),

        Visibility(
          visible: formData!.isCreatingEquipment!,
          child: Text(
            i18nIn.$trans('form.adding_equipment'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.red
            ),
          )
        ),
        Visibility(
          visible: !formData!.isCreatingEquipment!,
          child:
            SizedBox(
              width: 400,
              child: Row(
              children: [
                SizedBox(width: 290,
                    child: TextFormField(
                      controller: formData!.orderlineFormData!.productController,
                      keyboardType: TextInputType.text,
                      focusNode: equipmentCreateFocusNode,
                      readOnly: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return i18nIn.$trans('form.validator_equipment');
                        }
                        return null;
                      }
                  )
                ),
                const SizedBox(width: 10),
                Visibility(
                    visible: formData!.orderlineFormData!.equipment != null,
                    child: const Icon(
                      Icons.check,
                      color: Colors.blue,
                      size: 24.0,
                    ),
                )
              ],
            )
          )
        ),
        const SizedBox(
          height: 10.0,
        ),

        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_location', pathOverride: 'generic'))),
        _getLocationsPart(context),

        widgetsIn.wrapGestureDetector(context, const SizedBox(
          height: 10.0,
        )),

        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_remarks', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.remarksController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widgetsIn.createElevatedButtonColored(
            i18nIn.$trans('form.button_add_orderline'),
            () { _addOrderLineEquipment(context); }
        )
      ],
    ));
  }

  Widget _buildOrderlineFormNoBranch(BuildContext context) {
    return Form(key: _formKeys[1], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_equipment', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.productController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty) {
                return i18nIn.$trans('form.validator_equipment');
              }
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_location', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.locationController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_remarks', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.remarksController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        widgetsIn.createElevatedButtonColored(
            i18nIn.$trans('form.button_add_orderline'),
            () { _addOrderLine(context); }
        )
      ],
    ));
  }

  void _addOrderLine(BuildContext context) {
    if (this._formKeys[1].currentState!.validate()) {
      this._formKeys[1].currentState!.save();

      Orderline orderline = formData!.orderlineFormData!.toModel();

      formData!.orderLines!.add(orderline);

      formData!.orderlineFormData!.remarksController!.text = '';
      formData!.orderlineFormData!.locationController!.text = '';
      formData!.orderlineFormData!.productController!.text = '';

      updateFormData(context);
    } else {
      widgetsIn.displayDialog(context,
          i18nIn.$trans('error_dialog_title', pathOverride: 'generic'),
          i18nIn.$trans('form.error_adding_orderline')
      );
    }
  }

  void _addOrderLineEquipment(BuildContext context) {
    if (this._formKeys[1].currentState!.validate() && formData!.orderlineFormData!.equipment != null &&
        formData!.orderlineFormData!.equipmentLocation != null) {
      this._formKeys[1].currentState!.save();

      // fill location text from selected location
      if (formData!.orderlineFormData!.locationController!.text == '') {
        EquipmentLocation location = formData!.locations!.firstWhere(
            (location) => location.id == formData!.orderlineFormData!.equipmentLocation
        );

        formData!.orderlineFormData!.locationController!.text = location.name!;
      }

      Orderline orderline = formData!.orderlineFormData!.toModel();

      formData!.orderLines!.add(orderline);

      formData!.orderlineFormData!.remarksController!.text = '';
      formData!.orderlineFormData!.locationController!.text = '';
      formData!.orderlineFormData!.productController!.text = '';
      formData!.orderlineFormData!.typeAheadControllerEquipment!.text = '';
      formData!.orderlineFormData!.typeAheadControllerEquipmentLocation!.text = '';
      formData!.orderlineFormData!.equipment = null;
      formData!.orderlineFormData!.equipmentLocation = null;

      updateFormData(context);
    } else {
      widgetsIn.displayDialog(context,
          i18nIn.$trans('error_dialog_title', pathOverride: 'generic'),
          i18nIn.$trans('form.error_adding_orderline')
      );
    }
  }

  Widget _buildOrderlineSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_orderlines'),
        formData!.orderLines,
        (item) {
          String equipmentLocationTitle = "${i18nIn.$trans('info_equipment', pathOverride: 'generic')} / ${i18nIn.$trans('info_location', pathOverride: 'generic')}";
          String equipmentLocationValue = "${item.product} / ${item.location}";
          return <Widget>[
            ...widgetsIn.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
            ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_remarks', pathOverride: 'generic'), item.remarks)
          ];
        },
        (Orderline item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widgetsIn.createDeleteButton(
                    () { _showDeleteDialogOrderline(context, item); }
                )
              ],
            )
          ];
        }
    );
  }

  Widget _buildInfolineForm(BuildContext context) {
    return Form(key: _formKeys[2], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_infoline'))),
        TextFormField(
            controller: formData!.infolineFormData!.infoController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              if (value!.isEmpty) {
                return i18nIn.$trans('form.validator_infoline');
              }

              return null;
            }
        ),
        const SizedBox(
          height: 10.0,
        ),
        widgetsIn.createElevatedButtonColored(
            i18nIn.$trans('form.button_add_infoline'),
            () { _addInfoLine(context); }
        )
      ],
    ));
  }

  void _addInfoLine(BuildContext context) {
    if (this._formKeys[2].currentState!.validate()) {
      this._formKeys[2].currentState!.save();

      Infoline infoline = formData!.infolineFormData!.toModel();

      formData!.infoLines!.add(infoline);

      // reset fields
      formData!.infolineFormData!.infoController!.text = '';
      updateFormData(context);
    } else {
      widgetsIn.displayDialog(context,
          i18nIn.$trans('error_dialog_title', pathOverride: 'generic'),
          i18nIn.$trans('form.error_adding_infoline')
      );
    }
  }

  Widget _buildInfolineSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_infolines'),
        formData!.infoLines,
        (item) {
          return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_infoline'), item.info);
        },
        (Infoline item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widgetsIn.createDeleteButton(
                    () { _showDeleteDialogInfoline(context, item); }
                )
              ],
            )
          ];
        }
    );
  }

  _deleteOrderLine(BuildContext context, Orderline orderLine) {
    if (orderLine.id != null && !formData!.deletedOrderLines!.contains(orderLine)) {
      formData!.deletedOrderLines!.add(orderLine);
    }
    formData!.orderLines!.removeAt(formData!.orderLines!.indexOf(orderLine));
    updateFormData(context);
  }

  _showDeleteDialogOrderline(BuildContext context, Orderline orderLine) {
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('form.delete_dialog_title_orderline'),
        i18nIn.$trans('form.delete_dialog_content_orderline'),
        () => _deleteOrderLine(context, orderLine),
        context
    );
  }

  _deleteInfoLine(BuildContext context, Infoline infoline) {
    if (infoline.id != null && !formData!.deletedInfoLines!.contains(infoline)) {
      formData!.deletedInfoLines!.add(infoline);
    }

    formData!.infoLines!.removeAt(formData!.infoLines!.indexOf(infoline));
    updateFormData(context);
  }

  _showDeleteDialogInfoline(BuildContext context, Infoline infoline) {
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('form.delete_dialog_title_infoline'),
        i18nIn.$trans('form.delete_dialog_content_infoline'),
        () => _deleteInfoLine(context, infoline),
        context
    );
  }

  Future<void> _doSubmit(BuildContext context) async {
    if (this._formKeys[0].currentState!.validate()) {
      if (!formData!.isValid()) {
        if (formData!.orderType == null) {
          widgetsIn.displayDialog(context,
              i18nIn.$trans('form.validator_ordertype_dialog_title'),
              i18nIn.$trans('form.validator_ordertype_dialog_content')
          );

          return;
        }
      }

      this._formKeys[0].currentState!.save();

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
          deletedOrderLines: formData!.deletedOrderLines!,
          deletedInfoLines: formData!.deletedInfoLines!,
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
        ));
      }
    }
  }
}
