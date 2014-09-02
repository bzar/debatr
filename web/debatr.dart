//import 'dart:html' as html;
import 'debate.dart';
import 'debategraph.dart';
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

  DebateGraph graph = new DebateGraph("#graph", debate);
  graph.update();
}
