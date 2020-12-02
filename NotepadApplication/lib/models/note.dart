class Note {

  int _id;
  String _title;

  set id(int value) {
    _id = value;
  }

  String _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, [this._description]);

  Note.withId(this._id, this._title, this._date, this._priority, [this._description]);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  int get priority => _priority;
  String get date => _date;

  set title(String value) {
    if (value.length > 0){
      _title = value;
    }
  }

  set description(String value) {
    if (value.length > 0){
      _description = value;
    }
  }

  set date(String value) {
    _date = value;
  }

  set priority(int value) {
    if (value >= 1 && value <=2){
      _priority = value;
    }
  }


  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();

    if (id != null){
      map['id'] = _id;
    }
    map['title'] = _title;
    map['date'] = _date;
    map['priority'] = _priority;
    map['description'] = _description;

    return map;
  }


  Note.fromMapObject(Map<String,dynamic> map){
    this._id = map['id'];
    this._title = map['title'];
    this._date= map['date'];
    this._priority = map['priority'];
    this._description = map['description'];
  }

}

