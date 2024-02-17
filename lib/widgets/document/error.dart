import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

class OrderDocumentListErrorWidget extends BaseErrorWidget {
  final int? orderId;

  const OrderDocumentListErrorWidget({
    super.key,
    required super.error,
    required super.memberPicture,
    required this.orderId,
    required super.widgetsIn,
    required super.i18nIn,
  });

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }
}
