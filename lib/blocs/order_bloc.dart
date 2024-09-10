import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/order/api.dart';
import '../blocs/order_states.dart';
import '../models/order/models.dart';
import '../models/order/form_data.dart';

final log = Logger('orders.blocs.order_bloc');

enum OrderEventStatus {
  doAsync,
  doSearch,
  doRefresh,
  fetchAll,
  fetchDetailView,
  fetchUnaccepted,
  fetchUnassigned,
  fetchSales,
  fetchPast,
  assignMe,

  delete,
}

class OrderEvent {
  final OrderEventStatus? status;
  final int? pk;
  final int? page;
  final String? query;
  final Order? order;

  const OrderEvent({
    this.pk,
    this.status,
    this.page,
    this.query,
    this.order,
  });
}

class OrderBloc<FormData extends BaseOrderFormData> extends Bloc<OrderEvent, OrderState> {
  OrderApi api = OrderApi();

  OrderBloc() : super(OrderInitialState()) {
    on<OrderEvent>((event, emit) async {
      if (event.status == OrderEventStatus.doAsync) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == OrderEventStatus.doSearch) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == OrderEventStatus.doRefresh) {
        _handleDoRefreshState(event, emit);
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
      else if (event.status == OrderEventStatus.delete) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == OrderEventStatus.fetchUnassigned) {
        await _handleFetchUnassignedState(event, emit);
      }
      else if (event.status == OrderEventStatus.fetchSales) {
        await _handleFetchSalesState(event, emit);
      }
      else if (event.status == OrderEventStatus.assignMe) {
        await _handleAssignMeState(event, emit);
      }

    },
    transformer: sequential());
  }

  Future<void> _handleAssignMeState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.doAssignMe(event.pk!);
      emit(OrderAssignedMeState(result: result));
    } catch(e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  void _handleDoAsyncState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderLoadingState());
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

  Future<void> _handleFetchViewState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.detail(event.pk!);
      emit(OrderLoadedViewState(order: order));
    } catch (e, stack_trace) {
      log.severe("fetch detail error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchAllState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.list(filters: {
        'q': event.query,
        'page': event.page
      });
      emit(OrdersLoadedState(
          orders: orders,
          query: event.query,
          page: event.page
      ));
    } catch (e, stack_trace) {
      log.severe("fetch all error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnacceptedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchUnaccepted(
          page: event.page,
          query: event.query);
      emit(OrdersUnacceptedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e, stack_trace) {
      log.severe("fetch unaccepted error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPastState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchOrdersPast(
          page: event.page,
          query: event.query);
      emit(OrdersPastLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e, stack_trace) {
      log.severe("fetch past error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchSalesState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchSalesOrders(
          page: event.page,
          query: event.query);
      emit(OrdersSalesLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e, stack_trace) {
      log.severe("fetch sales error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnassignedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchOrdersUnAssigned(
          page: event.page,
          query: event.query);
      emit(OrdersUnassignedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e, stack_trace) {
      log.severe("fetch unassigned error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(OrderDeletedState(result: result));
    } catch (e, stack_trace) {
      log.severe("delete error: $e\n$stack_trace");
      emit(OrderErrorState(message: e.toString()));
    }
  }
}
