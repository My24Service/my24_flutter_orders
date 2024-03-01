import 'package:flutter/material.dart';

import '../blocs/order_bloc.dart';

typedef NavFormFunction = void Function(BuildContext context, int? orderPk, OrderEventStatus fetchMode);
typedef NavDetailFunction = void Function(BuildContext context, int orderPk);
typedef NavListFunction = void Function(BuildContext context, OrderEventStatus fetchMode);
