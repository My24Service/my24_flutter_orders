import 'package:my24_flutter_core/models/base_models.dart';

import 'models.dart';

class OrderlineFormData extends BaseFormData<Orderline> {
  int? id;
  int? order;
  int? equipment;
  int? equipmentLocation;

  String? location;
  String? product;
  String? remarks;

  bool isValid() {
    if (product == "") {
      return false;
    }

    return true;
  }

  void reset(int? order) {
    id = null;
    order = order;
    equipment = null;
    equipmentLocation = null;
    location = null;
    product = null;
    remarks = null;
  }

  @override
  Orderline toModel() {
    Orderline orderline = Orderline(
        id: id,
        order: order,
        product: product,
        location: location,
        remarks: remarks,
        equipment: equipment,
        equipmentLocation: equipmentLocation,
    );

    return orderline;
  }

  factory OrderlineFormData.createEmpty(int? order) {
    return OrderlineFormData(
      id: null,
      order: order,
      equipment: null,
      equipmentLocation: null,
      location: null,
      product: null,
      remarks: null,
    );
  }

  factory OrderlineFormData.createFromModel(Orderline orderline) {
    return OrderlineFormData(
      id: orderline.id,
      order: orderline.order,
      equipment: orderline.equipment,
      equipmentLocation: orderline.equipmentLocation,
      location: orderline.location,
      product: orderline.product,
      remarks: orderline.remarks,
    );
  }

  OrderlineFormData({
    this.id,
    this.order,
    this.equipment,
    this.equipmentLocation,
    this.location,
    this.product,
    this.remarks,
  });
}
