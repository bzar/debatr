import * as React from 'react';
import E from './E.js';
import * as Debate from './debate.js';
import {assertionView} from './assertionview.js';

var ui = React.createClass({
  render: function() { 
    return E(['div', [
        ['h1', 'Debatr!'],
        [assertionView],
    ]]);
  }
});

React.render(React.createElement(ui), document.getElementById('ui'));

function populateTestData() {
  var aDebate = [
    { id: 0, type: "statement", text: "Earth is flat", status: "disputed", x: 20, y: 50 },
    { id: 1, type: "statement", status: "undisputed", x: 220, y: 50, text: "Far away mountains only show their top" },
    { id: 3, type: "evidence", text: "http://en.wikipedia.org/wiki/History_of_geodesy", status: "undisputed", x: 500, y: 70 },
    { id: 2, type: "dispute", assertion: 0, premise: 1, status: "undisputed" },
    { id: 4, type: "support", assertion: 1, premise: 3, status: "undisputed" }
  ];

  aDebate.map(Debate.actions.createAssertion);
}


populateTestData();
Debate.actions.selectAssertion(0);

