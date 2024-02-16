import 'package:equatable/equatable.dart';

import '../models/order/models.dart';

abstract class OrderState extends Equatable {}

class OrderInitialState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderNavDocumentsState extends OrderState {
  final int orderPk;

  OrderNavDocumentsState({ required this.orderPk });

  @override
  List<Object> get props => [];
}

class OrderNavDetailState extends OrderState {
  final int orderPk;

  OrderNavDetailState({ required this.orderPk });

  @override
  List<Object> get props => [];
}

class OrderLoadingState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderSearchState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderRefreshState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderErrorState extends OrderState {
  final String? message;

  OrderErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class OrderErrorSnackbarState extends OrderState {
  final String? message;

  OrderErrorSnackbarState({this.message});

  @override
  List<Object?> get props => [message];
}

class OrderLoadedState extends OrderState {
  final dynamic formData;

  OrderLoadedState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class OrderLoadedViewState extends OrderState {
  final Order? order;

  OrderLoadedViewState({this.order});

  @override
  List<Object?> get props => [order];
}

class OrderNewState extends OrderState {
  final dynamic formData;

  OrderNewState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class OrderNewEquipmentCreatedState extends OrderState {
  final dynamic formData;

  OrderNewEquipmentCreatedState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class OrderNewLocationCreatedState extends OrderState {
  final dynamic formData;

  OrderNewLocationCreatedState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class OrdersLoadedState extends OrderState {
  final Orders? orders;
  final String? query;
  final int? page;

  OrdersLoadedState({this.orders, this.query, this.page});

  @override
  List<Object?> get props => [orders, query, page];
}

class OrdersUnacceptedLoadedState extends OrderState {
  final Orders? orders;
  final String? query;
  final int? page;

  OrdersUnacceptedLoadedState({this.orders, this.query, this.page});

  @override
  List<Object?> get props => [orders, query, page];
}

class OrdersPastLoadedState extends OrderState {
  final Orders? orders;
  final String? query;
  final int? page;

  OrdersPastLoadedState({this.orders, this.query, this.page});

  @override
  List<Object?> get props => [orders, query, page];
}

class OrderDeletedState extends OrderState {
  final bool? result;

  OrderDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class OrderUpdatedState extends OrderState {
  final Order? order;

  OrderUpdatedState({this.order});

  @override
  List<Object?> get props => [order];
}

class OrderInsertedState extends OrderState {
  final Order? order;

  OrderInsertedState({this.order});

  @override
  List<Object?> get props => [order];
}

class OrderAcceptedState extends OrderState {
  final bool? result;

  OrderAcceptedState({this.result});

  @override
  List<Object?> get props => [result];
}

class OrderRejectedState extends OrderState {
  final bool? result;

  OrderRejectedState({this.result});

  @override
  List<Object?> get props => [result];
}