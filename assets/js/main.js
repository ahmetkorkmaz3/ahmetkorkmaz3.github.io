(function () {
  // Footer year
  var year = document.querySelector('[data-year]');
  if (year) year.textContent = new Date().getFullYear();

  // Highlight the nav link of the section in view
  var navLinks = document.querySelectorAll('.nav a');
  if (navLinks.length && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        navLinks.forEach(function (a) {
          a.classList.toggle('active', a.getAttribute('href') === '#' + entry.target.id);
        });
      });
    }, { rootMargin: '-30% 0px -60% 0px' });
    document.querySelectorAll('main section[id]').forEach(function (s) { io.observe(s); });
  }

  // 3D gallery filter. Without JavaScript the buttons stay hidden and every card shows.
  var filters = document.querySelector('.filters');
  if (filters) {
    var cards = document.querySelectorAll('.cards [data-kind]');
    filters.hidden = false;
    filters.addEventListener('click', function (event) {
      var button = event.target.closest('[data-filter]');
      if (!button) return;
      var kind = button.getAttribute('data-filter');
      filters.querySelectorAll('[data-filter]').forEach(function (b) {
        b.setAttribute('aria-pressed', String(b === button));
      });
      cards.forEach(function (card) {
        card.hidden = kind !== 'all' && card.getAttribute('data-kind') !== kind;
      });
    });
  }

  // Live GitHub star counts for "owner/repo" values (the static numbers in the HTML stay as a fallback)
  if (window.fetch) {
    document.querySelectorAll('[data-repo]').forEach(function (el) {
      fetch('https://api.github.com/repos/' + el.getAttribute('data-repo'))
        .then(function (r) { return r.ok ? r.json() : null; })
        .then(function (repo) {
          if (repo && typeof repo.stargazers_count === 'number') el.textContent = repo.stargazers_count;
        })
        .catch(function () {});
    });
  }
})();
