library user_data;

class BusData {
  String ownerName;
  String busName;
  String contact;
  String id;
  String licenseNumber;

  BusData.fromJson(response) {
    this.id = response["ownerId"];
    this.ownerName = response["name"];
    this.busName = response["busName"];
    this.licenseNumber = response["licenseNo"];
  }
  Map<String, dynamic> toJson() => {
    "id": this.id,
    "name": this.ownerName,
    "busName": this.busName,
    "licenseNumber": this.licenseNumber,
  };
}
