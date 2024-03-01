import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import '../order/models.dart';

class OrderDocumentPageData {
  final String? memberPicture;
  final Widget? drawer;
  final Order? order;

  OrderDocumentPageData({
    this.memberPicture,
    this.drawer,
    this.order
  });
}

class OrderDocument extends BaseModel {
  final int? id;
  int? orderId;
  final String? name;
  final String? description;
  final String? file;
  final String? url;

  OrderDocument({
    this.id,
    this.orderId,
    this.name,
    this.description,
    this.file,
    this.url,
  });

  factory OrderDocument.fromJson(Map<String, dynamic> parsedJson) {
    return OrderDocument(
      id: parsedJson['id'],
      orderId: parsedJson['order'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      file: parsedJson['file'],
      url: parsedJson['url'],
    );
  }

  @override
  String toJson() {
    // only add file when it's base64 encoded
    String? useFile;

    try {
      base64Decode(file!);
      useFile = file!;
    } catch(e) {
      useFile = null;
    }

    Map body = {
      'order': orderId,
      'name': name,
      'description': description,
    };

    if (useFile != null) {
      body['file'] = useFile;
    }

    return json.encode(body);
  }
}

class OrderDocuments extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<OrderDocument>? results;

  OrderDocuments({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory OrderDocuments.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<OrderDocument> results = list.map((i) => OrderDocument.fromJson(i)).toList();

    return OrderDocuments(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
