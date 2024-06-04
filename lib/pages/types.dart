import 'package:flutter/material.dart';

import '../blocs/order_bloc.dart';

// function definitions that are used by apps because they have their own implementation of pages
typedef NavFormFunction = void Function(BuildContext context, int? orderPk, OrderEventStatus fetchMode);
typedef NavFormFromEquipmentFunction = void Function(BuildContext context, String uuid, String orderType);
typedef NavDetailFunction = void Function(BuildContext context, int orderPk);
typedef NavListFunction = void Function(BuildContext context, OrderEventStatus fetchMode);
typedef NavAssignFunction = void Function(BuildContext context, int orderPk);
