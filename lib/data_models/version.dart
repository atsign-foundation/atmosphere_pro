class AppVersion {
  Version? android;
  Version? ios;
  Version? macOs;
  Version? windows;
  Version? linux;
  AppVersion({
    this.android,
    this.ios,
    this.macOs,
    this.windows,
    this.linux,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['android'] = android?.toJson();
    data['ios'] = ios?.toJson();
    data['macOs'] = macOs?.toJson();
    data['windows'] = windows?.toJson();
    data['linux'] = linux?.toJson();
    return data;
  }

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    try {
      return AppVersion(
        android: Version.fromJson(json['android']),
        ios: Version.fromJson(json['ios']),
        macOs: Version.fromJson(json['macOs']),
        windows: Version.fromJson(json['windows']),
        linux: Version.fromJson(json['linux']),
      );
    } catch (e) {
      return AppVersion();
    }
  }
}

class Version {
  String latestVersion;
  String minVersion;
  Version({
    required this.latestVersion,
    required this.minVersion,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latestVersion'] = latestVersion;
    data['minVersion'] = minVersion;
    return data;
  }

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      latestVersion: json['latestVersion'],
      minVersion: json['minVersion'],
    );
  }
}
