import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_equipment/models/location/api.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_member_models/private/api.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';

import '../models/order/api.dart';
import '../blocs/order_states.dart';
import '../models/order/models.dart';
import '../models/infoline/api.dart';
import '../models/infoline/models.dart';
import '../models/order/form_data.dart';
import '../models/orderline/api.dart';
import '../models/orderline/models.dart';

enum OrderEventStatus {
  doAsync,
  doSearch,
  doRefresh,
  fetchAll,
  fetchDetail,
  fetchDetailView,
  fetchUnaccepted,
  fetchPast,

  newOrder,
  delete,
  update,
  insert,
  updateFormData,
  createSelectEquipment,
  createSelectEquipmentLocation,
  accept,
  reject,

  navDocuments,
  navDetail
}

class OrderEvent {
  final OrderEventStatus? status;
  final int? pk;
  final int? page;
  final String? query;
  final Order? order;
  final dynamic formData;
  final List<Orderline>? orderLines;
  final List<Infoline>? infoLines;
  final List<Orderline>? deletedOrderLines;
  final List<Infoline>? deletedInfoLines;

  const OrderEvent({
    this.pk,
    this.status,
    this.page,
    this.query,
    this.order,
    this.formData,
    this.orderLines,
    this.infoLines,
    this.deletedOrderLines,
    this.deletedInfoLines
  });
}

abstract class OrderBlocBase<FormData extends BaseOrderFormData> extends Bloc<OrderEvent, OrderState> {
  OrderApi api = OrderApi();
  EquipmentLocationApi locationApi = EquipmentLocationApi();
  EquipmentApi equipmentApi = EquipmentApi();
  PrivateMemberApi privateMemberApi = PrivateMemberApi();
  OrderlineApi orderlineApi = OrderlineApi();
  InfolineApi infolineApi = InfolineApi();

  OrderBlocBase(OrderState initialState) : super(initialState);

  Future<void> handleEvent(event, emit) async {
    if (event.status == OrderEventStatus.doAsync) {
      _handleDoAsyncState(event, emit);
    }
    else if (event.status == OrderEventStatus.doSearch) {
      _handleDoSearchState(event, emit);
    }
    else if (event.status == OrderEventStatus.navDocuments) {
      _handleNavDocumentsState(event, emit);
    }
    else if (event.status == OrderEventStatus.navDetail) {
      _handleNavDetailState(event, emit);
    }
    else if (event.status == OrderEventStatus.doRefresh) {
      _handleDoRefreshState(event, emit);
    }
    else if (event.status == OrderEventStatus.fetchDetail) {
      await _handleFetchState(event, emit);
    }
    else if (event.status == OrderEventStatus.fetchDetailView) {
      await _handleFetchViewState(event, emit);
    }
    else if (event.status == OrderEventStatus.fetchAll) {
      await _handleFetchAllState(event, emit);
    }
    else if (event.status == OrderEventStatus.fetchUnaccepted) {
      await _handleFetchUnacceptedState(event, emit);
    }
    else if (event.status == OrderEventStatus.fetchPast) {
      await _handleFetchPastState(event, emit);
    }
    else if (event.status == OrderEventStatus.insert) {
      await _handleInsertState(event, emit);
    }
    else if (event.status == OrderEventStatus.update) {
      await _handleEditState(event, emit);
    }
    else if (event.status == OrderEventStatus.delete) {
      await _handleDeleteState(event, emit);
    }
    else if (event.status == OrderEventStatus.updateFormData) {
      _handleUpdateFormDataState(event, emit);
    }
    else if (event.status == OrderEventStatus.createSelectEquipment) {
      await _handleCreateSelectEquipment(event, emit);
    }
    else if (event.status == OrderEventStatus.createSelectEquipmentLocation) {
      await _handleCreateSelectEquipmentLocation(event, emit);
    }
    else if (event.status == OrderEventStatus.accept) {
      _handleAcceptState(event, emit);
    }
    else if (event.status == OrderEventStatus.reject) {
      _handleRejectState(event, emit);
    }
  }

