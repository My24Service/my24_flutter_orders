import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_equipment/models/location/api.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';

import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';

import 'package:my24_flutter_orders/blocs/order_form_bloc.dart';
import 'package:my24_flutter_orders/blocs/orderline_bloc.dart';
import 'package:my24_flutter_orders/models/orderline/form_data.dart';

final log = Logger('orders.form.orderlines.equipment');

class OrderlineFormEquipment<
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final My24i18n i18n;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final OrderlineFormData orderlineFormData;

  OrderlineFormEquipment({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.i18n,
    required this.orderlineFormData
  });

  @override
  State<StatefulWidget> createState() => _OrderlineFormEquipmentState();
}

class _OrderlineFormEquipmentState<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<OrderlineFormEquipment> {
  final TextEditingController remarksController = TextEditingController();
  bool setLocationToEquipment = false;

  @override
  void dispose() {
    super.dispose();
    remarksController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderlineFormData.equipmentCreateQuickResponse != null) {
      log.info("build: equipment create quick response received");
      widget.orderlineFormData.equipment = widget.orderlineFormData.equipmentCreateQuickResponse!.id!;
      widget.orderlineFormData.product = widget.orderlineFormData.equipmentCreateQuickResponse!.name!;
    }

    if (widget.orderlineFormData.equipmentLocationCreateQuickResponse != null) {
      log.info("build: location create quick response received");
      widget.orderlineFormData.equipmentLocation = widget.orderlineFormData.equipmentLocationCreateQuickResponse!.id!;
      widget.orderlineFormData.location = widget.orderlineFormData.equipmentLocationCreateQuickResponse!.name!;
    }

    remarksController.text = widget.orderlineFormData.remarks!;

    return Form(
        key: widget.formKey,
        child: Column(
        children: [
          EquipmentPart(
            formData: widget.formData,
            widgets: widget.widgets,
            i18n: widget.i18n,
            canCreateEquipment: _canCreateEquipment(),
            orderlineFormData: widget.orderlineFormData,
          ),
          const SizedBox(
            height: 10.0,
          ),

          widget.widgets.wrapGestureDetector(
              context,
              Text(My24i18n.tr('generic.info_location'))
          ),
          LocationsPart(
            formData: widget.formData,
            widgets: widget.widgets,
            i18n: widget.i18n,
            canCreateLocation: _canCreateLocation(),
            orderlineFormData: widget.orderlineFormData,
          ),

          widget.widgets.wrapGestureDetector(
            context,
            const SizedBox(
              height: 10.0,
            )
          ),

          widget.widgets.wrapGestureDetector(
              context,
              Text(My24i18n.tr('generic.info_remarks'))
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
          Visibility(
            visible: _displayAddLocationToEquipment(),
            child: CheckboxListTile(
                title: widget.widgets.wrapGestureDetector(
                    context,
                    Text(widget.i18n.$trans('info_save_location_to_equipment'))
                ),
                value: setLocationToEquipment,
                onChanged: (newValue) {
                  setState(() {
                    setLocationToEquipment = newValue!;
                  });

                }
            )
          ),
          if (_displayAddLocationToEquipment())
            const SizedBox(
            height: 10.0,
          ),

          widget.widgets.createElevatedButtonColored(
              widget.i18n.$trans('button_add'),
              () { _addOrderLine(context); }
          )
        ],
      )
    );
  }

  bool _displayAddLocationToEquipment() {
    return !widget.orderlineFormData.equipmentHasLocation! && widget.orderlineFormData.equipment != null && widget.orderlineFormData.equipmentLocation != null;
  }

  _addListeners() {
    remarksController.addListener(_remarksListen);
  }

  void _remarksListen() {
    if (remarksController.text.isEmpty) {
      widget.orderlineFormData.remarks = "";
    } else {
      widget.orderlineFormData.remarks = remarksController.text;
    }
  }

