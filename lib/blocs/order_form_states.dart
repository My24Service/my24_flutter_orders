import 'package:equatable/equatable.dart';

import '../models/order/models.dart';

abstract class OrderFormState extends Equatable {}

class OrderFormInitialState extends OrderFormState {
  @override
  List<Object> get props => [];
}

class OrderFormLoadingState extends OrderFormState {
  @override
  List<Object> get props => [];
}

class OrderFormNavListState extends OrderFormState {
  @override
  List<Object> get props => [];
}

class OrderFormErrorState extends OrderFormState {
  final String? message;

  OrderFormErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class OrderFormErrorSnackbarState extends OrderFormState {
  final String? message;

  OrderFormErrorSnackbarState({this.message});

  @override
  List<Object?> get props => [message];
}

class OrderLoadedState extends OrderFormState {
  final dynamic formData;

  OrderLoadedState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class OrderLineAddedState extends OrderFormState {
  OrderLineAddedState();

  @override
  List<Object?> get props => [];
}

class OrderLineRemovedState extends OrderFormState {
  OrderLineRemovedState();

  @override
  List<Object?> get props => [];
}

class InfoLineAddedState extends OrderFormState {
  InfoLineAddedState();

  @override
  List<Object?> get props => [];
}

class InfoLineRemovedState extends OrderFormState {
  InfoLineRemovedState();

  @override
  List<Object?> get props => [];
}

class DocumentAddedState extends OrderFormState {
  DocumentAddedState();

  @override
  List<Object?> get props => [];
}

class DocumentRemovedState extends OrderFormState {
  DocumentRemovedState();

  @override
  List<Object?> get props => [];
}

class OrderNewState extends OrderFormState {
  final dynamic formData;

  OrderNewState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class OrderUpdatedState extends OrderFormState {
  final Order? order;

  OrderUpdatedState({this.order});

  @override
  List<Object?> get props => [order];
}

class OrderInsertedState extends OrderFormState {
  final Order? order;

  OrderInsertedState({this.order});

  @override
  List<Object?> get props => [order];
}


class OrderAcceptedState extends OrderFormState {
  final bool? result;

  OrderAcceptedState({this.result});

  @override
  List<Object?> get props => [result];
}

class OrderRejectedState extends OrderFormState {
  final bool? result;

  OrderRejectedState({this.result});

  @override
  List<Object?> get props => [result];
}
