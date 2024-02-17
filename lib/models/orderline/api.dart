import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class OrderlineApi extends BaseCrud<Orderline, Orderlines> {
  @override
  get basePath {
    return "/order/orderline";
  }

  @override
  Orderline fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Orderline.fromJson(parsedJson!);
  }

  @override
  Orderlines fromJsonList(Map<String, dynamic>? parsedJson) {
    return Orderlines.fromJson(parsedJson!);
  }
}