  void _handleUpdateFormDataState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderLoadedState(formData: event.formData));
  }

  Future<void> _handleCreateSelectEquipment(OrderEvent event, Emitter<OrderState> emit) async {
    final bool hasBranches = (await coreUtils.getHasBranches())!;
    final String? submodel = await coreUtils.getUserSubmodel();

    try {
      if (hasBranches) {
        final EquipmentCreateQuickBranch equipment = EquipmentCreateQuickBranch(
          name: event.formData!.orderlineFormData!.typeAheadControllerEquipment!.text.trim(),
          branch: submodel == 'planning_user' ? event.formData!.branch : 0,
        );

        final EquipmentCreateQuickResponse response = await equipmentApi.createQuickBranch(equipment);
        event.formData!.orderlineFormData!.equipment = response.id;
        event.formData!.orderlineFormData!.productController!.text = response.name!;

      } else {
        final EquipmentCreateQuickCustomer equipment = EquipmentCreateQuickCustomer(
          name: event.formData!.orderlineFormData!.typeAheadControllerEquipment!.text.trim(),
          customer: submodel == 'planning_user' ? event.formData!.customerPk : 0,
        );

        final EquipmentCreateQuickResponse response = await equipmentApi.createQuickCustomer(equipment);
        event.formData!.orderlineFormData!.equipment = response.id;
        event.formData!.orderlineFormData!.productController!.text = response.name!;
      }

      event.formData!.isCreatingEquipment = false;
      emit(OrderNewEquipmentCreatedState(formData: event.formData));
    } catch(e) {
      event.formData!.error = e.toString();
      emit(OrderErrorSnackbarState(message: e.toString()));
      event.formData!.isCreatingEquipment = false;
      emit(OrderLoadedState(formData: event.formData));
    }
  }

  Future<void> _handleCreateSelectEquipmentLocation(OrderEvent event, Emitter<OrderState> emit) async {
    final bool hasBranches = (await coreUtils.getHasBranches())!;
    final String? submodel = await coreUtils.getUserSubmodel();

    try {
      if (hasBranches) {
        final EquipmentLocationCreateQuickBranch location = EquipmentLocationCreateQuickBranch(
          name: event.formData!.orderlineFormData!.typeAheadControllerEquipmentLocation!.text.trim(),
          branch: submodel == 'planning_user' ? event.formData!.branch : 0,
        );

        final EquipmentLocationCreateQuickResponse response = await locationApi.createQuickBranch(location);
        event.formData!.orderlineFormData!.equipmentLocation = response.id;
        event.formData!.orderlineFormData!.locationController!.text = response.name!;

      } else {
        final EquipmentLocationCreateQuickCustomer location = EquipmentLocationCreateQuickCustomer(
          name: event.formData!.orderlineFormData!.typeAheadControllerEquipmentLocation!.text.trim(),
          customer: submodel == 'planning_user' ? event.formData!.customerPk : 0,
        );

        final EquipmentLocationCreateQuickResponse response = await locationApi.createQuickCustomer(location);
        event.formData!.orderlineFormData!.equipmentLocation = response.id;
        event.formData!.orderlineFormData!.locationController!.text = response.name!;
      }

      event.formData!.isCreatingLocation = false;
      emit(OrderNewLocationCreatedState(formData: event.formData));
    } catch(e) {
      event.formData!.error = e.toString();
      emit(OrderErrorSnackbarState(message: e.toString()));
      event.formData!.isCreatingLocation = false;
      emit(OrderLoadedState(formData: event.formData));
    }
  }

  Future<FormData> addQuickCreateSettings(FormData data) async {
    final Map<String, dynamic> memberSettings = (await privateMemberApi.fetchSettings())!;

    data.quickCreateSettings = QuickCreateSettings(
        equipmentPlanningQuickCreate: memberSettings['equipment_planning_quick_create'],
        equipmentQuickCreate: memberSettings['equipment_quick_create'],
        equipmentLocationPlanningQuickCreate: memberSettings['equipment_location_planning_quick_create'],
        equipmentLocationQuickCreate: memberSettings['equipment_location_quick_create']
    );

    return data;
  }

  void _handleDoAsyncState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderLoadingState());
  }

  void _handleNavDocumentsState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderNavDocumentsState(orderPk: event.pk!));
  }

  void _handleNavDetailState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderNavDetailState(orderPk: event.pk!));
  }

  void _handleDoSearchState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderSearchState());
  }

  void _handleDoRefreshState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderRefreshState());
  }

  FormData createFromModel(Order order, OrderTypes orderTypes) {
    throw UnimplementedError("create from model should be implemented");
  }

  Future<void> _handleFetchState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final OrderTypes orderTypes = await api.fetchOrderTypes();
      final bool hasBranches = (await coreUtils.getHasBranches())!;
      final Order order = await api.detail(event.pk!);

      FormData formData = createFromModel(order, orderTypes);
      formData = await addQuickCreateSettings(formData);

      // fetch locations for branches
      if (hasBranches) {
        formData.locations = await locationApi.fetchLocationsForSelect(branch: formData.branch);
        if (formData.locations!.isNotEmpty) {
          formData.orderlineFormData!.equipmentLocation = formData.locations![0].id;
        }
      }

      emit(OrderLoadedState(formData: formData));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchViewState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.detail(event.pk!);
      emit(OrderLoadedViewState(order: order));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchAllState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.list(filters: {
        'order_by': '-start_date',
        'q': event.query,
        'page': event.page
      });
      emit(OrdersLoadedState(
          orders: orders,
          query: event.query,
          page: event.page
      ));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnacceptedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchUnaccepted(
          page: event.page,
          query: event.query);
      emit(OrdersUnacceptedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPastState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchOrdersPast(
          page: event.page,
          query: event.query);
      emit(OrdersPastLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.insert(event.order!);

      // insert orderlines
      for (int i=0; i<event.orderLines!.length; i++) {
        event.orderLines![i].order = order.id;
        Orderline orderline = await orderlineApi.insert(event.orderLines![i]);
        order.orderLines!.add(orderline);
      }

      // insert infolines
      for (int i=0; i<event.infoLines!.length; i++) {
        event.infoLines![i].order = order.id;
        Infoline infoline = await infolineApi.insert(event.infoLines![i]);
        order.infoLines!.add(infoline);
      }

      emit(OrderInsertedState(order: order));
    } catch(e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.update(event.pk!, event.order!);

      // handle orderlines
      for (int i=0; i<event.deletedOrderLines!.length; i++) {
        if (event.deletedOrderLines![i].id != null) {
          orderlineApi.delete(event.deletedOrderLines![i].id!);
        }
      }

      for (int i=0; i<event.orderLines!.length; i++) {
        if (event.orderLines![i].id == null) {
          if (event.orderLines![i].order == null) {
            event.orderLines![i].order = event.pk;
          }
          await orderlineApi.insert(event.orderLines![i]);
        } else {
          // update but we haven't got that yet
          if (event.orderLines![i].order == null) {
            event.orderLines![i].order = event.pk;
          }
          await orderlineApi.update(event.orderLines![i].id!, event.orderLines![i]);
        }
      }

      // handle infolines
      for (int i=0; i<event.deletedInfoLines!.length; i++) {
        if (event.deletedInfoLines![i].id != null) {
          infolineApi.delete(event.deletedInfoLines![i].id!);
        }
      }

      for (int i=0; i<event.infoLines!.length; i++) {
        if (event.infoLines![i].id == null) {
          if (event.infoLines![i].order == null) {
            event.infoLines![i].order = event.pk;
          }
          await infolineApi.insert(event.infoLines![i]);
        } else {
          // update but we haven't got that yet
          if (event.infoLines![i].order == null) {
            event.infoLines![i].order = event.pk;
          }
          await infolineApi.update(event.infoLines![i].id!, event.infoLines![i]);
        }
      }

      emit(OrderUpdatedState(order: order));
    } catch(e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(OrderDeletedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAcceptState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.acceptOrder(event.pk!);
      emit(OrderAcceptedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleRejectState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.rejectOrder(event.pk!);
      emit(OrderRejectedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
}
