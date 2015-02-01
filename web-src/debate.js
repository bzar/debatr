import * as Reflux from 'reflux';
import {findFirstIndex} from './util.js'

export var actions = Reflux.createActions([
  'createAssertion', 'deleteAssertion', 'updateAssertion', 'selectAssertion',
  'createAndSelectConnectedAssertion'
]);

export function emptyDebate() {
  return {
    assertions: [],
    selected: null
  };
}

export function isConnection(assertion)
{
  return ['dispute', 'support'].indexOf(assertion.type) >= 0;
}

export function isClaim(assertion)
{
  return !isConnection(assertion);
}

export var store = Reflux.createStore({
  debate: emptyDebate(),
  previousId: -1,
  listenables: [actions],
  onCreateAssertion: function(assertion) {
    if(assertion.id === undefined) {
      assertion.id = ++this.previousId;
    } else if(assertion.id > this.previousId) {
      this.previousId = assertion.id;
    }
    assertion.status = 'undisputed';
    this.debate.assertions.push(assertion);
    updateDebate(this.debate.assertions);
    this.trigger(this.debate);
  },
  onDeleteAssertion: function(assertionId) {
    var index = findFirstIndex(v => v.id === assertionId, this.debate.assertions);
    if(index >= 0)
    {
      this.debate.assertions.splice(index, 1);
      updateDebate(this.debate.assertions);
      this.trigger(this.debate);
    }
  },
  onUpdateAssertion: function(assertion) {
    var index = findFirstIndex(v => v.id === assertion.id, this.debate.assertions);
    if(index >= 0)
    {
      this.debate.assertions[index] = assertion;
      updateDebate(this.debate.assertions);
      this.trigger(this.debate);
    }
  },
  onSelectAssertion: function(assertionId) {
    this.debate.selected = assertionId;  
    this.trigger(this.debate);
  },
  onCreateAndSelectConnectedAssertion: function(parentId, connectionType, assertion) {
    this.onCreateAssertion(assertion);
    this.onCreateAssertion({
      type: connectionType,
      assertion: parentId,
      premise: assertion.id
    });
    this.onSelectAssertion(assertion.id);
  }
});

function updateDebate(debate) {
  var debateById = {};
  var disputedBy = {};
  for(var i = 0; i < debate.length; ++i) {
    var assertion = debate[i];
    debateById[assertion.id] = assertion;
    if(assertion.type === "dispute") {
      var children = disputedBy[assertion.assertion];
      if(!children) {
        children = [];
        disputedBy[assertion.assertion] = children;
      }
      children.push(assertion);
    }
  }

  function falsePremise(connection) {
    return debateById[connection.premise].status === "false";
  }

  function validDispute(connection) {
    return connection.status === "undisputed" && 
      debateById[connection.premise].status === "undisputed";
  }

  var statusChanged = true;
  while(statusChanged) {
    statusChanged = false;
    for(var i = 0; i < debate.length; ++i) {
      var assertion = debate[i];

      if(assertion.status === "false")
        continue;

      var oldStatus = assertion.status;
      var children = disputedBy[assertion.id];
      if(!children || children.every(falsePremise)) {
        assertion.status = "undisputed";
      } else if(children.some(validDispute)) {
        assertion.status = "disputed";
      } else {
        assertion.status = "controversial";
      }

      if(oldStatus !== assertion.status) {
        statusChanged = true;
      }
    } 
  }
}