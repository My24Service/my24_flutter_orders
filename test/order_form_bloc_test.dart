import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24_flutter_orders/blocs/order_form_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_form_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'fixtures.dart';
import 'order_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch order detail', () async {
    final client = MockClient();
    final OrderFormBloc orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;
    orderFormBloc.locationApi.httpClient = client;
    orderFormBloc.equipmentApi.httpClient = client;
    orderFormBloc.privateMemberApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(order, 200));

    // return order types data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/order_types/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(orderTypes, 200));

    // return member settings data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/member/get_my_settings/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberSettings, 200));

    orderFormBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderLoadedState>());
        expect(event.props[0], isA<OrderFormData>());
      })
    );

    expectLater(orderFormBloc.stream, emits(isA<OrderLoadedState>()));

    orderFormBloc.add(
        const OrderFormEvent(
            status: OrderFormEventStatus.fetchDetail,
            pk: 1
        ));
  });

  test('Test order edit', () async {
    final client = MockClient();
    final orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;
    // orderBloc.customerApi.httpClient = client;
    // orderBloc.locationApi.httpClient = client;
    // orderBloc.equipmentApi.httpClient = client;
    orderFormBloc.privateMemberApi.httpClient = client;

    Order orderModel = Order(
      id: 1,
      customerId: '123465',
      orderId: '987654',
      serviceNumber: '132789654',
      orderLines: [],
      infoLines: [],
      documents: []
    );

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(client.patch(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(order, 200));

    // return member settings data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/member/get_my_settings/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberSettings, 200));

    orderFormBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderUpdatedState>());
        expect(event.props[0], isA<Order>());
      })
    );

    expectLater(orderFormBloc.stream, emits(isA<OrderUpdatedState>()));

    orderFormBloc.add(
        OrderFormEvent(
          status: OrderFormEventStatus.update,
          order: orderModel,
          pk: 1,
          infoLines: [],
          orderLines: [],
          documents: [],
          deletedInfoLines: [],
          deletedOrderLines: [],
          deletedDocuments: []
        ));
  });

  test('Test order insert', () async {
    final client = MockClient();
    final orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;

    Order orderModel = Order(
      customerId: '123465',
      orderId: '987654',
      serviceNumber: '132789654',
      orderLines: [],
      infoLines: [],
      documents: []
    );

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/order/order/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(order, 201));

    Order newOrder = await orderFormBloc.api.insert(orderModel);
    expect(newOrder, isA<Order>());
  });

  test('Test order accept', () async {
    final client = MockClient();
    final orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(tokenData, 200));

    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/set_order_accepted/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 200));

    orderFormBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<OrderAcceptedState>());
          expect(event.props[0], true);
        })
    );

    expectLater(orderFormBloc.stream, emits(isA<OrderAcceptedState>()));

    orderFormBloc.add(
        const OrderFormEvent(status: OrderFormEventStatus.accept, pk: 1)
    );
  });

  test('Test order reject', () async {
    final client = MockClient();
    final orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(tokenData, 200));

    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/set_order_rejected/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 200));

    orderFormBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<OrderRejectedState>());
          expect(event.props[0], true);
        })
    );

    expectLater(orderFormBloc.stream, emits(isA<OrderRejectedState>()));

    orderFormBloc.add(
        const OrderFormEvent(status: OrderFormEventStatus.reject, pk: 1)
    );
  });
}
