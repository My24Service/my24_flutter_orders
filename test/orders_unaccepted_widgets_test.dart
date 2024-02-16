import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24_flutter_orders/widgets/order/unaccepted/empty.dart';
import 'package:my24_flutter_orders/widgets/order/unaccepted/error.dart';
import 'package:my24_flutter_orders/widgets/order/unaccepted/list.dart';
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
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_not_accepted/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    OrderListPage widget = OrderListPage(bloc: orderBloc, fetchMode: OrderEventStatus.FETCH_UNACCEPTED);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UnacceptedListWidget), findsOneWidget);
    expect(find.byType(UnacceptedListErrorWidget), findsNothing);
    expect(find.byType(UnacceptedListEmptyWidget), findsNothing);
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
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_not_accepted/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));


    OrderListPage widget = OrderListPage(bloc: orderBloc, fetchMode: OrderEventStatus.FETCH_UNACCEPTED);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UnacceptedListWidget), findsNothing);
    expect(find.byType(UnacceptedListErrorWidget), findsNothing);
    expect(find.byType(UnacceptedListEmptyWidget), findsOneWidget);
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
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_not_accepted/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 500));

    OrderListPage widget = OrderListPage(bloc: orderBloc, fetchMode: OrderEventStatus.FETCH_UNACCEPTED);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UnacceptedListWidget), findsNothing);
    expect(find.byType(UnacceptedListErrorWidget), findsOneWidget);
    expect(find.byType(UnacceptedListEmptyWidget), findsNothing);
  });
}
