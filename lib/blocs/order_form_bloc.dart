import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_equipment/models/location/api.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_member_models/private/api.dart';

import '../models/document/api.dart';
import '../models/document/models.dart';
import '../models/order/api.dart';
import '../models/order/models.dart';
import '../models/infoline/api.dart';
import '../models/infoline/models.dart';
import '../models/order/form_data.dart';
import '../models/orderline/api.dart';
import '../models/orderline/models.dart';
import 'order_form_states.dart';

enum OrderFormEventStatus {
  doAsync,
  fetchDetail,
  newOrder,
  newOrderFromEquipmentCustomer,
  newOrderFromEquipmentBranch,
  update,
  insert,
  accept,
  reject,
  updateFormData,

  addOrderLine,
  removeOrderline,

  addInfoLine,
  removeInfoline,

  addDocument,
  removeDocument,
}

class OrderFormEvent {
  final OrderFormEventStatus? status;
  final int? pk;
  final String? equipmentUuid;
  final String? equipmentOrderType;
  final Order? order;
  final dynamic formData;

  final List<Orderline>? orderLines;
  final List<Orderline>? deletedOrderLines;

  final List<Infoline>? infoLines;
  final List<Infoline>? deletedInfoLines;

  final List<OrderDocument>? documents;
  final List<OrderDocument>? deletedDocuments;

  final List<Equipment>? equipmentLocationUpdates;

  final Orderline? orderline;
  final OrderDocument? document;
  final Infoline? infoline;

  const OrderFormEvent({
    this.pk,
    this.equipmentUuid,
    this.equipmentOrderType,
    this.status,
    this.order,
    this.formData,
    this.orderLines,
    this.infoLines,
    this.deletedOrderLines,
    this.deletedInfoLines,
    this.documents,
    this.deletedDocuments,
    this.equipmentLocationUpdates,
    this.orderline,
    this.infoline,
    this.document,
  });
}

abstract class OrderFormBlocBase<FormData extends BaseOrderFormData> extends Bloc<OrderFormEvent, OrderFormState> {
  OrderApi api = OrderApi();
  EquipmentLocationApi locationApi = EquipmentLocationApi();
  EquipmentApi equipmentApi = EquipmentApi();
  PrivateMemberApi privateMemberApi = PrivateMemberApi();
  OrderlineApi orderlineApi = OrderlineApi();
  InfolineApi infolineApi = InfolineApi();
  OrderDocumentApi orderDocumentApi = OrderDocumentApi();

  OrderFormBlocBase(OrderFormState initialState) : super(initialState);

  Future<void> handleEvent(event, emit) async {
    if (event.status == OrderFormEventStatus.doAsync) {
      _handleDoAsyncState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.fetchDetail) {
      await _handleFetchState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.insert) {
      await _handleInsertState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.update) {
      await _handleEditState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.updateFormData) {
      _handleUpdateFormDataState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.addOrderLine) {
      _handleAddOrderLineState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.removeOrderline) {
      _handleRemoveOrderlineState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.addInfoLine) {
      _handleAddInfoLineState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.removeInfoline) {
      _handleRemoveInfolineState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.addDocument) {
      _handleAddDocumentState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.removeDocument) {
      _handleRemoveDocumentState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.accept) {
      await _handleAcceptState(event, emit);
    }
    else if (event.status == OrderFormEventStatus.reject) {
      await _handleRejectState(event, emit);
    }
  }

  void _handleAddOrderLineState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    event.formData.orderLines!.add(event.orderline);

