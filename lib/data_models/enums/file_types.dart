enum FileTypes { all, docx, ppt, pdf, excel, txtFile, psd, html, png }

extension GenderTypeExtension on FileTypes {
  String get text {
    switch (this) {
      case FileTypes.all:
        return 'All';
      case FileTypes.docx:
        return 'Docx';
      case FileTypes.ppt:
        return 'PPT';
      case FileTypes.pdf:
        return 'PDF';
      case FileTypes.excel:
        return 'Excel';
      case FileTypes.txtFile:
        return 'Txt File';
      case FileTypes.psd:
        return 'PSD';
      case FileTypes.html:
        return 'HTML';
      case FileTypes.png:
        return 'PNG';
      default:
        return '';
    }
  }
}
