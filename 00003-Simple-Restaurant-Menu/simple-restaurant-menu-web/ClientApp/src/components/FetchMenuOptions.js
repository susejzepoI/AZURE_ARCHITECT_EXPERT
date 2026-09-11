import React, { Component } from 'react';

export class FetchMenuOptions extends Component {
  static displayName = FetchMenuOptions.name;

  constructor(props) {
    super(props);
    this.state = { options: [], loading: true };
  }

  componentDidMount() {
    this.populateMenuOptions();
  }

  static renderMenuOptionsTable(options) {
    return (
      <table className="table table-striped" aria-labelledby="tableLabel">
        <thead>
          <tr>
            <th>Menu Option</th>
          </tr>
        </thead>
        <tbody>
          {options.map(option =>
            <tr key={option}>
              <td>{option}</td>
            </tr>
          )}
        </tbody>
      </table>
    );
  }

  render() {
    let contents = this.state.loading
      ? <p><em>Loading...</em></p>
      : FetchMenuOptions.renderMenuOptionsTable(this.state.options);

    return (
      <div>
        <h1 id="tableLabel">Menu Options</h1>
        <p>This component demonstrates fetching menu options from the server.</p>
        {contents}
      </div>
    );
  }

  async populateMenuOptions() {
    const response = await fetch('menuoptions');
    const data = await response.json();
    this.setState({ options: data, loading: false });
  }
}