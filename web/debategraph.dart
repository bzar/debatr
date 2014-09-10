library debategraph;

import "dart:html" show Element, MouseEvent, WheelEvent;
import "debate.dart";
import "package:charted/charted.dart";

class Layers {
  Selection nodes;
  Selection connectionNodes;
  Selection nodeTexts;
  Selection lines;
}

class Point {
  Point(this.x, this.y);
  num x;
  num y;
  operator -(Point other) => new Point(x - other.x, y - other.y);
  operator +(Point other) => new Point(x + other.x, y + other.y);
  operator /(num d) => new Point(x / d, y / d);
}

class MouseMovementTracker {
  Point previousPosition = null;
  Point position = null;
  Point get movement => previousPosition != null ? position - previousPosition : new Point(0, 0);

  void updateFromEvent(MouseEvent e) {
    previousPosition = position;
    position = new Point(e.client.x, e.client.y);
  }
}

typedef E AssertionSelectedCallback<E>(Assertion, DebateGraph);

class DebateGraph {

  SelectionScope scope;
  Selection svg;
  Debate debate;
  Layers layers;

  Assertion selected = null;
  AssertionSelectedCallback onSelected = null;

  Premise dragged = null;
  bool panning = false;
  MouseMovementTracker tracker = new MouseMovementTracker();

  num zoom = 1;
  Point origin = new Point(0, 0);
  Point get size => new Point(scope.root.clientWidth, scope.root.clientHeight);
  Point get center => origin + size / zoom / 2;

  num premiseNodeRadius = 10;
  num connectionNodeRadius = 5;
  
  static final Map<String, String> statusColors = {
    "undisputed": "#88cc88",
    "disputed": "#cc8888",
    "controversial": "#cccc88"
  };

  static final Map<String, String> connectionColors = {
    "dispute": "#ff8888",
    "support": "#88ff88",
    "cause": "#8888ff",
  };

  static final Map<String, String> premiseColors = {
    "statement": "#ffffff",
    "evidence": "#cccccc"
  };

  DebateGraph(String elementSelector, this.debate) {
    scope = new SelectionScope.selector(elementSelector);
    svg = scope.append("svg:svg")
        ..attr("width", "100%")
        ..attr("height", "100%");

    var defs = svg.append("svg:defs");
    var premiseMarker = defs.append("svg:marker")
    ..attr("id", "premise-arrow")
    ..attr("viewBox", "0 -5 10 10")
    ..attr("refX", 8 + premiseNodeRadius)
    ..attr("markerUnits", "userSpaceOnUse")
    ..attr("markerWidth", 10)
    ..attr("markerHeight", 10)
    ..attr("orient", "auto")
    ..attr("fill", "#aaa");    
    premiseMarker.append("svg:path")
    ..attr("d", "M0,-5L10,0L0,5");
    var connectionMarker = defs.append("svg:marker")
    ..attr("id", "connection-arrow")
    ..attr("viewBox", "0 -5 10 10")
    ..attr("refX", 8 + connectionNodeRadius)
    ..attr("markerUnits", "userSpaceOnUse")
    ..attr("markerWidth", 10)
    ..attr("markerHeight", 10)
    ..attr("orient", "auto")
    ..attr("fill", "#aaa");    
    connectionMarker.append("svg:path")
    ..attr("d", "M0,-5L10,0L0,5");

    Selection container = svg.append("g");
    layers = new Layers()
    ..lines = container.append("g")
    ..nodes = container.append("g")
    ..connectionNodes = container.append("g")
    ..nodeTexts = container.append("g");

    void mouseUp(dynamic d, int ei, Element e) {
      scope.event.preventDefault();
      scope.event.stopPropagation();
      dragged = null;
      panning = false;
    }

    void mouseDown(dynamic d, int ei, Element e) {
      scope.event.preventDefault();
      scope.event.stopPropagation();
      panning = true;
      MouseEvent e = scope.event as MouseEvent;
    }

    void mouseMove(dynamic d, int ei, Element e) {
      scope.event.preventDefault();
      scope.event.stopPropagation();
      MouseEvent e = scope.event as MouseEvent;
      if (dragged != null) {
        dragged.x += tracker.movement.x / zoom;
        dragged.y += tracker.movement.y / zoom;
        update();
      } else if (panning) {
        origin.x += tracker.movement.x;
        origin.y += tracker.movement.y;
        container.attr("transform", "translate(${origin.x}, ${origin.y})scale($zoom)");
        update();
      }
      tracker.updateFromEvent(e);
    }

    void wheel(dynamic d, int ei, Element e) {
      scope.event.preventDefault();
      scope.event.stopPropagation();
      WheelEvent e = scope.event as WheelEvent;
      if (e.deltaY > 0 && zoom > 0.5) {
        zoom -= 0.1;
      } else if (e.deltaY < 0 && zoom < 1) {
        zoom += 0.1;
      }
      container.attr("transform", "translate(${origin.x}, ${origin.y})scale($zoom)");
    }
    svg.on("mousemove", mouseMove);
    svg.on("mouseup", mouseUp);
    svg.on("mousedown", mouseDown);
    svg.on("wheel", wheel);
  }

