library debate;

class Debate {
  Map<String, Assertion> _assertions = new Map<String, Assertion>();
  
  void add(Assertion a) {
    a.debate = this;
    _assertions[a.id] = a;
  }
  
  Assertion get(String id) => _assertions[id];
  
  Iterable<Premise> get premises => _assertions.values
      .where((a) => a is Premise)
      .map((a) => a as Premise);
  Iterable<Connection> get connections => _assertions.values
      .where((a) => a is Connection)
      .map((a) => a as Connection);

  Debate.fromJson(dynamic json) {
    Assertion jsonToAssertion(Map a) {
      if(Premise.TYPES.contains(a["type"])) {
        return new Premise.fromJson(a);
      } else if(Connection.TYPES.contains(a["type"])) {
        return new Connection.fromJson(a);
      } else {
        return null;
      }
    }
    
    json.map(jsonToAssertion)
      .where((a) => a != null)
      .forEach(add);
  }
}

abstract class Assertion {
  String id;
  String type;
  String status;
  Debate debate;
  num get x;
  num get y;
}

class Premise extends Assertion {
  static final List<String> TYPES = ["statement", "evidence"];
  String text;
  num x;
  num y;

  Premise.fromJson(Map obj) {
    id = obj["id"];
    type = obj["type"];
    status = obj["status"];
    text = obj["text"];
    x = obj["x"];
    y = obj["y"];
  }
}

class Connection extends Assertion {
  static final List<String> TYPES = ["dispute", "support"];
  String assertionId;
  String premiseId;
  
  Connection.fromJson(Map obj) {
    id = obj["id"];
    type = obj["type"];
    status = obj["status"];
    assertionId = obj["assertion"];
    premiseId = obj["premise"];    
  }
  
  Assertion get assertion => debate.get(assertionId);
  Assertion get premise => debate.get(premiseId);
  num get x => (assertion.x + premise.x) / 2;
  num get y => (assertion.y + premise.y) / 2;
}