    emit(OrderLineAddedState());
    emit(OrderLoadedState(formData: event.formData));
  }

  void _handleRemoveOrderlineState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    if (event.orderline!.id != null && !event.formData.deletedOrderLines!.contains(event.orderline!)) {
      event.formData.deletedOrderLines!.add(event.orderline!);
    }
    event.formData.orderLines!.removeAt(event.formData.orderLines!.indexOf(event.orderline!));

    emit(OrderLineRemovedState());
    emit(OrderLoadedState(formData: event.formData));
  }

  void _handleAddInfoLineState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    event.formData.infoLines!.add(event.infoline);

    emit(InfoLineAddedState());
    emit(OrderLoadedState(formData: event.formData));
  }

  void _handleRemoveInfolineState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    if (event.infoline!.id != null && !event.formData.deletedInfolines!.contains(event.infoline!)) {
      event.formData.deletedInfolines!.add(event.infoline!);
    }
    event.formData.infoLines!.removeAt(event.formData.infoLines!.indexOf(event.infoline!));

    emit(InfoLineRemovedState());
    emit(OrderLoadedState(formData: event.formData));
  }

  void _handleAddDocumentState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    event.formData.documents!.add(event.document);

    emit(DocumentAddedState());
    emit(OrderLoadedState(formData: event.formData));
  }

  void _handleRemoveDocumentState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    if (event.document!.id != null && !event.formData.deletedDocuments!.contains(event.document!)) {
      event.formData.deletedDocuments!.add(event.document!);
    }

    event.formData.documents!.removeAt(event.formData.documents!.indexOf(event.document!));

    emit(DocumentRemovedState());
    emit(OrderLoadedState(formData: event.formData));
  }

  void _handleUpdateFormDataState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    emit(OrderLoadedState(formData: event.formData));
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

  void _handleDoAsyncState(OrderFormEvent event, Emitter<OrderFormState> emit) {
    emit(OrderFormLoadingState());
  }

  FormData createFromModel(Order order, OrderTypes orderTypes) {
    throw UnimplementedError("create from model should be implemented");
  }

  Future<void> _handleFetchState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
    try {
      final OrderTypes orderTypes = await api.fetchOrderTypes();
      final Order order = await api.detail(event.pk!);

      // when an order type gets deleted, this will cause an error in the from
      // that the value doesn't exist
      if (!orderTypes.orderTypes!.contains(order.orderType)) {
        order.orderType = null;
      }

      FormData formData = createFromModel(order, orderTypes);
      formData = await addQuickCreateSettings(formData);

      emit(OrderLoadedState(formData: formData));
    } catch (e) {
      emit(OrderFormErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
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

      // add documents
      for (int i=0; i<event.documents!.length; i++) {
        event.documents![i].orderId = order.id;
        OrderDocument document = await orderDocumentApi.insert(event.documents![i]);
        order.documents!.add(document);
      }

      // handle equipment location updates
      if (event.equipmentLocationUpdates != null) {
        for (int i = 0; i < event.equipmentLocationUpdates!.length; i++) {
          await equipmentApi.update(event.equipmentLocationUpdates![i].id!,
              event.equipmentLocationUpdates![i]);
        }
      }

      emit(OrderInsertedState(order: order));
    } catch(e) {
      emit(OrderFormErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
    try {
      final Order order = await api.update(event.pk!, event.order!);

      // handle orderlines
      for (int i=0; i<event.deletedOrderLines!.length; i++) {
        if (event.deletedOrderLines![i].id != null) {
          orderlineApi.delete(event.deletedOrderLines![i].id!);
        }
      }

      for (int i=0; i<event.orderLines!.length; i++) {
        log.info('orderline.id: ${event.orderLines![i].id}');
        if (event.orderLines![i].id == null) {
          if (event.orderLines![i].order == null) {
            event.orderLines![i].order = event.pk;
          }
          await orderlineApi.insert(event.orderLines![i]);
        } else {
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

      // handle documents
      for (int i=0; i<event.deletedDocuments!.length; i++) {
        if (event.deletedDocuments![i].id != null) {
          orderDocumentApi.delete(event.deletedDocuments![i].id!);
        }
      }

      for (int i=0; i<event.documents!.length; i++) {
        if (event.documents![i].id == null) {
          if (event.documents![i].orderId == null) {
            event.documents![i].orderId = event.pk;
          }
          await orderDocumentApi.insert(event.documents![i]);
        } else {
          if (event.documents![i].orderId == null) {
            event.documents![i].orderId = event.pk;
          }
          await orderDocumentApi.update(event.documents![i].id!, event.documents![i]);
        }
      }

      // handle equipment location updates
      if (event.equipmentLocationUpdates != null) {
        for (int i=0; i<event.equipmentLocationUpdates!.length; i++) {
          await equipmentApi.update(event.equipmentLocationUpdates![i].id!, event.equipmentLocationUpdates![i]);
        }
      }

      emit(OrderUpdatedState(order: order));
    } catch(e) {
      emit(OrderFormErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAcceptState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
    try {
      final bool result = await api.acceptOrder(event.pk!);
      emit(OrderAcceptedState(result: result));
    } catch (e) {
      emit(OrderFormErrorState(message: e.toString()));
    }
  }

  Future<void> _handleRejectState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
    try {
      final bool result = await api.rejectOrder(event.pk!);
      emit(OrderRejectedState(result: result));
    } catch (e) {
      emit(OrderFormErrorState(message: e.toString()));
    }
  }
}
