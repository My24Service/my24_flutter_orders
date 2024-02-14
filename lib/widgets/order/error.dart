import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../blocs/order_bloc.dart';
import '../../models/order/models.dart';

class OrderListErrorWidget<BlocClass extends OrderBlocBase> extends BaseErrorWidget  {
  final TextEditingController searchController = TextEditingController();

  OrderListErrorWidget({
    Key? key,
    required String error,
    required OrderPageMetaData orderPageMetaData,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn,
  }) : super(
      key: key,
      error: error,
      memberPicture: orderPageMetaData.memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: i18nIn,
  );

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }
}
