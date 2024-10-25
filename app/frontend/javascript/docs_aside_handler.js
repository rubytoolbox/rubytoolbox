// Similar to bulma_burger, this makes the documentation mobile
// nav toggleable
export default function() {
  document.querySelectorAll('.documentation aside .toggle').forEach(function(toggle) {
    toggle.addEventListener("click", function() {
      this.parentNode.classList.toggle('is-active');
    })
  });
}
