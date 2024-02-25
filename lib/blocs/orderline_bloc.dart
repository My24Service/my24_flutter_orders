import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_equipment/models/location/api.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';

import '../models/orderline/form_data.dart';
import 'orderline_states.dart';

enum OrderLineStatus {
  updateFormData,
  newFormData,
  createSelectEquipment,
  createSelectEquipmentLocation,
  doAsync,
  added
}

final log = Logger('orderline_bloc');

class OrderLineEvent {
  final String? value;
  OrderlineFormData? formData;
  final OrderLineStatus? status;
  int? order;
  String? name;
  int? branch;
  int? customerPk;

  OrderLineEvent({
    this.value,
    this.status,
    this.formData,
    this.order,
    this.name,
    this.branch,
    this.customerPk
  });
}

class OrderLineBloc extends Bloc<OrderLineEvent, OrderLineBaseState> {
  EquipmentLocationApi locationApi = EquipmentLocationApi();
  EquipmentApi equipmentApi = EquipmentApi();

  OrderLineBloc() : super(OrderLineInitialState()) {
    on<OrderLineEvent>((event, emit) async {
      if (event.status == OrderLineStatus.doAsync) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == OrderLineStatus.updateFormData) {
        _handleUpdateFormData(event, emit);
      }
      else if (event.status == OrderLineStatus.newFormData) {
        _handleNewFormData(event, emit);
      }
      else if (event.status == OrderLineStatus.createSelectEquipment) {
        await _handleCreateSelectEquipment(event, emit);
      }
      else if (event.status == OrderLineStatus.createSelectEquipmentLocation) {
        await _handleCreateSelectEquipmentLocation(event, emit);
      } else if (event.status == OrderLineStatus.added) {
        _handleAdded(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(OrderLineEvent event, Emitter<OrderLineBaseState> emit) {
    emit(OrderLineLoadingState());
  }

  void _handleAdded(OrderLineEvent event, Emitter<OrderLineBaseState> emit) {
    emit(OrderLineAddedState());
  }

  void _handleUpdateFormData(OrderLineEvent event, Emitter<OrderLineBaseState> emit) {
    emit(OrderLineLoadedState(formData: event.formData!));
  }

  void _handleNewFormData(OrderLineEvent event, Emitter<OrderLineBaseState> emit) {
    emit(OrderLineNewFormDataState(formData: OrderlineFormData.createEmpty(event.order)));
  }

  Future<void> _handleCreateSelectEquipment(OrderLineEvent event, Emitter<OrderLineBaseState> emit) async {
    final bool hasBranches = (await coreUtils.getHasBranches())!;
    EquipmentCreateQuickResponse response;

    try {
      if (hasBranches) {
        final EquipmentCreateQuickBranch equipment = EquipmentCreateQuickBranch(
          name: event.name!,
          branch: event.branch!,
        );

        response = await equipmentApi.createQuickBranch(equipment);
        event.formData!.equipmentCreateQuickResponse = response;
      } else {
        final EquipmentCreateQuickCustomer equipment = EquipmentCreateQuickCustomer(
          name: event.name!,
          customer: event.customerPk!,
        );

        response = await equipmentApi.createQuickCustomer(equipment);
        event.formData!.equipmentCreateQuickResponse = response;
      }

      emit(OrderLineNewEquipmentCreatedState(
        formData: event.formData!,
      ));
    } catch(e) {
      log.severe("error: $e");
      emit(OrderLineErrorSnackbarState(message: e.toString()));
      emit(OrderLineLoadedState(formData: event.formData!));
    }
  }

  Future<void> _handleCreateSelectEquipmentLocation(OrderLineEvent event, Emitter<OrderLineBaseState> emit) async {
    final bool hasBranches = (await coreUtils.getHasBranches())!;
    EquipmentLocationCreateQuickResponse response;

    try {
      if (hasBranches) {
        final EquipmentLocationCreateQuickBranch location = EquipmentLocationCreateQuickBranch(
          name: event.name!,
          branch: event.branch!,
        );

        response = await locationApi.createQuickBranch(location);
        event.formData!.equipmentLocationCreateQuickResponse = response;
      } else {
        final EquipmentLocationCreateQuickCustomer location = EquipmentLocationCreateQuickCustomer(
          name: event.name!,
          customer: event.customerPk!,
        );

        response = await locationApi.createQuickCustomer(location);
        event.formData!.equipmentLocationCreateQuickResponse = response;
      }

      emit(OrderLineNewLocationCreatedState(formData: event.formData!));
    } catch(e) {
      log.severe("error: $e");
      emit(OrderLineErrorSnackbarState(message: e.toString()));
      emit(OrderLineLoadedState(formData: event.formData!));
    }
  }

}
