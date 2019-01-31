// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require chart.js/dist/Chart.bundle.js
//= require headroom.js/dist/headroom
//= require_tree .

document.addEventListener("turbolinks:load", function () {
  // Make the sticky top nav hide on scroll, re-appear on scrolling up.
  // See https://wicky.nillia.ms/headroom.js/
  new Headroom(document.querySelector("header.main .navbar"), { offset: 250 }).init();

  // Snippet to enable the bulma burger menu in mobile
  // taken from https://bulma.io/documentation/components/navbar/#navbar-menu

  // Get all "navbar-burger" elements
  var $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {

    // Add a click event on each of them
    $navbarBurgers.forEach(function (el) {
      el.addEventListener('click', function () {

        // Get the target from the "data-target" attribute
        var target = el.dataset.target;
        var $target = document.getElementById(target);

        // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');
      });
    });
  }

  document.querySelectorAll('.documentation aside .toggle').forEach(function(toggle) {
    toggle.addEventListener("click", function() {
      this.parentNode.classList.toggle('is-active');
    })
  });

  Chart.defaults.global.defaultFontFamily = 'Lato, "Helvetica Neue", Helvetica, Arial, sans-serif';
  Chart.defaults.global.defaultFontSize = 12;
  Chart.defaults.global.defaultFontStyle = "bold";
  Chart.defaults.global.animation = 0;


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
});

