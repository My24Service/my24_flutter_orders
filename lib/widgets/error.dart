import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../models/order/models.dart';

class OrderListErrorWidget extends BaseErrorWidget  {
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
  String getAppBarTitle(BuildContext context) {
    return i18nIn.$trans('list.app_bar_title_error');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }
}
