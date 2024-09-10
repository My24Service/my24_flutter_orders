import 'package:flutter/material.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../models/order/models.dart';

class OrderDetailWidget extends BaseSliverPlainStatelessWidget {
  final OrderPageMetaData orderPageMetaData;
  final Order? order;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "orders");
  final CoreUtils utils = CoreUtils();

  OrderDetailWidget({
    Key? key,
    required this.order,
    required this.orderPageMetaData,
    required this.widgetsIn,
  }) : super(
      key: key,
      mainMemberPicture: orderPageMetaData.memberPicture,
      widgets: widgetsIn,
      i18n: My24i18n(basePath: "orders")
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return i18nIn.$trans('detail.app_bar_title');
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "${order!.orderId} ${order!.orderName} ${order!.orderDate}";
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Column(
        children: [
            // createHeader(i18nIn.$trans('info_order')),
            widgetsIn.buildOrderInfoCard(context, order!, isCustomer: _isCustomer()),
            if (!_isCustomer() && order!.parentOrderData != null)
              _createParentOrderDataSection(context),
            if (!_isCustomer() && order!.parentOrderData != null)
              widgetsIn.getMy24Divider(context),
            if (!_isCustomer() && order!.copiedOrderData != null)
              _createCopiedOrderDataSection(context),
            if (!orderPageMetaData.hasBranches!)
              _createAssignedInfoSection(context),
            _createOrderlinesSection(context),
            if (!_isCustomerOrBranch())
              _createInfolinesSection(context),
            _buildDocumentsSection(context),
            _buildWorkorderDocumentsSection(context),
            _createStatusSection(context),
            _createWorkorderWidget(context),
          ]
    );
  }

  bool _isCustomerOrBranch() {
    return orderPageMetaData.submodel == 'customer_user' || orderPageMetaData.hasBranches!;
  }

  bool _isCustomer() {
    return orderPageMetaData.submodel == 'customer_user';
  }

  Widget _createWorkorderWidget(BuildContext context) {
    if (orderPageMetaData.hasBranches!) {
      final DataTable table = _createWorkorderPdfsPartnerSection(context);
      return Center(
          child: table
      );
    }
    
    Widget result = widgetsIn.createViewWorkOrderButton(
        order!.workorderPdfUrl, context);
    Widget resultPartner = _createWorkorderPdfsPartnerSection(context);

    return Center(
        child: Column(
          children: [
            result,
            const SizedBox(height: 10),
            resultPartner
          ],
        )
    );
  }

  DataTable _createWorkorderPdfsPartnerSection(BuildContext context) {
    final List<String> headerKeys = [
      i18nIn.$trans('info_partner', pathOverride: 'generic'),
      ""
    ];

    final List<DataColumn> header = headerKeys.map((key) =>
        DataColumn(
          label: Expanded(
            child: Text(
              key,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        )
    ).toList();

    final List<DataRow> rows = order!.workorderPdfsUrlPartner!.map((m) =>
        DataRow(
          cells: <DataCell>[
            DataCell(Text("${m.companycode}")),
            DataCell(widgetsIn.createViewWorkOrderPartnerButton(m.url, context)),
          ],
        )).toList();

    return DataTable(
        columns: header,
        rows: rows
    );
  }

  Widget _createAssignedInfoSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_assigned_users_info'),
        order!.assignedUserInfo,
        (item) {
          String? value = item.fullName;
          if (item.licensePlate != null && item.licensePlate != "") {
            value = "$value (${i18nIn.$trans('info_license_plate')}: ${item.licensePlate})";
          }
          return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_name', pathOverride: 'generic'), value);
        },
        (item) {
          return <Widget>[];
        },
        noResultsString: i18nIn.$trans('info_no_one_else_assigned', pathOverride: 'assigned_orders.detail')
    );
  }

  Widget _createCopiedOrderDataSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_copied_orders'),
        order!.copiedOrderData,
        (RelatedOrderModel item) {
          return <Widget>[
            ...widgetsIn.buildItemListKeyValueList(
              i18nIn.$trans('info_partner', pathOverride: 'generic'),
              item.companycode
            ),
            ...widgetsIn.buildItemListKeyValueList(
              i18nIn.$trans('info_order_id'),
              item.orderId
            )
          ];
        },
        (item) {
          return <Widget>[];
        },
        noResultsString: i18nIn.$trans('info_no_copied_orders')
    );
  }

  Widget _createParentOrderDataSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_original_order'),
        [order!.parentOrderData],
        (RelatedOrderModel item) {
          return <Widget>[
            ...widgetsIn.buildItemListKeyValueList(
                i18nIn.$trans('info_partner', pathOverride: 'generic'),
                item.companycode
            ),
            ...widgetsIn.buildItemListKeyValueList(
                i18nIn.$trans('info_order_id'),
                item.orderId
            )
          ];
        },
            (item) {
          return <Widget>[];
        },
        noResultsString: i18nIn.$trans('info_no_parent_order')
    );
  }

  // order lines
  Widget _createOrderlinesSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_orderlines'),
      order!.orderLines,
      (item) {
        String equipmentLocationTitle = "${i18nIn.$trans('info_equipment', pathOverride: 'generic')} / ${i18nIn.$trans('info_location', pathOverride: 'generic')}";
        String equipmentLocationValue = "${item.product?? '-'} / ${item.location?? '-'}";
        return <Widget>[
          ...widgetsIn.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          if (item.remarks != null && item.remarks != "")
            ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_remarks', pathOverride: 'generic'), item.remarks)
        ];
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // info lines
  Widget _createInfolinesSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_infolines'),
      order!.infoLines,
      (item) {
        return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_infoline'), item.info);
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // documents
  Widget _buildDocumentsSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_documents'),
      order!.documents,
      (item) {
        String nameDescKey = My24i18n.tr('generic.info_name');
        String? nameDescValue = item.name;
        if (item.description != null && item.description != "") {
          nameDescValue = "$nameDescValue (${item.description})";
        }

        return widgetsIn.buildItemListKeyValueList(nameDescKey, nameDescValue);
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widgetsIn.createViewButton(
                  () async {
                    String url = await utils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                    if (!openResult['result'] && context.mounted) {
                      widgetsIn.createSnackBar(
                        context,
                        i18nIn.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic')
                      );
                    }
                  }
              ),
            ],
          )
        ];
      },
    );
  }

  // workorder documents
  Widget _buildWorkorderDocumentsSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_workorder_documents'),
      order!.workorderDocuments,
      (WorkOrderDocument item) {
        return <Widget>[
          ...widgetsIn.buildItemListKeyValueList(
              My24i18n.tr('generic.info_name'),
              item.name
          ),
        ];
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widgetsIn.createViewButton(
                () async {
                    String url = await utils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                    if (!openResult['result'] && context.mounted) {
                      widgetsIn.createSnackBar(
                        context,
                        i18nIn.$trans(
                            'error_arg', namedArgs: {'error': openResult['message']},
                            pathOverride: 'generic'
                        )
                      );
                    }
                  }
              ),
            ],
          )
        ];
      },
    );
  }

  Widget _createStatusSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_status_history'),
        order!.statuses,
        (item) {
          return <Widget>[Text("${item.created} ${item.status}")];
        },
        (item) {
          return <Widget>[];
        },
        withDivider: false
    );
  }
}
