(function () {
  var root = document.documentElement;

  // Theme toggle (the initial theme is set by the inline script in <head>)
  var themeBtn = document.querySelector('[data-theme-toggle]');
  if (themeBtn) {
    themeBtn.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) {}
    });
  }

  // Mobile menu
  var menuBtn = document.querySelector('[data-menu-toggle]');
  var links = document.querySelector('.nav-links');
  if (menuBtn && links) {
    menuBtn.addEventListener('click', function () {
      var open = links.classList.toggle('open');
      menuBtn.setAttribute('aria-expanded', open);
    });
    links.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') {
        links.classList.remove('open');
        menuBtn.setAttribute('aria-expanded', 'false');
      }
    });
  }

  // Header border on scroll
  var header = document.querySelector('.site-header');
  if (header) {
    var onScroll = function () { header.classList.toggle('scrolled', window.scrollY > 8); };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // Reveal on scroll
  var items = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });
    items.forEach(function (el) { io.observe(el); });
  } else {
    items.forEach(function (el) { el.classList.add('visible'); });
  }

  // Footer year
  var year = document.querySelector('[data-year]');
  if (year) year.textContent = new Date().getFullYear();

  // Live GitHub star counts (the static numbers in the HTML stay as a fallback)
  var starEls = document.querySelectorAll('[data-repo]');
  if (starEls.length && window.fetch) {
    fetch('https://api.github.com/users/ahmetkorkmaz3/repos?per_page=100')
      .then(function (r) { return r.ok ? r.json() : []; })
      .then(function (repos) {
        var map = {};
        repos.forEach(function (repo) { map[repo.name.toLowerCase()] = repo.stargazers_count; });
        starEls.forEach(function (el) {
          var count = map[el.getAttribute('data-repo').toLowerCase()];
          if (typeof count === 'number') el.textContent = count;
        });
      })
      .catch(function () {});
  }
})();
