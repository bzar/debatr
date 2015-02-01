import * as React from 'react';

export default function E(node) {
  function isChildren(x) { return x instanceof Array; }
  function isText(x) { return typeof x === "string"; }
  function createChildren(i) {
    return node.slice(i).reduce(function(res, val) { 
      return res.concat(val); 
    }).map(E);
  }

  if(!(node instanceof Array))
    return node;

  var element = node[0];
  var props = null;
  var text = null;
  var children = null;

  if(node.length > 1) {
    if(isChildren(node[1])) {
      children = createChildren(1);
    } else if(isText(node[1])) {
      text = node[1];
      if(isChildren(node[2])) {
        children = createChildren(2);
      }
    } else if(node.length == 2) {
      props = node[1];
    } else if(isChildren(node[2])) {
      props = node[1];
      children = createChildren(2);
    } else if(isText(node[2])) {
      props = node[1];
      text = node[2];
      if(isChildren(node[3])) {
        children = createChildren(3);
      }
    }
  }
  return React.createElement(element, props, text, children);
}