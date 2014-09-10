import 'dart:html';
import 'debate.dart';
import 'debategraph.dart';

void main() {
  var debateJson = [
    { "id": "0", "type": "statement", "status": "disputed", "x": 20, "y": 50 , "text": "Earth is flat" },
    { "id": "1", "type": "statement", "status": "undisputed", "x": 220, "y": 50, "text": "Far away mountains only show their top" },
    { "id": "2", "type": "dispute", "assertion": "0", "premise": "1", "status": "undisputed" },
    { "id": "3", "type": "evidence", "text": "http://en.wikipedia.org/wiki/History_of_geodesy", "status": "undisputed", "x": 500, "y": 70 },
    { "id": "4", "type": "support", "assertion": "1", "premise": "3", "status": "undisputed" }
  ];

  Debate debate = new Debate.fromJson(debateJson);

  DebateGraph graph = new DebateGraph("#graph", debate);
  graph.update();

  Assertion target;
  String connectionType;
  
  graph.onSelected = (a, g) {
    if(target != null) {
      Connection connection = new Connection()
      ..type = connectionType
      ..status = "undisputed"
      ..premiseId = target.id
      ..assertionId = a.id;
      debate.add(connection);
      debate.refresh();
      graph.update();
      target = null;
    }
    updateAssertionInfo(a);
  };

  document.querySelector("#tools").onSubmit.listen((Event e) {
    e.preventDefault();
  });
  document.querySelector("#assertion-info").onSubmit.listen((Event e) {
    e.preventDefault();
  });
  document.querySelector("#addStatement").onClick.listen((Event e) {
    e.preventDefault();
    Premise statement = new Premise()
    ..type = "statement"
    ..text = ""
    ..status = "undisputed"
    ..x = graph.center.x
    ..y = graph.center.y;

    String statementId = debate.add(statement);
    graph.selectAssertion(debate.get(statementId));
  });
  document.querySelector("#addEvidence").onClick.listen((Event e) {
      e.preventDefault();
      Premise statement = new Premise()
      ..type = "evidence"
      ..text = ""
      ..status = "undisputed"
      ..x = graph.center.x
      ..y = graph.center.y;

      String statementId = debate.add(statement);
      graph.selectAssertion(debate.get(statementId));
  });
  
  
  document.querySelector("#addDispute").onClick.listen((Event e) {
    e.preventDefault();
    if(graph.selected != null) {
      target = graph.selected;
      connectionType = "dispute";
    }
  });  
  document.querySelector("#addSupport").onClick.listen((Event e) {
    e.preventDefault();
    if(graph.selected != null) {
      target = graph.selected;
      connectionType = "support";
    }
  });
  document.querySelector("#addCause").onClick.listen((Event e) {
    e.preventDefault();
    if(graph.selected != null) {
      target = graph.selected;
      connectionType = "cause";
    }
  });
  document.querySelector("#assertion-statement").onInput.listen((Event e) {
    if(graph.selected != null && graph.selected is Premise) {
      (graph.selected as Premise).text = (document.querySelector("#assertion-statement") as InputElement).value;
      graph.update();
    }
  });
}

void updateAssertionInfo(Assertion a) {
  var setText = (sel, t) => document.querySelector(sel).text = t;
  setText("#assertion-type", a.type);
  setText("#assertion-status", a.status);
  if(a is Premise) {
    (document.querySelector("#assertion-statement") as InputElement).value = a.text;
  } else {
    setText("#assertion-target", a is Connection ? a.assertionId : "");
    setText("#assertion-premise", a is Connection ? a.premiseId : "");
  }
    
  document.querySelector("#assertion-target-item").hidden = a is Premise;
  document.querySelector("#assertion-premise-item").hidden = a is Premise;
  document.querySelector("#assertion-statement-item").hidden = a is Connection;
}
