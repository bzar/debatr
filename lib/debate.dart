library debate;

class Debate {
  Map<String, Assertion> _assertions = new Map<String, Assertion>();
  int nextId = 0;

  String add(Assertion a) {
    if (a.id == null) {
      a.id = nextId.toString();
      nextId += 1;
    } else {
      int idValue = int.parse(a.id);
      if (idValue >= nextId) {
        nextId = idValue + 1;
      }
    }
    a.debate = this;
    _assertions[a.id] = a;
    return a.id;
  }

  Assertion get(String id) => _assertions[id];

  Iterable<Premise> get premises => _assertions.values.where((a) => a is Premise).map((a) => a as Premise);
  Iterable<Connection> get connections => _assertions.values.where((a) => a is Connection).map((a) => a as Connection);

  Debate.fromJson(dynamic json) {
    Assertion jsonToAssertion(Map a) {
      if (Premise.TYPES.contains(a["type"])) {
        return new Premise.fromJson(a);
      } else if (Connection.TYPES.contains(a["type"])) {
        return new Connection.fromJson(a);
      } else {
        return null;
      }
    }

    json.map(jsonToAssertion).where((a) => a != null).forEach(add);
  }

  void refresh() {
    var getDisputedBy = (Assertion a) => connections.where((b) => b.type == "dispute").where((c) => c.assertionId == a.id).toList(growable: false);
    Map<String, List<Connection>> disputedBy = new Map.fromIterable(_assertions.values, key: (a) => a.id, value: getDisputedBy);

    var falsePremise = (Connection c) => c.premise.status == "false";
    var validDispute = (Connection c) => c.status == "undisputed" && c.premise.status == "undisputed";

    bool statusChanged = true;
    while (statusChanged) {
      statusChanged = false;
      for (Assertion a in _assertions.values) {
        if (a.status == "false") {
          continue;
        }

        String oldStatus = a.status;
        List<Connection> children = disputedBy[a.id];

        if (children == null || children.every(falsePremise)) {
          a.status = "undisputed";
        } else if (children.any(validDispute)) {
          a.status = "disputed";
        } else {
          a.status = "controversial";
        }

        if (oldStatus != a.status) {
          statusChanged = true;
        }
      }
    }
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

  Premise() {

  }
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

  Connection() {

  }
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
