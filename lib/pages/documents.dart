import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import '../blocs/document_bloc.dart';
import '../blocs/document_states.dart';
import '../blocs/order_bloc.dart';
import '../widgets/document/error.dart';
import '../widgets/document/form.dart';
import '../widgets/document/list.dart';
import '../models/document/models.dart';
import '../models/order/api.dart';
import '../models/order/models.dart';

String? initialLoadMode;
int? loadId;
bool customerOrderAccepted = false;

abstract class BaseOrderDocumentsPage extends StatelessWidget {
  final int? orderId;
  final i18n = My24i18n(basePath: "orders.documents");
  final OrderDocumentBloc bloc;
  final CoreUtils utils = CoreUtils();
  final OrderApi api = OrderApi();
  final CoreWidgets widgets = CoreWidgets();

  BaseOrderDocumentsPage({
    Key? key,
    required this.orderId,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  Future<OrderDocumentPageData> getPageData() async {
    Order order = await api.detail(orderId!);
    String? memberPicture = await utils.getMemberPicture();

    OrderDocumentPageData result = OrderDocumentPageData(
      memberPicture: memberPicture,
      order: order
    );

    return result;
  }

  OrderDocumentBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    } else if (initialLoadMode == 'form') {
      bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.NEW,
          orderId: orderId
      ));
    }

    return bloc;
  }

  void navOrders(BuildContext context, OrderEventStatus fetchMode);

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (boolIn) {
          if (customerOrderAccepted) {
            navOrders(context, OrderEventStatus.FETCH_ALL);
          } else {
            navOrders(context, OrderEventStatus.FETCH_UNACCEPTED);
          }

          return;
        },
        child: FutureBuilder<OrderDocumentPageData>(
          future: getPageData(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              OrderDocumentPageData pageData = snapshot.data!;
              customerOrderAccepted = pageData.order!.customerOrderAccepted!;

              return BlocProvider<OrderDocumentBloc>(
                  create: (context) => _initialBlocCall(),
                  child: BlocConsumer<OrderDocumentBloc, OrderDocumentState>(
                      listener: (context, state) {
                        _handleListeners(context, state);
                      },
                      builder: (context, state) {
                        return Scaffold(
                            body: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: _getBody(context, state, pageData),
                            )
                        );
                      }
                  )
              );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      i18n.$trans("error_arg", pathOverride: "generic",
                          namedArgs: {"error": "${snapshot.error}"}
                      )
                  )
              );
            } else {
              return Scaffold(
                  body: widgets.loadingNotice()
              );
            }
          }
      )
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    if (state is OrderDocumentInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    }

    if (state is OrderDocumentUpdatedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_updated'));

      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    }

    if (state is OrderDocumentDeletedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_deleted'));

      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    }

    if (state is OrderDocumentsLoadedState && state.query == null && state.documents!.results!.isEmpty) {
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.NEW_EMPTY,
          orderId: orderId
      ));
    }
  }

  Widget _getBody(context, state, OrderDocumentPageData pageData) {
    if (state is OrderDocumentInitialState) {
      return widgets.loadingNotice();
    }

    if (state is OrderDocumentLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is OrderDocumentErrorState) {
      return OrderDocumentListErrorWidget(
        error: state.message,
        orderId: orderId,
        memberPicture: pageData.memberPicture,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is OrderDocumentsLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.documents!.count,
          next: state.documents!.next,
          previous: state.documents!.previous,
          currentPage: state.page ?? 1,
          pageSize: 20
      );

      return OrderDocumentListWidget(
        orderDocuments: state.documents,
        orderId: orderId,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is OrderDocumentLoadedState) {
      return OrderDocumentFormWidget(
        formData: state.documentFormData,
        orderId: orderId,
        memberPicture: pageData.memberPicture,
        newFromEmpty: false,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is OrderDocumentNewState) {
      return OrderDocumentFormWidget(
        formData: state.documentFormData,
        orderId: orderId,
        memberPicture: pageData.memberPicture,
        newFromEmpty: state.fromEmpty,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}