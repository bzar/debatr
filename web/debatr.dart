import 'package:debatr/components/debatrgraph.dart';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@Controller(
    selector: "[debatr]",
    publishAs: "debatr")
class Debatr {
  Debate debate;
  
  Debatr() {
    var debateJson = [{
        "id": "0",
        "type": "statement",
        "status": "disputed",
        "x": 20,
        "y": 50,
        "text": "Earth is flat"
      }, {
        "id": "1",
        "type": "statement",
        "status": "undisputed",
        "x": 220,
        "y": 50,
        "text": "Far away mountains only show their top"
      }, {
        "id": "2",
        "type": "dispute",
        "assertion": "0",
        "premise": "1",
        "status": "undisputed"
      }, {
        "id": "3",
        "type": "evidence",
        "text": "http://en.wikipedia.org/wiki/History_of_geodesy",
        "status": "undisputed",
        "x": 500,
        "y": 70
      }, {
        "id": "4",
        "type": "support",
        "assertion": "1",
        "premise": "3",
        "status": "undisputed"
      }];

    debate = new Debate.fromJson(debateJson);
  }
}


class DebatrModule extends Module {
  DebatrModule() {
    bind(Debatr);
    bind(DebatrGraph);
  }
}
void main() {
  applicationFactory()
        .addModule(new DebatrModule())
        .run();
}
  