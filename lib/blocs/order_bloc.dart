import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/order/api.dart';
import '../blocs/order_states.dart';
import '../models/order/models.dart';
import '../models/order/form_data.dart';

enum OrderEventStatus {
  doAsync,
  doSearch,
  doRefresh,
  fetchAll,
  fetchDetailView,
  fetchUnaccepted,
  fetchPast,

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
    },
    transformer: sequential());
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

  Future<void> _handleDeleteState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(OrderDeletedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
}