  _canCreateEquipment() {
    return (widget.isPlanning && widget.formData.quickCreateSettings!.equipmentPlanningQuickCreate) ||
        (!widget.isPlanning && widget.formData.quickCreateSettings!.equipmentQuickCreate);
  }

  _canCreateLocation() {
    return (widget.isPlanning && widget.formData.quickCreateSettings!.equipmentLocationPlanningQuickCreate) ||
        (!widget.isPlanning && widget.formData.quickCreateSettings!.equipmentLocationQuickCreate);
  }

  _addOrderLine(BuildContext context) {
    if (widget.formKey.currentState!.validate() && widget.orderlineFormData.equipment != null &&
        widget.orderlineFormData.equipmentLocation != null) {
      widget.formKey.currentState!.save();

      Orderline orderline = widget.orderlineFormData.toModel();

      // check if we need to update equipment
      if (setLocationToEquipment) {
        final Equipment updateEquipment = Equipment(
          id: orderline.equipment!,
          name: orderline.product!,
          location: orderline.equipmentLocation!
        );
        widget.formData.equipmentLocationUpdates!.add(updateEquipment);
      }

      final orderBloc = BlocProvider.of<BlocClass>(context);
      orderBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      orderBloc.add(OrderFormEvent(
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
      log.severe("error adding orderline; equipment: ${widget.orderlineFormData.equipment}, equipment location: ${widget.orderlineFormData.equipmentLocation}");
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}

class EquipmentPart<FormDataClass extends BaseOrderFormData> extends StatefulWidget {
  final FocusNode equipmentCreateFocusNode = FocusNode();
  final TextEditingController typeAheadControllerEquipment = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final bool canCreateEquipment;
  final OrderlineFormData orderlineFormData;

  EquipmentPart({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n,
    required this.canCreateEquipment,
    required this.orderlineFormData
  });

  @override
  State<StatefulWidget> createState() => _EquipmentPartState();
}

class _EquipmentPartState extends State<EquipmentPart> {
  final EquipmentApi equipmentApi = EquipmentApi();
  bool isCreatingEquipment = false;

  @override
  void dispose() {
    super.dispose();
    widget.typeAheadControllerEquipment.dispose();
    widget.productController.dispose();
    widget.equipmentCreateFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderlineFormData.equipmentCreateQuickResponse != null) {
      setState(() {
        isCreatingEquipment = false;
      });
    }

    widget.productController.text = widget.orderlineFormData.product!;

    // we need the top level context is the dialog call
    BuildContext mainContext = context;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.widgets.wrapGestureDetector(
              context,
              Text(My24i18n.tr('generic.info_equipment'))
          ),
          TypeAheadFormField<EquipmentTypeAheadModel>(
            minCharsForSuggestions: 2,
            textFieldConfiguration: TextFieldConfiguration(
                controller: widget.typeAheadControllerEquipment,
                decoration: InputDecoration(
                    labelText:
                    widget.i18n.$trans('typeahead_label_search_equipment')
                )
            ),
            suggestionsCallback: (String pattern) async {
              return await equipmentApi.typeAhead(
                  pattern, widget.formData.branch);
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.i18n.$trans('equipment_not_found'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey
                      )
                  ),
                  if (widget.canCreateEquipment)
                    TextButton(
                      child: Text(
                          widget.i18n.$trans('create_new_equipment'),
                          style: const TextStyle(
                            fontSize: 12,
                          )
                      ),
                      onPressed: () {
                        // create new equipment
                        FocusScope.of(context).requestFocus(widget.equipmentCreateFocusNode);
                        widget.widgets.showActionDialogWrapper(
                          widget.i18n.$trans('dialog_title_create_equipment'),
                          widget.i18n.$trans('dialog_content_create_equipment', namedArgs: {'name': widget.typeAheadControllerEquipment.text}),
                          widget.i18n.$trans('dialog_button_create_equipment'),
                          () { _createSelectEquipment(mainContext); },
                          context
                        );
                      },
                    )
                ]
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (EquipmentTypeAheadModel equipment) {
              widget.productController.text = equipment.name!;

              widget.orderlineFormData.equipment = equipment.id!;
              widget.orderlineFormData.product = equipment.name!;

              // fill location if this is set and known
              if (equipment.location != null) {
                widget.orderlineFormData.equipmentHasLocation = true;
                widget.orderlineFormData.equipmentLocation = equipment.location!.id;
                widget.orderlineFormData.location = equipment.location!.name!;
              } else {
                widget.orderlineFormData.equipmentHasLocation = false;
              }

              _updateFormData();
            },
            validator: (value) {
              return null;
            },
          ),

          widget.widgets.wrapGestureDetector(context, const SizedBox(
            height: 10.0,
          )),

          Visibility(
              visible: isCreatingEquipment,
              child: Text(
                widget.i18n.$trans('adding_equipment'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.red
                ),
              )
          ),
          Visibility(
              visible: !isCreatingEquipment,
              child:
              SizedBox(
                  width: 420,
                  child: Row(
                    children: [
                      SizedBox(width: 260,
                          child: TextFormField(
                              controller: widget.productController,
                              keyboardType: TextInputType.text,
                              focusNode: widget.equipmentCreateFocusNode,
                              readOnly: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return widget.i18n.$trans('validator_equipment');
                                }
                                return null;
                              }
                          )
                      ),
                      const SizedBox(width: 10),
                      Visibility(
                        visible: widget.orderlineFormData.equipment != null,
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

  void _updateFormData() {
    final bloc = BlocProvider.of<OrderLineBloc>(context);
    bloc.add(OrderLineEvent(status: OrderLineStatus.doAsync));
    bloc.add(OrderLineEvent(
        status: OrderLineStatus.updateFormData,
        formData: widget.orderlineFormData
    ));
  }

  _createSelectEquipment(BuildContext context) {
    setState(() {
      isCreatingEquipment = true;
    });

    final bloc = BlocProvider.of<OrderLineBloc>(context);
    bloc.add(OrderLineEvent(status: OrderLineStatus.doAsync));
    bloc.add(OrderLineEvent(
        status: OrderLineStatus.createSelectEquipment,
        name: widget.typeAheadControllerEquipment.text,
        branch: widget.formData.branch!,
        formData: widget.orderlineFormData
    ));
  }
}

class LocationsPart<FormDataClass extends BaseOrderFormData> extends StatefulWidget {
  final TextEditingController typeAheadControllerEquipmentLocation = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final EquipmentLocationApi equipmentLocationApi = EquipmentLocationApi();
  final FocusNode equipmentLocationCreateFocusNode = FocusNode();
  final EquipmentLocationApi locationApi = EquipmentLocationApi();
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final bool canCreateLocation;
  final OrderlineFormData orderlineFormData;

  LocationsPart({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n,
    required this.canCreateLocation,
    required this.orderlineFormData
  });

  @override
  State<StatefulWidget> createState() => _LocationsPartState();
}

class _LocationsPartState<FormDataClass extends BaseOrderFormData> extends State<LocationsPart> {
  List<EquipmentLocation> locations = [];
  bool isCreatingLocation = false;

  @override
  void dispose() {
    super.dispose();
    widget.typeAheadControllerEquipmentLocation.dispose();
    widget.locationController.dispose();
    widget.equipmentLocationCreateFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.canCreateLocation) {
      _fetchLocations();
    }
    _addListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderlineFormData.equipmentLocationCreateQuickResponse != null) {
      setState(() {
        isCreatingLocation = false;
      });
    }

    widget.locationController.text = widget.orderlineFormData.location!;

    // we need the top level context is the dialog call
    BuildContext mainContext = context;

    if (widget.canCreateLocation) {
      return Column(
        children: [
          Visibility(
            visible: widget.orderlineFormData.equipmentLocation == null,
            child: TypeAheadFormField<EquipmentLocationTypeAheadModel>(
              minCharsForSuggestions: 2,
              textFieldConfiguration: TextFieldConfiguration(
                  controller: widget.typeAheadControllerEquipmentLocation,
                  decoration: InputDecoration(
                      labelText:
                      widget.i18n.$trans('typeahead_label_search_location')
                  )
              ),
              suggestionsCallback: (String pattern) async {
                return await widget.equipmentLocationApi.typeAhead(pattern, widget.formData.branch);
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
                return Column(
                  children: [
                    Text(widget.i18n.$trans('location_not_found'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey
                        )
                    ),
                    TextButton(
                      child: Text(
                          widget.i18n.$trans('create_new_location'),
                          style: const TextStyle(
                            fontSize: 12,
                          )
                      ),
                      onPressed: () {
                        // create new location
                        FocusScope.of(context).requestFocus(widget.equipmentLocationCreateFocusNode);
                        widget.widgets.showActionDialogWrapper(
                            widget.i18n.$trans('dialog_title_create_location'),
                            widget.i18n.$trans('dialog_content_create_location', namedArgs: {'name': widget.typeAheadControllerEquipmentLocation.text}),
                            widget.i18n.$trans('dialog_button_create_location'),
                            () { _createSelectEquipmentLocation(mainContext); },
                            context
                        );
                      },
                    )
                  ]
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (EquipmentLocationTypeAheadModel suggestion) {
                widget.locationController.text = suggestion.name!;

                widget.orderlineFormData.equipmentLocation = suggestion.id!;
                widget.orderlineFormData.location = suggestion.name!;

                // _updateFormData();
              },
              validator: (value) {
                return null;
              },
            )
          ),
          widget.widgets.wrapGestureDetector(context, const SizedBox(
            height: 10.0,
          )),

          Visibility(
              visible: isCreatingLocation,
              child: Text(
                widget.i18n.$trans('adding_location'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.red
                ),
              )
          ),
          Visibility(
              visible: !isCreatingLocation,
              child:
              SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 260,
                          child: TextFormField(
                              controller: widget.locationController,
                              keyboardType: TextInputType.text,
                              focusNode: widget.equipmentLocationCreateFocusNode,
                              readOnly: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return widget.i18n.$trans('validator_location');
                                }
                                return null;
                              }
                          )
                      ),
                      const SizedBox(width: 10),
                      Visibility(
                        visible: widget.orderlineFormData.equipmentLocation != null,
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
        value: "${widget.orderlineFormData.equipmentLocation}",
        items: locations.map((EquipmentLocation location) {
          return DropdownMenuItem<String>(
            value: "${location.id}",
            child: Text(location.name!),
          );
        }).toList(),
        onChanged: (String? locationId) {
          EquipmentLocation location = locations.firstWhere(
                  (location) => location.id == widget.orderlineFormData.equipmentLocation);
          widget.locationController.text = location.name!;

          widget.orderlineFormData.equipmentLocation = location.id!;
        }
    );
  }

  _createSelectEquipmentLocation(BuildContext context) {
    setState(() {
      isCreatingLocation = true;
    });

    final bloc = BlocProvider.of<OrderLineBloc>(context);
    bloc.add(OrderLineEvent(
        status: OrderLineStatus.createSelectEquipmentLocation,
        name: widget.typeAheadControllerEquipmentLocation.text,
        branch: widget.formData.branch!,
        formData: widget.orderlineFormData
    ));
  }

  Future<void> _fetchLocations() async {
    locations = await widget.locationApi.fetchLocationsForSelect(branch: widget.formData.branch);
  }

  _addListeners() {
    widget.locationController.addListener(_locationListen);
  }

  void _locationListen() {
    if (widget.locationController.text.isEmpty) {
      widget.orderlineFormData.location = "";
    } else {
      widget.orderlineFormData.location = widget.locationController.text;
    }
  }
}