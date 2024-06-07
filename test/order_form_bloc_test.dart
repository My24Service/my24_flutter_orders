import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24_flutter_core/dev_logging.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
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
  setUpLogging();

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
    orderFormBloc.orderlineApi.httpClient = client;
    orderFormBloc.infolineApi.httpClient = client;
    orderFormBloc.orderDocumentApi.httpClient = client;
    orderFormBloc.infolineApi.httpClient = client;
    orderFormBloc.locationApi.httpClient = client;
    orderFormBloc.equipmentApi.httpClient = client;
    orderFormBloc.privateMemberApi.httpClient = client;

    Order orderModel = Order(
      id: 1,
      customerId: '123465',
      orderId: '987654',
      serviceNumber: '132789654'
    );

    Orderline orderline1 = Orderline(
      id: 1,
      order: 1,
      product: "Wheel-lock 1",
      location: "Loods 3"
    );

    Orderline orderline2 = Orderline(
        id: 2,
        order: 1,
        product: "Wheel-lock 2",
        location: "Loods 3"
    );

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(client.patch(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(order, 200));

    // return orderline data with a 200
    when(client.patch(Uri.parse('https://demo.my24service-dev.com/api/order/orderline/1/'), headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(orderLine1, 200));

    // return orderline data with a 200
    when(client.patch(Uri.parse('https://demo.my24service-dev.com/api/order/orderline/2/'), headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(orderLine2, 200));

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
          // TODO add infolines and orderlines
          infoLines: [],
          orderLines: [orderline1, orderline2],
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

  test("Test add orderline", () async {
    final orderFormBloc = OrderFormBloc();
    final Order orderModel = Order.fromJson(jsonDecode(order));
    final Orderline orderline1 = Orderline(
        order: 1,
        product: "Wheel-lock 1",
        location: "Loods 3"
    );

    orderFormBloc.stream.listen(
        expectAsync1((event) {
          if (event is OrderLineAddedState) {
            expect(event, isA<OrderLineAddedState>());
          }
          if (event is OrderLoadedState) {
            expect(event, isA<OrderLoadedState>());
            expect(event.props[0], isA<OrderFormData>());
            expect(event.formData.orderLines!.length, 2);
            expect(event.formData.orderLines![0].id, 1);
            expect(event.formData.orderLines![1].id, null);
          }
        }, count: 2)
    );

    final OrderTypes orderTypesObj = OrderTypes.fromJson(jsonDecode(orderTypes));
    final OrderFormData formData = OrderFormData.createFromModel(orderModel, orderTypesObj);

    orderFormBloc.add(OrderFormEvent(
        status: OrderFormEventStatus.addOrderLine,
        formData: formData,
        orderline: orderline1
    ));
  });
}
