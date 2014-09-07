library debategraph;

import "dart:html" show Element, MouseEvent, WheelEvent;
import 'debate.dart';
import 'package:charted/charted.dart';

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
  
  static final Map<String, String> nodeColors = {
    "undisputed": "#00f000",
    "disputed": "#f00000",
    "controversial": "#f0f000"
  };

  static final Map<String, String> connectionColors = {
    "dispute": "#f00000",
    "support": "#00f000"
  };

  DebateGraph(String elementSelector, this.debate) {
    scope = new SelectionScope.selector(elementSelector);
    svg = scope.append('svg:svg')
    ..attr("width", "100%")
    ..attr("height", "100%");
    
    Selection container = svg.append("g");
    layers = new Layers()
    ..lines = container.append("g")
    ..nodes = container.append("g")
    ..connectionNodes = container.append("g")
    ..nodeTexts =  container.append("g");
    
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
      if(dragged != null) {
        dragged.x += tracker.movement.x / zoom;
        dragged.y += tracker.movement.y / zoom;
        update();
      } else if(panning) {
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
      if(e.deltaY > 0 && zoom > 0.5) {
        zoom -= 0.1;
      } else if(e.deltaY < 0 && zoom < 1) {
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
    if(onSelected != null) {
      onSelected(a, this);
    }
    update();
  }
  void update() {
    var nodeColor = (d,i,e) => nodeColors[d.status];
    var connectionColor = (d,i,e) => connectionColors[d.type];
    var getId = (a) => a.id;
    var isSelected = (d) => selected != null && d.id == selected.id;
    var lines = layers.lines.selectAll("line").data(debate.connections, getId);
    lines.enter.append("line")
    ..styleWithCallback("stroke", connectionColor)
    ..attrWithCallback("x1", (d,i,e) => d.premise.x)
    ..attrWithCallback("y1", (d,i,e) => d.premise.y)
    ..attrWithCallback("x2", (d,i,e) => d.assertion.x)
    ..attrWithCallback("y2", (d,i,e) => d.assertion.y);
    
    lines.transition()
    ..duration(25)
    ..styleWithCallback("stroke", connectionColor)
    ..attrWithCallback("x1", (d,i,e) => d.premise.x)
    ..attrWithCallback("y1", (d,i,e) => d.premise.y)
    ..attrWithCallback("x2", (d,i,e) => d.assertion.x)
    ..attrWithCallback("y2", (d,i,e) => d.assertion.y);

    lines.exit.remove();
    
    var connectionNodes = layers.connectionNodes.selectAll("circle").data(debate.connections, getId);
    connectionNodes.enter.append("circle")
    ..attrWithCallback("cx", (d,i,e) => d.x)
    ..attrWithCallback("cy", (d,i,e) => d.y)
    ..attrWithCallback("fill", nodeColor)
    ..attr("r", "5px")
    ..style("stroke", "#888888")
    ..styleWithCallback("stroke-width", ((d,i,e) => isSelected(d) ? "1px" : "0"))
    ..on("mousedown", (d,i,e) => selectAssertion(d));
    
    connectionNodes.transition()
    ..duration(25)
    ..attrWithCallback("fill", nodeColor)
    ..styleWithCallback("stroke-width", ((d,i,e) => isSelected(d) ? "1px" : "0"))
    ..attrWithCallback("cx", (d,i,e) => d.x)
    ..attrWithCallback("cy", (d,i,e) => d.y);
      
    connectionNodes.exit.remove();

    var nodes = layers.nodes.selectAll("circle").data(debate.premises, getId);
    nodes.enter.append("circle")
    ..attrWithCallback("cx", (d,i,e) => d.x)
    ..attrWithCallback("cy", (d,i,e) => d.y)
    ..attrWithCallback("fill", nodeColor)
    ..attr("r", "10px")
    ..style("stroke", "#888888")
    ..styleWithCallback("stroke-width", ((d,i,e) => isSelected(d) ? "2px" : "0"))
    ..on("mousedown", (d,i,e) {
      dragged = d;
      selectAssertion(d);
    })
    ..on("mouseup", (d,i,e) => dragged = null);
    
    nodes.transition()
    ..duration(25)
    ..attrWithCallback("fill", nodeColor)
    ..attrWithCallback("cx", (d,i,e) => d.x)
    ..attrWithCallback("cy", (d,i,e) => d.y)
    ..styleWithCallback("stroke-width", (d,i,e) => isSelected(d) ? 2 : 0);
    
    nodes.exit.remove();
    
    var nodeTexts = layers.nodeTexts.selectAll("text").data(debate.premises, getId);
    nodeTexts.enter.append("svg:text")
    ..attrWithCallback("x", (d,i,e) => d.x)
    ..attrWithCallback("y", (d,i,e) => d.y)
    ..textWithCallback((d,i,e) => d.text);
    
    nodeTexts.transition()
    ..duration(25)
    ..attrWithCallback("x", (d,i,e) => d.x)
    ..attrWithCallback("y", (d,i,e) => d.y);
      
    nodeTexts.exit.remove();
  }
}
