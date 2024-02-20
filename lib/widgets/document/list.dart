import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import '../../blocs/document_bloc.dart';
import '../../blocs/order_bloc.dart';
import '../../models/document/models.dart';

abstract class BaseOrderDocumentListWidget<BlocClass extends OrderBlocBase> extends BaseSliverListStatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final OrderDocuments? orderDocuments;
  final int orderId;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final CoreUtils utils = CoreUtils();

  BaseOrderDocumentListWidget({
    Key? key,
    required this.orderDocuments,
    required this.orderId,
    required super.paginationInfo,
    required super.memberPicture,
    required this.searchQuery,
    required this.widgetsIn,
    required super.i18n,
  }) : super(
      key: key,
      widgets: widgetsIn,
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return i18n.$trans('app_bar_subtitle',
        namedArgs: {'count': "${orderDocuments!.count}"}
    );
  }

  void navDetail(BuildContext context);

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return widgetsIn.createDefaultElevatedButton(
                context,
                i18n.$trans('nav_order'),
                () { navDetail(context); }
            );
          },
          childCount: 1,
        )
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            OrderDocument document = orderDocuments!.results![index];

            return Column(
              children: [
                ...widgetsIn.buildItemListKeyValueList(i18n.$trans('name'),
                    document.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widgetsIn.createViewButton(
                        () async {
                          String url = await utils.getUrl(document.url);
                          url = url.replaceAll('/api', '');

                          Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                          if (!openResult['result'] && context.mounted) {
                            widgetsIn.createSnackBar(
                              context,
                              i18n.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic')
                            );
                          }
                        }
                    ),
                    const SizedBox(width: 8),
                    widgetsIn.createEditButton(
                        () => { _doEdit(context, document) }
                    ),
                    const SizedBox(width: 10),
                    widgetsIn.createDeleteButton(
                            () { _showDeleteDialog(context, document); }
                    ),
                  ],
                ),
                if (index < orderDocuments!.results!.length-1)
                  widgetsIn.getMy24Divider(context)
              ],
            );
          },
          childCount: orderDocuments!.results!.length,
        )
    );
  }

  // private methods
  _doDelete(BuildContext context, OrderDocument document) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.delete,
        pk: document.id,
        orderId: orderId
    ));
  }

  _doEdit(BuildContext context, OrderDocument document) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.fetchDetail,
        pk: document.id
    ));
  }

  _showDeleteDialog(BuildContext context, OrderDocument document) {
    widgetsIn.showDeleteDialogWrapper(
        i18n.$trans('delete_dialog_title'),
        i18n.$trans('delete_dialog_content'),
        () => _doDelete(context, document),
        context
    );
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.fetchAll,
        orderId: orderId
    ));
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return widgets.showPaginationSearchNewSection(
      context,
      paginationInfo,
      searchController,
      _nextPage,
      _previousPage,
      _doSearch,
      _handleNew,
    );
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.newDocument,
        orderId: orderId
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
      status: OrderDocumentEventStatus.fetchAll,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
      status: OrderDocumentEventStatus.fetchAll,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doSearch));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.fetchAll,
        query: searchController.text,
        page: 1,
        orderId: orderId
    ));
  }
}
