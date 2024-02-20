import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../blocs/order_bloc.dart';

abstract class BaseAfterCreateButtonsWidget<BlocClass extends OrderBlocBase> extends BaseEmptyWidget {
  final int orderPk;

  const BaseAfterCreateButtonsWidget({
    Key? key,
    String? memberPicture,
    required CoreWidgets widgetsIn,
    required My24i18n i18nIn,
    required this.orderPk
  }) : super(
      key: key,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: i18nIn
  );

  void navOrders(BuildContext context);
  void navDocuments(BuildContext context, int orderPk);

  @override
  String getAppBarTitle(BuildContext context) {
    return i18n.$trans('after_create.app_bar_title');
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Row(
      children: [
        widgets.createDefaultElevatedButton(
          context,
          i18n.$trans('after_create.order_list'),
          () { navOrders(context); }
        ),
        const SizedBox(width: 10),
        widgets.createDefaultElevatedButton(
            context,
            i18n.$trans('after_create.add_document'),
            () { navDocuments(context, orderPk); }
        )
      ],
    );
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }
}
