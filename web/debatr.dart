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

  graph.onSelected = (a, g) {
    updateAssertionInfo(a);
  };

  document.querySelector("#dispute").onSubmit.listen((Event e) {
    e.preventDefault();
    if(graph.selected != null) {
      Premise statement = new Premise()
      ..type = "statement"
      ..text = (document.querySelector("#dispute-text") as InputElement).value
      ..status = "undisputed"
      ..x = graph.selected.x + 100
      ..y = graph.selected.y;

      String statementId = debate.add(statement);

      Connection dispute = new Connection()
      ..type = "dispute"
      ..status = "undisputed"
      ..assertionId = graph.selected.id
      ..premiseId = statementId;

      debate.add(dispute);

      debate.refresh();
      graph.update();
    }

  });

  document.querySelector("#support").onSubmit.listen((Event e) {
      e.preventDefault();
      if(graph.selected != null) {
        Premise statement = new Premise()
        ..type = "statement"
        ..text = (document.querySelector("#support-text") as InputElement).value
        ..status = "undisputed"
        ..x = graph.selected.x + 100
        ..y = graph.selected.y;

        String statementId = debate.add(statement);

        Connection support = new Connection()
        ..type = "support"
        ..status = "undisputed"
        ..assertionId = graph.selected.id
        ..premiseId = statementId;

        debate.add(support);

        debate.refresh();
        graph.update();
      }

    });
}

void updateAssertionInfo(Assertion a) {
  var setText = (sel, t) => document.querySelector(sel).text = t;
  setText("#assertion-type", a.type);
  setText("#assertion-statement", a is Premise ? a.text : "");
  setText("#assertion-status", a.status);
  setText("#assertion-target", a is Connection ? a.assertionId : "");
  setText("#assertion-premise", a is Connection ? a.premiseId : "");
}