  void selectAssertion(Assertion a) {
    selected = a;
    if (onSelected != null) {
      onSelected(a, this);
    }
    update();
  }
  void update() {
    var statusColor = (d, i, e) => statusColors[d.status];
    var connectionColor = (d, i, e) => connectionColors[d.type];
    var premiseColor = (d, i, e) => premiseColors[d.type];
    var getId = (a) => a.id;
    var isSelected = (d) => selected != null && d.id == selected.id;

    var lines = layers.lines.selectAll("line").data(debate.connections, getId);
    lines.enter.append("line")
    ..styleWithCallback("stroke", connectionColor)
    ..attrWithCallback("x1", (d, i, e) => d.premise.x)
    ..attrWithCallback("y1", (d, i, e) => d.premise.y)
    ..attrWithCallback("x2", (d, i, e) => d.assertion.x)
    ..attrWithCallback("y2", (d, i, e) => d.assertion.y)
    ..style("stroke-width", "3px")
    ..styleWithCallback("marker-end", (d,i,e) => (d.assertion is Premise ? "url(#premise-arrow)" : "url(#connection-arrow)"));

    lines.transition()
    ..duration(25)
    ..styleWithCallback("stroke", connectionColor)
    ..attrWithCallback("x1", (d, i, e) => d.premise.x)
    ..attrWithCallback("y1", (d, i, e) => d.premise.y)
    ..attrWithCallback("x2", (d, i, e) => d.assertion.x)
    ..attrWithCallback("y2", (d, i, e) => d.assertion.y);

    lines.exit.remove();

    var connectionNodes = layers.connectionNodes.selectAll("circle").data(debate.connections, getId);
    connectionNodes.enter.append("circle")
    ..attr("r", "5px")
    ..style("stroke", "#555")
    ..attrWithCallback("fill", statusColor)
    ..styleWithCallback("stroke-width", ((d, i, e) => isSelected(d) ? "2px" : "0px"))
    ..attrWithCallback("cx", (d, i, e) => d.x)
    ..attrWithCallback("cy", (d, i, e) => d.y)
    ..on("mousedown", (d, i, e) => selectAssertion(d));

    connectionNodes.transition()
    ..duration(25)
    ..attrWithCallback("fill", statusColor)
    ..styleWithCallback("stroke-width", ((d, i, e) => isSelected(d) ? "2px" : "0px"))
    ..attrWithCallback("cx", (d, i, e) => d.x)
    ..attrWithCallback("cy", (d, i, e) => d.y);

    connectionNodes.exit.remove();

    var statements = debate.premises.where((p) => p.type == "statement");
    var statementNodes = layers.nodes.selectAll("circle").data(statements, getId);
    statementNodes.enter.append("circle")
    ..attr("r", premiseNodeRadius)
    ..attr("fill", "#ffffff")
    ..attrWithCallback("cx", (d, i, e) => d.x)
    ..attrWithCallback("cy", (d, i, e) => d.y)
    ..styleWithCallback("stroke", statusColor)
    ..styleWithCallback("stroke-width", (d, i, e) => isSelected(d) ? "4px" : "2px")
    ..on("mousedown", (d, i, e) {
      dragged = d;
      selectAssertion(d);
    })
    ..on("mouseup", (d, i, e) => dragged = null);

    statementNodes.transition()
    ..duration(25)
    ..attrWithCallback("cx", (d, i, e) => d.x)
    ..attrWithCallback("cy", (d, i, e) => d.y)
    ..styleWithCallback("stroke", statusColor)
    ..styleWithCallback("stroke-width", (d, i, e) => isSelected(d) ? "4px" : "2px");

    statementNodes.exit.remove();

    var evidence = debate.premises.where((p) => p.type == "evidence");
    var evidenceNodes = layers.nodes.selectAll("rect").data(evidence, getId);
    evidenceNodes.enter.append("rect")
    ..attrWithCallback("x", (d, i, e) => d.x - premiseNodeRadius)
    ..attrWithCallback("y", (d, i, e) => d.y - premiseNodeRadius)
    ..attr("width", 2*premiseNodeRadius)
    ..attr("height", 2*premiseNodeRadius)
    ..attr("fill", "#ffffff")
    ..styleWithCallback("stroke", statusColor)
    ..styleWithCallback("stroke-width", (d, i, e) => isSelected(d) ? "4px" : "2px")
    ..on("mousedown", (d, i, e) {
      dragged = d;
      selectAssertion(d);
    })
    ..on("mouseup", (d, i, e) => dragged = null);

    evidenceNodes.transition()
    ..duration(25)
    ..attrWithCallback("x", (d, i, e) => d.x - premiseNodeRadius)
    ..attrWithCallback("y", (d, i, e) => d.y - premiseNodeRadius)
    ..styleWithCallback("stroke", statusColor)
    ..styleWithCallback("stroke-width", (d, i, e) => isSelected(d) ? "4px" : "2px");

    evidenceNodes.exit.remove();

    var nodeTexts = layers.nodeTexts.selectAll("text").data(debate.premises, getId);
    nodeTexts.enter.append("svg:text")
    ..style("font-family", "sans-serif")
    ..style("font-size", "14px")
    ..attrWithCallback("x", (d, i, e) => d.x + 12)
    ..attrWithCallback("y", (d, i, e) => d.y);

    var elide = (s, l) => s.length <= l ? s : s.substring(0, l) + "…";
    nodeTexts..textWithCallback((d, i, e) => elide(d.text, 48));

    nodeTexts.transition()
    ..duration(25)
    ..attrWithCallback("x", (d, i, e) => d.x + 12)
    ..attrWithCallback("y", (d, i, e) => d.y);

    nodeTexts.exit.remove();
  }
}
