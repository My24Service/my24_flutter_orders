import 'package:my24_flutter_core/models/models.dart';

import '../../blocs/order_bloc.dart';

void doRefreshCommon(dynamic bloc, OrderEventStatus fetchEvent) {
  bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
  bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
  bloc.add(OrderEvent(status: fetchEvent));
}

handleNew(dynamic bloc) {
  bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
  bloc.add(OrderEvent(
      status: OrderEventStatus.NEW
  ));
}

nextPage(dynamic bloc, OrderEventStatus fetchEvent, PaginationInfo paginationInfo, String searchText) {
  bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
  bloc.add(OrderEvent(
    status: fetchEvent,
    page: paginationInfo.currentPage! + 1,
    query: searchText,
  ));
}

previousPage(dynamic bloc, OrderEventStatus fetchEvent, PaginationInfo paginationInfo, String searchText) {
  bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
  bloc.add(OrderEvent(
    status: fetchEvent,
    page: paginationInfo.currentPage! - 1,
    query: searchText,
  ));
}

doSearch(dynamic bloc, OrderEventStatus fetchEvent, String searchText) {
  bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
  bloc.add(OrderEvent(status: OrderEventStatus.DO_SEARCH));
  bloc.add(OrderEvent(
      status: fetchEvent,
      query: searchText,
      page: 1
  ));
}
