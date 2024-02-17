import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../../blocs/document_bloc.dart';
import '../../models/document/form_data.dart';
import '../../models/document/models.dart';

class OrderDocumentFormWidget extends BaseSliverPlainStatelessWidget{
  final int? orderId;
  final OrderDocumentFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final String? memberPicture;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  OrderDocumentFormWidget({
    Key? key,
    required this.orderId,
    this.formData,
    required this.memberPicture,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ? i18nIn.$trans('app_bar_title_new') : i18nIn.$trans(
        'app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView( // new line
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: _buildForm(context),
                      ),
                      widgetsIn.createSubmitSection(_getButtons(context) as Row)
                    ]
                )
            )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetsIn.createCancelButton(() => _navList(context)),
          const SizedBox(width: 10),
          widgetsIn.createSubmitButton(context, () => _handleSubmit(context)),
        ]
    );
  }

  void _navList(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.fetchAll,
        orderId: orderId
    ));
  }

  _openFilePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile file = result.files.first;

      formData!.documentFile = await formData!.getLocalFile(file.path!);
      formData!.documentController!.text = file.name;
      formData!.nameController!.text = file.name;
      if (context.mounted) {
        _updateFormData(context);
      }
    }
  }

  _openImageCamera(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      formData!.documentFile = await formData!.getLocalFile(pickedFile.path);
      formData!.documentController!.text = filename;
      if (context.mounted) {
        _updateFormData(context);
      }
    }
  }

  _openImagePicker(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String filename = pickedFile.path.split("/").last;

        formData!.documentFile = await formData!.getLocalFile(pickedFile.path);
        formData!.documentController!.text = filename;
        if (context.mounted) {
          _updateFormData(context);
        }
      }
  }

  Widget _buildOpenFileButton(BuildContext context) {
    return widgetsIn.createElevatedButtonColored(
        i18nIn.$trans('button_choose_file', pathOverride: 'generic'),
        () => _openFilePicker(context) );
  }

  Widget _buildTakePictureButton(BuildContext context) {
    return widgetsIn.createElevatedButtonColored(
        i18nIn.$trans('button_take_picture', pathOverride: 'generic'),
        () => _openImageCamera(context) );
  }

  Widget _buildChooseImageButton(BuildContext context) {
    return widgetsIn.createElevatedButtonColored(
        i18nIn.$trans('button_choose_image', pathOverride: 'generic'),
        () => _openImagePicker(context) );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(i18nIn.$trans('name')),
        TextFormField(
            controller: formData!.nameController,
            validator: (value) {
              if (value!.isEmpty) {
                return i18nIn.$trans('validator_name_document', pathOverride: 'generic');
              }
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        Text(i18nIn.$trans('info_description', pathOverride: 'generic')),
        TextFormField(
            controller: formData!.descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        Text(i18nIn.$trans('info_photo')),
        TextFormField(
            readOnly: true,
            controller: formData!.documentController,
            validator: (value) {
              return null;
            }),
        const SizedBox(
          height: 10.0,
        ),
        Column(children: [
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
        ]),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (!formData!.isValid()) {
        if (formData!.documentFile == null) {
          widgetsIn.displayDialog(context,
              i18nIn.$trans('dialog_no_document_title', pathOverride: 'generic'),
              i18nIn.$trans('dialog_no_document_content', pathOverride: 'generic')
          );
          return;
        }
      }

      final bloc = BlocProvider.of<OrderDocumentBloc>(context);
      if (formData!.id != null) {
        OrderDocument updatedDocument = formData!.toModel();
        bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
        bloc.add(OrderDocumentEvent(
            pk: updatedDocument.id,
            status: OrderDocumentEventStatus.update,
            document: updatedDocument,
            orderId: updatedDocument.orderId
        ));
      } else {
        OrderDocument newDocument = formData!.toModel();
        bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
        bloc.add(OrderDocumentEvent(
            status: OrderDocumentEventStatus.insert,
            document: newDocument,
            orderId: newDocument.orderId
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);
    bloc.add(const OrderDocumentEvent(status: OrderDocumentEventStatus.doAsync));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.updateFormData,
        documentFormData: formData
    ));
  }
}
