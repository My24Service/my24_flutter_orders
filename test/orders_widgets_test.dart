import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/widgets/detail.dart';
import 'package:my24_flutter_orders/widgets/error.dart';
import 'order_models.dart';
import 'fixtures.dart';

Widget createWidget({Widget? child}) {
  return MaterialApp(
      home: Scaffold(
          body: Container(
              child: child
          )
      ),
  );
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('loads main list', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    const String orders = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$order]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/?order_by=-start_date'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    OrderListPage widget = OrderListPage(bloc: orderBloc, fetchMode: OrderEventStatus.fetchAll);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderListErrorWidget), findsNothing);
    expect(find.byType(OrderListEmptyWidget), findsNothing);
    expect(find.byType(OrderListWidget), findsOneWidget);
  });

  testWidgets('loads main list empty', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return nothing with a 200
    const String orders = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/?order_by=-start_date'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    OrderListPage widget = OrderListPage(bloc: orderBloc, fetchMode: OrderEventStatus.fetchAll);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderListErrorWidget), findsNothing);
    expect(find.byType(OrderListEmptyWidget), findsOneWidget);
    expect(find.byType(OrderListWidget), findsNothing);
  });

  testWidgets('loads main list error', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return a 500
    const String orders = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/?order_by=-start_date'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 500));

    OrderListPage widget = OrderListPage(bloc: orderBloc, fetchMode: OrderEventStatus.fetchAll);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderListErrorWidget), findsOneWidget);
    expect(find.byType(OrderListEmptyWidget), findsNothing);
    expect(find.byType(OrderListWidget), findsNothing);
  });

  testWidgets('loads detail', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(order, 200));

    OrderDetailPage widget = OrderDetailPage(
      orderId: 1,
      bloc: orderBloc,
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDetailWidget), findsOneWidget);
  });

  testWidgets('loads form edit', (tester) async {
    final client = MockClient();
    final orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;
    orderFormBloc.privateMemberApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(order, 200));

    // return order types data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/order_types/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(orderTypes, 200));

    // return member settings data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/member/get_my_settings/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberSettings, 200));

    OrderFormPageClass widget = OrderFormPageClass(
      pk: 1,
      bloc: orderFormBloc,
      fetchMode: OrderEventStatus.fetchAll
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderFormWidget), findsOneWidget);
  });

  testWidgets('loads form new', (tester) async {
    final client = MockClient();
    final orderFormBloc = OrderFormBloc();
    orderFormBloc.api.httpClient = client;
    orderFormBloc.privateMemberApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return order types data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/order_types/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(orderTypes, 200));

    // return member settings data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/member/get_my_settings/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberSettings, 200));

    OrderFormPageClass widget = OrderFormPageClass(
        pk: null,
        bloc: orderFormBloc,
        fetchMode: OrderEventStatus.fetchAll
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderFormWidget), findsOneWidget);
  });
}
