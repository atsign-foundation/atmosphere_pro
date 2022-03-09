class NotificationPayload {
  String? name;
  // String handle;
  String? file;
  // String userImage;
  // int numberOfFiles;
  double? size;
  // int id;
  // String extension;

  NotificationPayload(
      {this.name,
      // this.handle,
      this.file,
      // this.id,
      // this.userImage,
      // this.numberOfFiles,
      // this.extension,
      this.size});

  NotificationPayload.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();
    // id = int.parse(json['id'].toString());
    // handle = json['handle'].toString();
    file = json['file'].toString();
    // userImage = json['userImage'].toString();
    // numberOfFiles = int.parse(json['numberOfFiles'].toString());
    size = double.parse(json['size'].toString());
    // extension = json['extension'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    // data['handle'] = this.handle;
    data['file'] = this.file;
    // data['id'] = this.id;
    // data['userImage'] = this.userImage;
    // data['numberOfFiles'] = this.numberOfFiles;
    data['size'] = this.size;
    // data['extension'] = this.extension;
    return data;
  }
}
