class MenuItem {
  String title;
  String image;
  String? routeName;
  bool? isUrl;
  bool? isEmail;
  List<MenuItem>? children;

  MenuItem({
    required this.title,
    required this.image,
    this.routeName,
    this.children,
    this.isUrl,
    this.isEmail,
  });
}
