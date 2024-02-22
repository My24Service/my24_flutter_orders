import 'package:my24_flutter_core/models/base_models.dart';

import 'models.dart';

class InfolineFormData extends BaseFormData<Infoline> {
  int? id;
  int? order;
  String? info;

  bool isValid() {
    if (info == "") {
      return false;
    }

    return true;
  }

  void reset(int? order) {
    id = null;
    order = order;
    info = null;
  }

  @override
  Infoline toModel() {
    Infoline infoline = Infoline(
        id: id,
        order: order,
        info: info,
    );

    return infoline;
  }

  factory InfolineFormData.createEmpty(int? order) {
    return InfolineFormData(
      id: null,
      info: null,
   );
  }

  factory InfolineFormData.createFromModel(Infoline infoline) {
    return InfolineFormData(
      id: infoline.id,
      order: infoline.order,
      info: infoline.info,
    );
  }

  InfolineFormData({
    this.id,
    this.order,
    this.info,
  });
}
