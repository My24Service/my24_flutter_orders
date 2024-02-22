import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_equipment/models/location/api.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';

class OrderlineFormEquipment<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final OrderlineFormData orderlineFormData;
  final My24i18n i18n;

  const OrderlineFormEquipment({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.orderlineFormData,
    required this.i18n
  });

  @override
  State<StatefulWidget> createState() => _OrderlineFormEquipmentState();
}

class _OrderlineFormEquipmentState<
  BlocClass extends OrderBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<OrderlineFormEquipment> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController typeAheadControllerEquipment = TextEditingController();
  final TextEditingController typeAheadControllerEquipmentLocation = TextEditingController();
  final EquipmentApi equipmentApi = EquipmentApi();
  final FocusNode equipmentCreateFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool mustResetLocation = false;

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
    typeAheadControllerEquipment.dispose();
    typeAheadControllerEquipmentLocation.dispose();
    equipmentCreateFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  _canCreateEquipment() {
    return (widget.isPlanning && widget.formData.quickCreateSettings!.equipmentPlanningQuickCreate) ||
        (!widget.isPlanning && widget.formData.quickCreateSettings!.equipmentQuickCreate);
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
                Text(My24i18n.tr('generic.info_equipment'))
            ),
            TypeAheadFormField<EquipmentTypeAheadModel>(
              minCharsForSuggestions: 2,
              textFieldConfiguration: TextFieldConfiguration(
                  controller: typeAheadControllerEquipment,
                  decoration: InputDecoration(
                      labelText:
                      widget.i18n.$trans('typeahead_label_search_equipment')
                  )
              ),
              suggestionsCallback: (String pattern) async {
                return await equipmentApi.equipmentTypeAhead(
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
                return Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.i18n.$trans('equipment_not_found'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey
                              )
                          ),
                          if (_canCreateEquipment())
                            TextButton(
                              child: Text(
                                  widget.i18n.$trans('create_new_equipment'),
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
                widget.orderlineFormData.equipment = suggestion.id!;
                productController.text = suggestion.name!;
                widget.orderlineFormData.product = suggestion.name!;

                // fill location if this is set and known
                if (suggestion.location != null) {
                  widget.orderlineFormData.equipmentLocation = suggestion.location!.id;
                  locationController.text = suggestion.location!.name!;
                  widget.orderlineFormData.location = suggestion.location!.name!;
                }
                setState(() {

                });
              },
              validator: (value) {
                return null;
              },
            ),

            widget.widgets.wrapGestureDetector(context, const SizedBox(
              height: 10.0,
            )),

            Visibility(
                visible: widget.formData.isCreatingEquipment!,
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
                visible: !widget.formData.isCreatingEquipment!,
                child:
                SizedBox(
                    width: 420,
                    child: Row(
                      children: [
                        SizedBox(width: 260,
                            child: TextFormField(
                                controller: productController,
                                keyboardType: TextInputType.text,
                                focusNode: equipmentCreateFocusNode,
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
              isPlanning: widget.isPlanning,
              orderlineFormData: widget.orderlineFormData,
              i18n: widget.i18n,
              mustReset: mustResetLocation,
            ),

            widget.widgets.wrapGestureDetector(
              context, const SizedBox(
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
            widget.widgets.createElevatedButtonColored(
                widget.i18n.$trans('button_add'),
                () { _addOrderLine(context); }
            )
          ],
        )
    );
  }

  _createSelectEquipment(BuildContext context) {
    // TODO do we still need this?
    // final bloc = BlocProvider.of<BlocClass>(context);
    //
    // formData!.isCreatingEquipment = true;
    // bloc.add(OrderEvent(
    //     status: OrderEventStatus.updateFormData,
    //     formData: formData
    // ));
    //
    // bloc.add(OrderEvent(
    //     status: OrderEventStatus.createSelectEquipment,
    //     formData: formData
    // ));
  }

  void _addOrderLine(BuildContext context) {
    if (this.formKey.currentState!.validate() && widget.orderlineFormData.equipment != null &&
        widget.orderlineFormData.equipmentLocation != null) {
      this.formKey.currentState!.save();

      Orderline orderline = widget.orderlineFormData.toModel();

      widget.formData.orderLines!.add(orderline);
      widget.orderlineFormData.reset(widget.formData.id);

      remarksController.text = '';
      locationController.text = '';
      productController.text = '';
      typeAheadControllerEquipment.text = '';
      typeAheadControllerEquipmentLocation.text = '';

      updateFormData(context);
      widget.widgets.createSnackBar(context, widget.i18n.$trans('snackbar_added'));
      setState(() {
        mustResetLocation = true;
      });
    } else {
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}

class LocationsPart<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final OrderlineFormData orderlineFormData;
  final My24i18n i18n;
  final bool mustReset;

  const LocationsPart({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.orderlineFormData,
    required this.i18n,
    required this.mustReset
  });

  @override
  State<StatefulWidget> createState() => _LocationsPartState();
}

class _LocationsPartState<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends State<LocationsPart> {
  final TextEditingController typeAheadControllerEquipmentLocation = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final EquipmentLocationApi equipmentLocationApi = EquipmentLocationApi();
  final FocusNode equipmentLocationCreateFocusNode = FocusNode();
  List<EquipmentLocation> locations = [];
  final EquipmentLocationApi locationApi = EquipmentLocationApi();

  _addListeners() {
    locationController.addListener(_locationListen);
  }

  void _locationListen() {
    if (locationController.text.isEmpty) {
      widget.orderlineFormData.location = "";
    } else {
      widget.orderlineFormData.location = locationController.text;
    }
  }

  @override
  void dispose() {
    super.dispose();
    typeAheadControllerEquipmentLocation.dispose();
    locationController.dispose();
    equipmentLocationCreateFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!_canCreateLocation()) {
      _fetchLocations();
    }
    _addListeners();
  }

  Future<void> _fetchLocations() async {
    locations = await locationApi.fetchLocationsForSelect(branch: widget.formData.branch);
  }

  _canCreateLocation() {
    return (widget.isPlanning && widget.formData.quickCreateSettings!.equipmentLocationPlanningQuickCreate) ||
        (!widget.isPlanning && widget.formData.quickCreateSettings!.equipmentLocationQuickCreate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mustReset) {
      locationController.text = "";
      typeAheadControllerEquipmentLocation.text = "";
    } else {
      if (widget.orderlineFormData.location != null) {
        locationController.text = widget.orderlineFormData.location!;
      }
    }
    if (_canCreateLocation()) {
      return Column(
        children: [
          Visibility(
            visible: widget.orderlineFormData.equipmentLocation == null,
            child: TypeAheadFormField<EquipmentLocationTypeAheadModel>(
              minCharsForSuggestions: 2,
              textFieldConfiguration: TextFieldConfiguration(
                  controller: typeAheadControllerEquipmentLocation,
                  decoration: InputDecoration(
                      labelText:
                      widget.i18n.$trans('typeahead_label_search_location')
                  )
              ),
              suggestionsCallback: (String pattern) async {
                return await equipmentLocationApi.locationTypeAhead(pattern, widget.formData.branch);
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
                widget.orderlineFormData.equipmentLocation = suggestion.id;
                widget.orderlineFormData.location = suggestion.name!;
                locationController.text = suggestion.name!;
                setState(() {

                });
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
              visible: widget.formData.isCreatingLocation!,
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
              visible: !widget.formData.isCreatingLocation!,
              child:
              SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 260,
                          child: TextFormField(
                              controller: locationController,
                              keyboardType: TextInputType.text,
                              focusNode: equipmentLocationCreateFocusNode,
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
          widget.orderlineFormData.equipmentLocation = int.parse(locationId!);
          EquipmentLocation location = locations.firstWhere(
                  (location) => location.id == widget.orderlineFormData.equipmentLocation);
          locationController.text = location.name!;
          widget.orderlineFormData.location  = location.name!;
          setState(() {

          });
        }
    );
  }

  _createSelectEquipmentLocation(BuildContext context) {
    // TODO do we still need this?
    // final bloc = BlocProvider.of<BlocClass>(context);
    //
    // widget.formData.isCreatingLocation = true;
    // bloc.add(OrderEvent(
    //     status: OrderEventStatus.updateFormData,
    //     formData: widget.formData
    // ));
    //
    // bloc.add(OrderEvent(
    //     status: OrderEventStatus.createSelectEquipmentLocation,
    //     formData: widget.formData
    // ));
  }

}