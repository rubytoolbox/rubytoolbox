// Some small snippets to put things into loading state to give users
// visual feedback that something is going on
export default function() {
  document.querySelectorAll("form.search-form").forEach(function(form) {
    form.addEventListener("submit", function() {
      document.querySelectorAll("form.search-form button[type=submit]").forEach(function(button) {
        button.classList.add("is-loading");
      });
    })
  });

  // When the bugfix forks toggle is clicked on the search the HTTP response takes
  // a tad too long to process without visual feedback to the user that something has happened,
  // therefore we put it into the loading state (and when going back in history ensure to revert
  // that state)
  document.querySelectorAll("a.bugfix-forks-toggle").forEach(function(button) {
    button.classList.remove("is-loading");
    button.addEventListener("click", function() {
      button.classList.add("is-loading");
    });
  });

  document.querySelectorAll(".project-display-picker .button").forEach(function(button) {
    button.classList.remove("is-loading");
    button.addEventListener("click", function() {
      button.classList.add("is-loading");
    });
  });

  // See above, just for the custom project order dropdown
  document.querySelectorAll(".project-order-dropdown .dropdown-content a").forEach(function(button) {
    document.querySelectorAll(".project-order-dropdown button").forEach(function(dropdown) {
      dropdown.classList.remove("is-loading");
    });
    button.addEventListener("click", function() {
      document.querySelectorAll(".project-order-dropdown button").forEach(function(dropdown) {
        dropdown.classList.add("is-loading");
      });
    });
  });
}
