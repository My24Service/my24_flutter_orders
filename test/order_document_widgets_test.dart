import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/document/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24_flutter_orders/pages/documents.dart';
import 'package:my24_flutter_orders/widgets/document/form.dart';
import 'package:my24_flutter_orders/widgets/document/error.dart';
import 'package:my24_flutter_orders/widgets/document/list.dart';
import 'package:my24_flutter_orders/blocs/document_bloc.dart';
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

class OrderDocumentListWidget extends BaseOrderDocumentListWidget {
  OrderDocumentListWidget({super.key, required super.orderDocuments, required super.orderId, required super.paginationInfo, required super.memberPicture, required super.searchQuery, required super.widgetsIn, required super.i18n});

  @override
  void navDetail(BuildContext context) {
  }

}

class OrderDocumentsPage extends BaseOrderDocumentsPage {
  OrderDocumentsPage({
    super.key,
    required super.orderId,
    required super.bloc,
    String? initialMode,
    int? pk
  }) : super(initialMode: initialMode, pk: pk);

  @override
  void navOrders(BuildContext context, OrderEventStatus fetchMode) {
    // TODO: implement navOrders
  }

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
    return const SizedBox(height: 1);
  }

  @override
  Widget getOrderDocumentListWidget({OrderDocuments? orderDocuments, required int orderId, required PaginationInfo paginationInfo, String? memberPicture, String? searchQuery, required CoreWidgets widgets, required My24i18n i18n}) {
    return OrderDocumentListWidget(orderDocuments: orderDocuments, orderId: orderId, paginationInfo: paginationInfo, memberPicture: memberPicture, searchQuery: searchQuery, widgetsIn: widgets, i18n: i18n);
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('finds list', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    const String documentData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$orderDocument]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    // return order data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(order, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(orderId: 1, bloc: documentBloc);
    widget.api.httpClient = client;

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentFormWidget), findsNothing);
    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    const String documentData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    // return order data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(order, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(orderId: 1, bloc: documentBloc);
    widget.api.httpClient = client;

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentFormWidget), findsOneWidget);
    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 500
    const String documentData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 500));

    // return order data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(order, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(orderId: 1, bloc: documentBloc);
    widget.api.httpClient = client;

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentFormWidget), findsNothing);
    expect(find.byType(OrderDocumentListErrorWidget), findsOneWidget);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orderDocument, 200));

    // return order data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(order, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(
      orderId: 1, bloc: documentBloc,
      initialMode: 'form',
      pk: 1,
    );
    widget.api.httpClient = client;

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
    expect(find.byType(OrderDocumentFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(order, 200));

    documentBloc.api.httpClient = client;

    OrderDocumentsPage widget = OrderDocumentsPage(
      orderId: 1, bloc: documentBloc,
      initialMode: 'new'
    );
    widget.api.httpClient = client;
    widget.utils.httpClient = client;

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
    expect(find.byType(OrderDocumentFormWidget), findsOneWidget);
  });
}
