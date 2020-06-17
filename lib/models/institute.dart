class Institute{
  String id;
  String name;

  Institute(this.id, this.name);

  Institute.fromJson(json){
    name = json["name"];
    id = json["_id"];
  }
  Map<String, dynamic> toJson() => {
    "name": this.name,
    "_id": this.id
  };
}