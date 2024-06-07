// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import '../../../models/document/form_data.dart';
import '../../../models/document/models.dart';
import '../../../models/order/form_data.dart';
import '../../blocs/order_form_bloc.dart';

class DocumentsWidget<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final My24i18n i18n = My24i18n(basePath: "orders.form.documents");
  final FormDataClass formData;
  final CoreWidgets widgets;
  final int? orderId;
  final bool? onlyPictures;
  final BlocClass? bloc;

  DocumentsWidget({
    super.key,
    required this.formData,
    required this.widgets,
    required this.orderId,
    this.onlyPictures,
    this.bloc
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
          if (onlyPictures != null && onlyPictures!)
            widgets.createHeader(i18n.$trans('header_pictures')),
          if (onlyPictures == null || !onlyPictures!)
            widgets.createHeader(i18n.$trans('header')),
            DocumentList(
              widgets: widgets,
              formData: formData,
              i18n: i18n,
              bloc: bloc,
            ),
          widgets.createHeader(i18n.$trans('header_new')),
          if (onlyPictures != null && onlyPictures!)
            OnlyPicturesForm(
              formData: formData,
              widgets: widgets,
              i18n: i18n,
              bloc: bloc,
            ),
          if (onlyPictures == null || !onlyPictures!)
            DocumentForm(
              formData: formData,
              widgets: widgets,
              i18n: i18n,
              bloc: bloc,
            ),
        ],
      ),
    );
  }
}

class DocumentList<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatelessWidget {
  final CoreWidgets widgets;
  final FormDataClass formData;
  final CoreUtils utils = CoreUtils();
  final My24i18n i18n;
  final BlocClass? bloc;

  DocumentList({
    super.key,
    required this.widgets,
    required this.formData,
    required this.i18n,
    this.bloc
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

  _delete(BuildContext context, OrderDocument document) {
    final useBloc = bloc ?? BlocProvider.of<BlocClass>(context);
    useBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
    useBloc.add(OrderFormEvent(
      document: document,
      status: OrderFormEventStatus.removeDocument,
      formData: formData
    ));
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

class DocumentForm<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final BlocClass? bloc;

  const DocumentForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n,
    this.bloc
  });

  @override
  State<StatefulWidget> createState() => _DocumentFormState();
}

class _DocumentFormState<BlocClass extends OrderFormBlocBase, FormDataClass extends BaseOrderFormData> extends State<DocumentForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final picker = ImagePicker();
  OrderDocumentFormData orderDocumentFormData = OrderDocumentFormData.createEmpty(null);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
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
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
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
    }
  }

  void _addDocument(BuildContext context) {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();

      OrderDocument orderDocument = orderDocumentFormData.toModel();

      final useBloc = widget.bloc ?? BlocProvider.of<BlocClass>(context);
      useBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      useBloc.add(OrderFormEvent(
        status: OrderFormEventStatus.addDocument,
        formData: widget.formData,
        document: orderDocument
      ));

      // reset fields
      orderDocumentFormData.reset(widget.formData.id);

      documentController.text = "";
      nameController.text = "";
      descriptionController.text = "";
    } else {
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}

class OnlyPicturesForm<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends StatefulWidget {
  final FormDataClass formData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final BlocClass? bloc;

  const OnlyPicturesForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n,
    this.bloc
  });

  @override
  State<StatefulWidget> createState() => _OnlyPicturesFormState();
}

class _OnlyPicturesFormState<
  BlocClass extends OrderFormBlocBase,
  FormDataClass extends BaseOrderFormData
> extends State<OnlyPicturesForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final picker = ImagePicker();
  OrderDocumentFormData orderDocumentFormData = OrderDocumentFormData.createEmpty(null);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              controller: nameController,
              validator: (value) {
                if (value!.isEmpty) {
                  return My24i18n.tr('generic.validator_name_document');
                }
                return null;
              }
            ),
            const SizedBox(
              height: 10.0,
            ),
            // Text(My24i18n.tr('generic.info_description')),
            // TextFormField(
            //     controller: descriptionController,
            //     keyboardType: TextInputType.multiline,
            //     maxLines: null,
            //     validator: (value) {
            //       return null;
            //     }),
            // const SizedBox(
            //   height: 10.0,
            // ),
            Text(widget.i18n.$trans('info_image')),
            TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                controller: documentController,
                validator: (value) {
                  return null;
                }),
            const SizedBox(
              height: 10.0,
            ),
            _buildChooseImageButton(context),
            _buildTakePictureButton(context),
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

  _openImageCamera(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      orderDocumentFormData.documentFile = await orderDocumentFormData.getLocalFile(pickedFile.path);
      documentController.text = filename;
      if (nameController.text == "") {
        nameController.text = filename;
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
    }
  }

  void _addDocument(BuildContext context) {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();

      OrderDocument orderDocument = orderDocumentFormData.toModel();

      final useBloc = widget.bloc ?? BlocProvider.of<BlocClass>(context);
      useBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      useBloc.add(OrderFormEvent(
          status: OrderFormEventStatus.addDocument,
          formData: widget.formData,
          document: orderDocument
      ));

      // reset fields
      orderDocumentFormData.reset(widget.formData.id);

      documentController.text = "";
      nameController.text = "";
      descriptionController.text = "";
    } else {
      widget.widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          widget.i18n.$trans('error_adding')
      );
    }
  }
}
