import 'dart:convert';
import 'dart:io';

import 'package:my24_flutter_core/models/base_models.dart';

import 'models.dart';

class OrderDocumentFormData extends BaseFormData<OrderDocument> {
  int? id;
  int? orderId;
  String? name;
  String? description;
  String? file;
  File? documentFile;

  bool isValid() {
    if (orderId == null) {
      return false;
    }

    if (documentFile == null) {
      return false;
    }

    return true;
  }

  void reset(int? orderId) {
    id = null;
    orderId = orderId;
    documentFile = null;
    name = null;
    description = null;
    file = null;
  }

  Future<File> getLocalFile(String path) async {
    return File(path);
  }

  @override
  OrderDocument toModel() {
    return OrderDocument(
      orderId: orderId,
      name: name,
      description: description,
      file: base64Encode(documentFile!.readAsBytesSync()),
    );
  }

  factory OrderDocumentFormData.createEmpty(int? orderId) {
    return OrderDocumentFormData(
        id: null,
        orderId: orderId,
        documentFile: null,
        name: null,
        description: null,
        file: null
    );
  }

  factory OrderDocumentFormData.createFromModel(OrderDocument document) {
    return OrderDocumentFormData(
        id: document.id,
        orderId: document.orderId,
        documentFile: null,
        name: document.name,
        description: document.description,
        file: document.file
    );
  }

  OrderDocumentFormData({
    this.id,
    this.orderId,
    this.documentFile,
    this.name,
    this.description,
    this.file
  });
}
