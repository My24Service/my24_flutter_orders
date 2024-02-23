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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  OrderlineFormEquipment({
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
  final TextEditingController remarksController = TextEditingController();
  bool mustReset = false;
  bool equipmentHasLocation = false;
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
    final bloc = BlocProvider.of<BlocClass>(context);

    if (widget.formData.equipmentCreateQuickResponse != null) {
      widget.orderlineFormData.equipment = widget.formData.equipmentCreateQuickResponse!.id!;
      widget.orderlineFormData.product = widget.formData.equipmentCreateQuickResponse!.name!;
    }

    if (widget.formData.equipmentLocationCreateQuickResponse != null) {
      widget.orderlineFormData.equipmentLocation = widget.formData.equipmentLocationCreateQuickResponse!.id!;
      widget.orderlineFormData.location = widget.formData.equipmentLocationCreateQuickResponse!.name!;
    }

    return Form(
        key: widget.formKey,
        child: Column(
        children: [
          EquipmentPart(
            formData: widget.formData,
            widgets: widget.widgets,
            orderlineFormData: widget.orderlineFormData,
            i18n: widget.i18n,
            mustReset: mustReset,
            onEquipmentSelect: _onEquipmentSelect,
            canCreateEquipment: _canCreateEquipment(),
            bloc: bloc,
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
            orderlineFormData: widget.orderlineFormData,
            i18n: widget.i18n,
            mustReset: mustReset,
            onLocationSelect: _onLocationSelect,
            canCreateLocation: _canCreateLocation(),
            bloc: bloc,
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
            visible: !equipmentHasLocation && widget.orderlineFormData.equipment != null && widget.orderlineFormData.equipmentLocation != null,
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
          if (!equipmentHasLocation)
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

  void _onLocationSelect(int id, String name) {
    setState(() {
      widget.orderlineFormData.equipmentLocation = id;
      widget.orderlineFormData.location = name;
    });
  }

  void _onEquipmentSelect(EquipmentTypeAheadModel equipment) {
    setState(() {
      widget.orderlineFormData.equipment = equipment.id!;
      widget.orderlineFormData.product = equipment.name!;

      // fill location if this is set and known
      if (equipment.location != null) {
        equipmentHasLocation = true;
        widget.orderlineFormData.equipmentLocation = equipment.location!.id;
        widget.orderlineFormData.location = equipment.location!.name!;
      } else {
        equipmentHasLocation = false;
      }
    });
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

      widget.formData.orderLines!.add(orderline);
      widget.orderlineFormData.reset(widget.formData.id);
      remarksController.text = "";

      // check if we need to update equipment
      if (setLocationToEquipment) {
        final Equipment updateEquipment = Equipment(
          id: orderline.equipment!,
          name: orderline.product!,
          location: orderline.equipmentLocation!
        );
        widget.formData.equipmentLocationUpdates!.add(updateEquipment);
      }

      final bloc = BlocProvider.of<BlocClass>(context);
      bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
      bloc.add(OrderEvent(
          status: OrderEventStatus.updateFormData,
          formData: widget.formData
      ));

      widget.widgets.createSnackBar(context, widget.i18n.$trans('snackbar_added'));

      // let widgets reset
      setState(() {
        mustReset = true;
      });
    } else {
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}

class EquipmentPart<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final OrderlineFormData orderlineFormData;
  final bool mustReset;
  final Function onEquipmentSelect;
  final bool canCreateEquipment;
  final BlocClass bloc;

  const EquipmentPart({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n,
    required this.orderlineFormData,
    required this.mustReset,
    required this.onEquipmentSelect,
    required this.canCreateEquipment,
    required this.bloc
  });

  @override
  State<StatefulWidget> createState() => _EquipmentPartState();
}

class _EquipmentPartState<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends State<EquipmentPart> {
  final EquipmentApi equipmentApi = EquipmentApi();
  final FocusNode equipmentCreateFocusNode = FocusNode();
  final TextEditingController typeAheadControllerEquipment = TextEditingController();
  final TextEditingController productController = TextEditingController();
  bool isCreatingEquipment = false;

  @override
  void dispose() {
    super.dispose();
    typeAheadControllerEquipment.dispose();
    productController.dispose();
    equipmentCreateFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formData.equipmentCreateQuickResponse != null) {
      setState(() {
        isCreatingEquipment = false;
      });
    }

    if (widget.mustReset) {
      productController.text = "";
      typeAheadControllerEquipment.text = "";
    } else {
      if (widget.orderlineFormData.product != null) {
        productController.text = widget.orderlineFormData.product!;
      }
    }

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
                        FocusScope.of(context).requestFocus(equipmentCreateFocusNode);
                        _createSelectEquipment(context);
                      },
                    )
                ]
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (EquipmentTypeAheadModel suggestion) {
              widget.onEquipmentSelect(suggestion);
              productController.text = suggestion.name!;
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
        ],
    );
  }

  _createSelectEquipment(BuildContext context) {
    setState(() {
      isCreatingEquipment = true;
    });
    widget.bloc.add(OrderEvent(
      status: OrderEventStatus.createSelectEquipment,
      formData: widget.formData,
      name: typeAheadControllerEquipment.text
    ));
  }
}

class LocationsPart<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final OrderlineFormData orderlineFormData;
  final My24i18n i18n;
  final bool mustReset;
  final Function onLocationSelect;
  final bool canCreateLocation;
  final BlocClass bloc;

  const LocationsPart({
    super.key,
    required this.formData,
    required this.widgets,
    required this.orderlineFormData,
    required this.i18n,
    required this.mustReset,
    required this.onLocationSelect,
    required this.canCreateLocation,
    required this.bloc
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
  bool isCreatingLocation = false;

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
    if (!widget.canCreateLocation) {
      _fetchLocations();
    }
    _addListeners();
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

    if (widget.formData.equipmentLocationCreateQuickResponse != null) {
      setState(() {
        isCreatingLocation = false;
      });
    }

    if (widget.canCreateLocation) {
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
                        FocusScope.of(context).requestFocus(equipmentLocationCreateFocusNode);
                        _createSelectEquipmentLocation(context);
                      },
                    )
                  ]
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (EquipmentLocationTypeAheadModel suggestion) {
                widget.onLocationSelect(suggestion.id, suggestion.name!);
                locationController.text = suggestion.name!;
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
          widget.onLocationSelect(location.id, location.name);
          locationController.text = location.name!;
        }
    );
  }

  _createSelectEquipmentLocation(BuildContext context) {
    setState(() {
      isCreatingLocation = true;
    });

    widget.bloc.add(OrderEvent(
      status: OrderEventStatus.createSelectEquipmentLocation,
      formData: widget.formData,
      name: typeAheadControllerEquipmentLocation.text
    ));
  }

  Future<void> _fetchLocations() async {
    locations = await locationApi.fetchLocationsForSelect(branch: widget.formData.branch);
  }

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
}