import 'package:my24_flutter_core/models/models.dart';

import '../../blocs/order_bloc.dart';

void doRefreshCommon(dynamic bloc, OrderEventStatus fetchEvent) {
  bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
  bloc.add(const OrderEvent(status: OrderEventStatus.doRefresh));
  bloc.add(OrderEvent(status: fetchEvent));
}

handleNew(dynamic bloc) {
  bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
  bloc.add(const OrderEvent(
      status: OrderEventStatus.newOrder
  ));
}

nextPage(dynamic bloc, OrderEventStatus fetchEvent, PaginationInfo paginationInfo, String searchText) {
  bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
  bloc.add(OrderEvent(
    status: fetchEvent,
    page: paginationInfo.currentPage! + 1,
    query: searchText,
  ));
}

previousPage(dynamic bloc, OrderEventStatus fetchEvent, PaginationInfo paginationInfo, String searchText) {
  bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
  bloc.add(OrderEvent(
    status: fetchEvent,
    page: paginationInfo.currentPage! - 1,
    query: searchText,
  ));
}

doSearch(dynamic bloc, OrderEventStatus fetchEvent, String searchText) {
  bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
  bloc.add(const OrderEvent(status: OrderEventStatus.doSearch));
  bloc.add(OrderEvent(
      status: fetchEvent,
      query: searchText,
      page: 1
  ));
}
