import React, { Component } from 'react';

export class FetchMenuOptions extends Component {
  static displayName = FetchMenuOptions.name;

  constructor(props) {
    super(props);
    this.state = { options: [], loading: true };
  }

  async populateMenuOptions() {
    const response = await fetch('menuoptions');
    const data = await response.json();
    this.setState({ options: data, loading: false });
  }
}

  return(
    <div className="btn-containers">
      <button type="button" className="filter-btn" onClick={this.populateMenuOptions}>Fetch Menu Options</button>
    </div>
  );