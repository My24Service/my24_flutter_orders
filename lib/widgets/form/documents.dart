// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import '../../../blocs/order_bloc.dart';
import '../../../models/document/form_data.dart';
import '../../../models/document/models.dart';
import '../../../models/order/form_data.dart';

class Documents<FormDataClass extends BaseOrderFormData> extends StatelessWidget {
  final My24i18n i18n = My24i18n(basePath: "orders.form.documents");
  final FormDataClass formData;
  final CoreWidgets widgets;
  final int? orderId;

  Documents({
    super.key,
    required this.formData,
    required this.widgets,
    required this.orderId
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          )
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          widgets.createHeader(i18n.$trans('header')),
          DocumentList(
            widgets: widgets,
            formData: formData,
            i18n: i18n,
          ),
          widgets.createHeader(i18n.$trans('header_new')),
          DocumentForm(
            formData: formData,
            widgets: widgets,
            i18n: i18n,
          ),
        ],
      ),
    );
  }
}

class DocumentList<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends StatelessWidget {
  final CoreWidgets widgets;
  final FormDataClass formData;
  final CoreUtils utils = CoreUtils();
  final My24i18n i18n;

  DocumentList({
    super.key,
    required this.widgets,
    required this.formData,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    if (formData.documents!.isEmpty) {
      return Column(
        children: [
          Text(i18n.$trans("no_items"))
        ],
      );
    }

    return widgets.buildItemsSection(
        context,
        "",
        formData.documents,
        (item) {
          return widgets.buildItemListKeyValueList(
              i18n.$trans('info_name'),
              item.name
          );
        },
        (OrderDocument item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widgets.createDeleteButton(
                () { _showDeleteDialog(context, item); }
                )
              ],
            )
          ];
        }
    );
  }

  updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: formData
    ));
  }

  _delete(BuildContext context, OrderDocument document) {
    if (document.id != null && !formData.deletedDocuments!.contains(document)) {
      formData.deletedDocuments!.add(document);
    }

    formData.documents!.removeAt(formData.documents!.indexOf(document));
    updateFormData(context);
  }

  _showDeleteDialog(BuildContext context, OrderDocument document) {
    widgets.showDeleteDialogWrapper(
        i18n.$trans('delete_dialog_title'),
        i18n.$trans('delete_dialog_content'),
        () => _delete(context, document),
        context
    );
  }

  // Widget _getDocumentPreview(OrderDocument document) {
  //   if (document.file!.endsWith(".jpg")) {
  //     return CachedNetworkImage(
  //       placeholder: (context, url) => const CircularProgressIndicator(),
  //       imageUrl: document.url!,
  //       fit: BoxFit.cover,
  //     );
  //   }
  //
  //   return const Text("view");
  // }
  //
  // Widget _createViewDocument(BuildContext context, OrderDocument document) {
  //   return widgets.createViewButton(
  //       () async {
  //         String url = await utils.getUrl(document.url);
  //         url = url.replaceAll('/api', '');
  //
  //         Map<String, dynamic> openResult = await coreUtils.openDocument(url);
  //         if (!openResult['result'] && context.mounted) {
  //           widgets.createSnackBar(
  //               context,
  //               i18n.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic')
  //           );
  //         }
  //       }
  //   );
  // }
}

class DocumentForm<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;

  const DocumentForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n
  });

  @override
  State<StatefulWidget> createState() => _DocumentFormState();
}

class _DocumentFormState<BlocClass extends OrderBlocBase, FormDataClass extends BaseOrderFormData> extends State<DocumentForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final picker = ImagePicker();
  OrderDocumentFormData orderDocumentFormData = OrderDocumentFormData.createEmpty(null);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  _addListeners() {
    nameController.addListener(_nameListen);
    descriptionController.addListener(_descriptionListen);
  }

  void _nameListen() {
    if (nameController.text.isEmpty) {
      orderDocumentFormData.name = "";
    } else {
      orderDocumentFormData.name = nameController.text;
    }
  }

  void _descriptionListen() {
    if (descriptionController.text.isEmpty) {
      orderDocumentFormData.description = "";
    } else {
      orderDocumentFormData.description = descriptionController.text;
    }
  }

  updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<BlocClass>(context);
    bloc.add(const OrderEvent(status: OrderEventStatus.doAsync));
    bloc.add(OrderEvent(
        status: OrderEventStatus.updateFormData,
        formData: widget.formData
    ));
  }

  @override
  void initState() {
    super.initState();
    orderDocumentFormData.orderId = widget.formData.id;
    _addListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.i18n.$trans('info_name')),
            TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return My24i18n.tr('generic.validator_name_document');
                  }
                  return null;
                }),
            const SizedBox(
              height: 10.0,
            ),
            Text(My24i18n.tr('generic.info_description')),
            TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  return null;
                }),
            const SizedBox(
              height: 10.0,
            ),
            Text(widget.i18n.$trans('info_document')),
            TextFormField(
                readOnly: true,
                controller: documentController,
                validator: (value) {
                  return null;
                }),
            const SizedBox(
              height: 10.0,
            ),
            Column(
                children: [
                  _buildOpenFileButton(context),
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildChooseImageButton(context),
                  Text(
                      My24i18n.tr('generic.info_or'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic
                      )
                  ),
                  _buildTakePictureButton(context),
                ]
            ),
            const SizedBox(
              height: 10.0,
            ),
            widget.widgets.createDefaultElevatedButton(
              context,
              widget.i18n.$trans('button_add'),
              () { _addDocument(context); }
            )
          ],
        )
    );
  }

  Widget _buildOpenFileButton(BuildContext context) {
    return widget.widgets.createElevatedButtonColored(
        My24i18n.tr('generic.button_choose_file'),
        () => _openFilePicker(context)
    );
  }

  Widget _buildTakePictureButton(BuildContext context) {
    return widget.widgets.createElevatedButtonColored(
        My24i18n.tr('generic.button_take_picture'),
        () => _openImageCamera(context)
    );
  }

  Widget _buildChooseImageButton(BuildContext context) {
    return widget.widgets.createElevatedButtonColored(
        My24i18n.tr('generic.button_choose_image'),
        () => _openImagePicker(context)
    );
  }

  _openFilePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile file = result.files.first;

      orderDocumentFormData.documentFile = await orderDocumentFormData.getLocalFile(file.path!);
      documentController.text = file.name;
      if (nameController.text == "") {
        nameController.text = file.name;
      }

      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  _openImageCamera(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      orderDocumentFormData.documentFile = await orderDocumentFormData.getLocalFile(pickedFile.path);
      documentController.text = filename;
      if (nameController.text == "") {
        nameController.text = filename;
      }

      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  _openImagePicker(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      orderDocumentFormData.documentFile = await orderDocumentFormData.getLocalFile(pickedFile.path);
      documentController.text = filename;
      if (nameController.text == "") {
        nameController.text = filename;
      }

      if (context.mounted) {
        updateFormData(context);
      }
    }
  }

  void _addDocument(BuildContext context) {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();

      OrderDocument orderDocument = orderDocumentFormData.toModel();

      widget.formData.documents!.add(orderDocument);

      // reset fields
      orderDocumentFormData.reset(widget.formData.id);

      documentController.text = "";
      nameController.text = "";
      descriptionController.text = "";

      updateFormData(context);
      widget.widgets.createSnackBar(context, widget.i18n.$trans('snackbar_added'));
    } else {
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}
