//
// We sync the README html of github repositories from their API,
// but <table> elements there aren't wrapped in a container and break
// the horizontal frame in mobile view.
//
// We could fix this by doing a Nokogiri parse / preprocess step,
// but just doing it ad-hoc in the browser seems the lower friction way
//
export default function() {
  document.querySelectorAll("section.readme .content > div table").forEach((table) => {
    const wrapper = document.createElement('div');
    // Standard bulma responsive table & styling classes
    wrapper.classList.add("table-container");
    table.classList.add("table");
    table.parentNode.insertBefore(wrapper, table);
    wrapper.appendChild(table);
  });
}
