import * as React from 'react';
import E from './E.js';
import * as Debate from './debate.js';

export var assertionLink = React.createClass({
  linkTo: function(assertion, single) {
    function selectAssertionFun(id) {
      return function() {
        Debate.actions.selectAssertion(id); 
      }
    }
    var text = {
      statement: assertion.text,
      evidence: assertion.text,
      dispute: this.props.rightToLeft ? 'Disputes' : 'Disputed by',
      support: this.props.rightToLeft ? 'Supports' : 'Supported by',
      cause: this.props.rightToLeft ? 'Causes' : 'Caused by'
    }[assertion.type];
    
    return ['a', {
      className: `assertionView-link ${assertion.type} ${assertion.status} ${single ? 'single' : ''}`,
      href: '#', 
      onClick: selectAssertionFun(assertion.id )
    }, text];
  },
  render: function() {
    var links = [];
    if(this.props.assertion) {
      links.push(this.linkTo(this.props.assertion, !this.props.target));
    }
    if(this.props.target) {
      links.push(this.linkTo(this.props.target));
    }
    if(this.props.rightToLeft) {
      links.reverse();
    }
  
    return E(['div', links]);
  } 
})