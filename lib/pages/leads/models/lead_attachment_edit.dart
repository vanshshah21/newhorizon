import 'lead_attachment.dart';
import 'package:file_picker/file_picker.dart';

enum AttachmentEditAction { none, delete, replace }

class LeadAttachmentEdit {
  final LeadAttachment original;
  AttachmentEditAction action;
  PlatformFile? replacementFile;

  LeadAttachmentEdit({
    required this.original,
    this.action = AttachmentEditAction.none,
    this.replacementFile,
  });
}
