import 'package:equatable/equatable.dart';

import '../models/orderline/form_data.dart';

abstract class OrderLineBaseState extends Equatable {}

class OrderLineInitialState extends OrderLineBaseState {
  @override
  List<Object?> get props => [];
}

class OrderLineLoadedState extends OrderLineBaseState {
  final OrderlineFormData formData;

  OrderLineLoadedState({
    required this.formData
  });

  @override
  List<Object?> get props => [formData];
}

class OrderLineNewFormDataState extends OrderLineBaseState {
  final OrderlineFormData formData;

  OrderLineNewFormDataState({
    required this.formData
  });

  @override
  List<Object?> get props => [formData];
}

class OrderLineNewEquipmentCreatedState extends OrderLineBaseState {
  final OrderlineFormData formData;

  OrderLineNewEquipmentCreatedState({
    required this.formData
  });

  @override
  List<Object?> get props => [formData];
}

class OrderLineNewLocationCreatedState extends OrderLineBaseState {
  final OrderlineFormData formData;

  OrderLineNewLocationCreatedState({
    required this.formData
  });

  @override
  List<Object?> get props => [formData];
}

class OrderLineErrorSnackbarState extends OrderLineBaseState {
  final String? message;

  OrderLineErrorSnackbarState({this.message});

  @override
  List<Object?> get props => [message];
}

class OrderLineLoadingState extends OrderLineBaseState {
  @override
  List<Object> get props => [];
}
