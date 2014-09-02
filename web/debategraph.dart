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

class DebateGraph {
  SelectionScope scope;
  Selection svg;
  Debate debate;
  Layers layers;

  Premise dragged = null;
  bool panning = false;
  
  num zoom = 1;
  num originx = 0;
  num originy = 0;
  
  static final Map<String, String> nodeColors = {
    "undisputed": "#0f0",
    "disputed": "#f00",
    "controversial": "#ff0"
  };

  static final Map<String, String> connectionColors = {
    "dispute": "#f00",
    "support": "#0f0"
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
      dragged = null;
      panning = false;
    }
    
    void mouseDown(dynamic d, int ei, Element e) {
      panning = true;
    }
    
    void mouseMove(dynamic d, int ei, Element e) {
      scope.event.preventDefault();
      scope.event.stopPropagation();
      MouseEvent e = scope.event as MouseEvent;
      if(dragged != null) {
        dragged.x += e.movement.x / zoom;
        dragged.y += e.movement.y / zoom;
      } else if(panning) {
        originx += e.movement.x;
        originy += e.movement.y;
        container.attr("transform", "translate($originx, $originy)scale($zoom)");
      }
      update();
    }
    
    void wheel(dynamic d, int ei, Element e) {
      scope.event.preventDefault();
      scope.event.stopPropagation();
      WheelEvent e = scope.event as WheelEvent;
      if(e.wheelDeltaY < 0 && zoom > 0.5) {
        zoom -= 0.1;
      } else if(e.wheelDeltaY > 0 && zoom < 1) {
        zoom += 0.1;
      }
      container.attr("transform", "translate($originx, $originy)scale($zoom)");
    }
    svg.on("mousemove", mouseMove);
    svg.on("mouseup", mouseUp);
    svg.on("mousedown", mouseDown);
    svg.on("wheel", wheel);
  }
  
  void update() {
    var nodeColor = (d,i,e) => nodeColors[d.status];
    var connectionColor = (d,i,e) => connectionColors[d.type];
    var getId = (a) => a.id;
    
    var lines = layers.lines.selectAll("line").data(debate.connections, getId);
    lines.enter.append("line")
      ..styleWithCallback("stroke", connectionColor)
      ..attrWithCallback("x1", (d,i,e) => d.premise.x)
      ..attrWithCallback("y1", (d,i,e) => d.premise.y)
      ..attrWithCallback("x2", (d,i,e) => d.assertion.x)
      ..attrWithCallback("y2", (d,i,e) => d.assertion.y);
    
    lines.transition()
      ..duration(25)
    //  ..styleWithCallback("stroke", connectionColor)
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
      ..attr("r", "5px");
    
    connectionNodes.transition()
      ..duration(25)
    //  ..attrWithCallback("fill", nodeColor)
      ..attrWithCallback("cx", (d,i,e) => d.x)
      ..attrWithCallback("cy", (d,i,e) => d.y);
      
    connectionNodes.exit.remove();

    var nodes = layers.nodes.selectAll("circle").data(debate.premises, getId);
    nodes.enter.append("circle")
      ..attrWithCallback("cx", (d,i,e) => d.x)
      ..attrWithCallback("cy", (d,i,e) => d.y)
      ..attrWithCallback("fill", nodeColor)
      ..attr("r", "10px")
      ..on("mousedown", (d,i,e) => dragged = d)
      ..on("mouseup", (d,i,e) => dragged = null);
    
    nodes.transition()
      ..duration(25)
      //..attrWithCallback("fill", nodeColor)
      ..attrWithCallback("cx", (d,i,e) => d.x)
      ..attrWithCallback("cy", (d,i,e) => d.y);
    
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
