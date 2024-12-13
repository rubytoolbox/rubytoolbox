// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

console.log('Welcome to the Ruby Toolbox 👋🎉')
console.log('Feel free to pass by https://github.com/rubytoolbox and contribute, see you there!')

import Headroom from "headroom.js"

import Charts from "~/javascript/charts"
// FIXME: Replace the inline JS from the components with something more sensible
window.Charts = Charts

import BurgerHandler from "~/javascript/bulma_burger"
import DocsAsideHandler from "~/javascript/docs_aside_handler"
import LoadingStateHandlers from "~/javascript/loading_state_handlers"
import ProjectAutocomplete from "~/javascript/project_autocomplete"
import FixReadmeOverflow from "~/javascript/fix_readme_overflow"

document.addEventListener("DOMContentLoaded", function () {
  // Make the sticky top nav hide on scroll, re-appear on scrolling up.
  // See https://wicky.nillia.ms/headroom.js/
  new Headroom(document.querySelector("header.main .navbar"), { offset: 250 }).init();

  BurgerHandler();
  DocsAsideHandler();
  LoadingStateHandlers();
  ProjectAutocomplete();
  FixReadmeOverflow()
});
