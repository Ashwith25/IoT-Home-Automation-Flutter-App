class DeviceHistory {
  Channel channel;
  List<Feeds> feeds;

  DeviceHistory({this.channel, this.feeds});

  DeviceHistory.fromJson(Map<String, dynamic> json) {
    this.channel =
        json["channel"] == null ? null : Channel.fromJson(json["channel"]);
    this.feeds = json["feeds"] == null
        ? null
        : (json["feeds"] as List).map((e) => Feeds.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.channel != null) data["channel"] = this.channel?.toJson();
    if (this.feeds != null)
      data["feeds"] = this.feeds?.map((e) => e.toJson())?.toList();
    return data;
  }
}

class Feeds {
  String createdAt;
  int entryId;
  dynamic field1;
  dynamic field2;

  Feeds({this.createdAt, this.entryId, this.field1, this.field2});

  Feeds.fromJson(Map<String, dynamic> json) {
    this.createdAt = json["created_at"];
    this.entryId = json["entry_id"];
    this.field1 = json["field1"];
    this.field2 = json["field2"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["created_at"] = this.createdAt;
    data["entry_id"] = this.entryId;
    data["field1"] = this.field1;
    data["field2"] = this.field2;
    return data;
  }
}

class Channel {
  int id;
  String name;
  String latitude;
  String longitude;
  String field1;
  String field2;
  String createdAt;
  String updatedAt;
  int lastEntryId;

  Channel(
      {this.id,
      this.name,
      this.latitude,
      this.longitude,
      this.field1,
      this.field2,
      this.createdAt,
      this.updatedAt,
      this.lastEntryId});

  Channel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
    this.latitude = json["latitude"];
    this.longitude = json["longitude"];
    this.field1 = json["field1"];
    this.field2 = json["field2"];
    this.createdAt = json["created_at"];
    this.updatedAt = json["updated_at"];
    this.lastEntryId = json["last_entry_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["name"] = this.name;
    data["latitude"] = this.latitude;
    data["longitude"] = this.longitude;
    data["field1"] = this.field1;
    data["field2"] = this.field2;
    data["created_at"] = this.createdAt;
    data["updated_at"] = this.updatedAt;
    data["last_entry_id"] = this.lastEntryId;
    return data;
  }
}

class DeviceData {
  String device;
  String startTime;
  String endTime;

  DeviceData({this.device, this.startTime, this.endTime});

  DeviceData.fromJson(Map<String, dynamic> json) {
    this.device = json["device"];
    this.startTime = json["startTime"];
    this.endTime = json["endTime"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["device"] = this.device;
    data["startTime"] = this.startTime;
    data["endTime"] = this.endTime;
    return data;
  }
}
