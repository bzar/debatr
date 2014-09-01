//import 'dart:html' as html;  
import 'package:charted/charted.dart';

void main() {
  var debateJson = [
    { "id": "0", "type": "statement", "status": "disputed", "x": 20, "y": 50 , "text": "Earth is flat" },
    { "id": "1", "type": "statement", "status": "undisputed", "x": 220, "y": 50, "text": "Far away mountains only show their top" },
    { "id": "2", "type": "dispute", "assertion": "0", "premise": "1", "status": "undisputed" },
    { "id": "3", "type": "evidence", "text": "http://en.wikipedia.org/wiki/History_of_geodesy", "status": "undisputed", "x": 500, "y": 70 },
    { "id": "4", "type": "support", "assertion": "1", "premise": "3", "status": "undisputed" }
  ];
    
  Debate debate = new Debate.fromJson(debateJson);
  
  SelectionScope scope = new SelectionScope.selector('#graph');
  Selection svg = scope.append('svg:svg')
    ..attr('width', "100%")
    ..attr('height', "50%");
  
  Layers layers = new Layers()
    ..lines = svg.append("g")  
    ..nodes = svg.append("g")
    ..connectionNodes = svg.append("g")
    ..nodeTexts =  svg.append("g");
  
  updateGraph(debate, layers);
}

void updateGraph(Debate debate, Layers layers) {
  Map<String, String> nodeColors = {
    "undisputed": "#0f0",
    "disputed": "#f00",
    "controversial": "#ff0"
  };
  var nodeColor = (d,i,e) => nodeColors[d.status];
  
  Map<String, String> connectionColors = {
    "dispute": "#f00",
    "support": "#0f0"
  };
  var connectionColor = (d,i,e) => connectionColors[d.type];
  
  var getId = (a) => a.id;
  
  var lines = layers.lines.selectAll("line").data(debate.connections, getId);
  lines.enter.append("line")
    ..styleWithCallback("stroke", connectionColor)
    ..attrWithCallback("x1", (d,i,e) => d.premise.x)
    ..attrWithCallback("y1", (d,i,e) => d.premise.y)
    ..attrWithCallback("x2", (d,i,e) => d.assertion.x)
    ..attrWithCallback("y2", (d,i,e) => d.assertion.y);

  var connectionNodes = layers.connectionNodes.selectAll("circle").data(debate.connections, getId);
  connectionNodes.enter.append("circle")
    ..attrWithCallback("cx", (d,i,e) => d.x)
    ..attrWithCallback("cy", (d,i,e) => d.y)
    ..attrWithCallback("fill", nodeColor)
    ..attr("r", "5px");

  var nodes = layers.nodes.selectAll("circle").data(debate.premises, getId);
  nodes.enter.append("circle")
    ..attrWithCallback("cx", (d,i,e) => d.x)
    ..attrWithCallback("cy", (d,i,e) => d.y)
    ..attrWithCallback("fill", nodeColor)
    ..attr("r", "10px");
  
  var nodeTexts = layers.nodeTexts.selectAll("text").data(debate.premises, getId);
  nodeTexts.enter.append("svg:text")
    ..attrWithCallback("x", (d,i,e) => d.x)
    ..attrWithCallback("y", (d,i,e) => d.y)
    ..textWithCallback((d,i,e) => d.text);
  
}

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

class Layers {
  Selection nodes;
  Selection connectionNodes;
  Selection nodeTexts;
  Selection lines;
}

