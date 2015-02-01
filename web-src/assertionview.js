import * as React from 'react';
import * as Reflux from 'reflux';
import * as Debate from './debate.js';
import E from './E.js';
import {findFirst, titleCase} from './util.js'
import {assertionLink} from './assertionlink.js';

function assertionTypeText(a) {
  return a ? titleCase(`${a.status} ${a.type}`) : '';
}

export var assertionView = React.createClass({
  mixins: [
    Reflux.connect(Debate.store,"debate")
  ],
  getInitialState: function() {
    return {
      debate: Debate.emptyDebate(), 
      selected: {}
    };
  },
  getSelectedAssertion: function() {
    return this.getAssertion(this.state.debate.selected);
  },
  getAssertion: function(assertionId) {
    if(assertionId == null || assertionId < 0)
      return {};
    return findFirst(v => v.id === assertionId, this.state.debate.assertions);
  },
  
  getNextAssertions: function(current) {
    var isNext = a => a.assertion === current.id || a.id === current.premise;
    return current ? this.state.debate.assertions.filter(isNext) : [];
  },
  getPrevAssertions: function(current) {
    var isPrev = a => a.premise === current.id || a.id === current.assertion;
    return current ? this.state.debate.assertions.filter(isPrev) : [];
  },
  getAssertionLink: function(a, prev) {
    var target = null;
    if(Debate.isConnection(a)) {
      target = this.getAssertion(prev ? a.assertion : a.premise);
    }
    return [assertionLink, {
      key: a.id,
      assertion: a, 
      target: target,
      rightToLeft: prev
    }];
  },
  disputeCurrent: function(e) {
    Debate.actions.createAndSelectConnectedAssertion(this.state.debate.selected, 'dispute', {
      type: 'statement',
      text: ''
    });
  },
  supportCurrent: function(e) {
    Debate.actions.createAndSelectConnectedAssertion(this.state.debate.selected, 'support', {
      type: 'evidence',
      text: ''
    });
  },
  getSelectedAssertionView: function(assertion) {
    var get = f => assertion ? assertion[f] : '';
    var set = f => e => {
      assertion[f] = e.target.value;
      Debate.actions.updateAssertion(assertion);
    }
    var disabled = assertion.id === undefined;
    
    var content = [];
    if(assertion.text !== undefined) {
      content.push(['input', {
        value: get('text'), 
        onChange: set('text'), 
        disabled: disabled
      }]);
    }
    
    var tools = [];
    tools.push(['button', {
      onClick: this.disputeCurrent
    }, 'Dispute']);
    tools.push(['button', {
      onClick: this.supportCurrent
    }, 'Support']);
    return ['div', {className: `assertionView-content ${assertion.type} ${assertion.status}`},
                [['h2', assertionTypeText(assertion)]], content, tools] 
    
  },
  
  
  render: function() {
    var assertion = this.getSelectedAssertion();
    var next = ['ul', {className: 'assertionView-connections next'}, 
      this.getNextAssertions(assertion).map(a => ['li', [this.getAssertionLink(a, false)]])];
    var prev = ['ul', {className: 'assertionView-connections prev'}, 
      this.getPrevAssertions(assertion).map(a => ['li', [this.getAssertionLink(a, true)]])];
    return E(['div', {className: 'assertionView'}, 
             [prev, this.getSelectedAssertionView(assertion), next]]);
  }       
  
});