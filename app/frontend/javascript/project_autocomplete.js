//
// This little snippet provides project name autocompletion the project
// comparison page - https://www.ruby-toolbox.com/compare
//
// Documentation for the library can be found at
// * https://github.com/alphagov/accessible-autocomplete?tab=readme-ov-file
// * https://alphagov.github.io/accessible-autocomplete/examples/
import accessibleAutocomplete from 'accessible-autocomplete'

export default function() {
  const fetchCompletions = function(term, callback) {
    fetch("/search/by_name?q=" + term)
      .then(function(response) {
        response.json().then(function(data) {
          callback(data);
        });
      });
  }

  document.querySelectorAll("label[for=comparison-autocomplete]").forEach((label) => {
    const id = 'comparison-autocomplete';

    accessibleAutocomplete({
      minLength: 1,
      element: document.getElementById(label.dataset.target),
      id: id,
      source: fetchCompletions,
      inputClasses: "input",
      displayMenu: "overlay",
      placeholder: "Type a project name to add it to the comparison",
      onConfirm: (term) => {
        // No idea why we have to do this one, but we have to do this one 🤷
        label.closest("form").querySelector("input[name=add]").value = term;
        label.closest("form").submit()
      },
      name: "add"
    });

    document.getElementById(id).focus();
  })
}
