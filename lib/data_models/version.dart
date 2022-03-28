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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
  String buildNumber;
  String minVersion;
  String minBuildNumber;
  bool isBackwardCompatible;
  Version(
      {required this.latestVersion,
      required this.buildNumber,
      required this.minVersion,
      required this.isBackwardCompatible,
      required this.minBuildNumber});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['latestVersion'] = latestVersion;
    data['minVersion'] = minVersion;
    data['buildNumber'] = buildNumber;
    data['minBuildNumber'] = minBuildNumber;
    data['isBackwardCompatible'] = isBackwardCompatible.toString();
    return data;
  }

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      latestVersion: json['latestVersion'],
      buildNumber: json['buildNumber'],
      minVersion: json['minVersion'],
      minBuildNumber: json['minBuildNumber'],
      isBackwardCompatible:
          json['isBackwardCompatible'] == 'true' ? true : false,
    );
  }
}
