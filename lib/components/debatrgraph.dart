library debatrgraph;

import 'dart:html';
import 'package:debatr/debategraph.dart';
export 'package:debatr/debategraph.dart' show Debate;
import 'package:angular/angular.dart';

@Component(
    selector: "debatr-graph",
    publishAs: "cmp",
    templateUrl: "packages/debatr/components/debatrgraph.html")
class DebatrGraph implements ShadowRootAware {
  DebateGraph graph;
  
  @NgOneWay("debate")
  Debate get debate => _debate;
  set debate(Debate d) {
    _debate = d;
    _createGraph();
  }
    
  Assertion get selected => graph != null ? graph.selected : null;
  Premise get selectedPremise => selected is Premise ? selected : null;
  Connection get selectedConnection => selected is Connection ? selected : null;
  
  String get selectedPremiseText => selectedPremise != null ? selectedPremise.text : null;
  void set selectedPremiseText(String text) {
    if(selectedPremise != null) {
      selectedPremise.text = text;
      graph.update();
    }
  }

  Scope _scope;
  Debate _debate;
  ShadowRoot _shadowRoot;
    
  // Input state variables
  Assertion _target;
  String _connectionType;
  
  DebatrGraph(Scope scope) {
    _scope = scope;
  }
  
  void addStatement() {
    Premise statement = new Premise()
            ..type = "statement"
            ..text = ""
            ..status = "undisputed"
            ..x = graph.center.x
            ..y = graph.center.y;

        String statementId = debate.add(statement);
        graph.selectAssertion(debate.get(statementId));
  }
  
  void addEvidence() {
    Premise evidence = new Premise()
            ..type = "evidence"
            ..text = ""
            ..status = "undisputed"
            ..x = graph.center.x
            ..y = graph.center.y;

        String evidenceId = debate.add(evidence);
        graph.selectAssertion(debate.get(evidenceId));
  }
  
  void addDispute() {
    if (graph.selected != null) {
          _target = graph.selected;
          _connectionType = "dispute";
        }
  }
  
  void addSupport() {
    if (graph.selected != null) {
          _target = graph.selected;
          _connectionType = "support";
        }
  }
  
  void addCause() {
    if (graph.selected != null) {
          _target = graph.selected;
          _connectionType = "cause";
        }
  }

  
  void onShadowRoot(ShadowRoot shadowRoot) {
    _shadowRoot = shadowRoot;
    _createGraph();
  }
  
  void _createGraph() {
    if(_debate != null && _shadowRoot != null) {
      graph = new DebateGraph(_shadowRoot.querySelector("#graph"), debate);
      graph.update();
      
      graph.onSelected = (a, g) {
        if (_target != null) {
          Connection connection = new Connection()
              ..type = _connectionType
              ..status = "undisputed"
              ..premiseId = _target.id
              ..assertionId = a.id;
          debate.add(connection);
          debate.refresh();
          _target = null;
        }
        _scope.apply(); // Refresh info fields
      };      
    }
  }  
}
