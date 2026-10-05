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

  // 3D page lightbox. Without JavaScript (or without <dialog>) the tiles stay plain links to the files.
  var tiles = document.querySelectorAll('.gallery .tile');
  if (tiles.length && window.HTMLDialogElement) {
    var box = document.createElement('dialog');
    box.className = 'lightbox';
    box.setAttribute('aria-label', 'Gallery');
    box.innerHTML = '<figure></figure><div class="lightbox-bar"><span></span>' +
      '<button type="button" data-step="-1" aria-label="Previous">←</button>' +
      '<button type="button" data-step="1" aria-label="Next">→</button>' +
      '<button type="button" data-close>Close</button></div>';
    document.body.appendChild(box);
    var figure = box.querySelector('figure');
    var counter = box.querySelector('.lightbox-bar span');
    var current = 0;

    var show = function (index) {
      current = (index + tiles.length) % tiles.length;
      var tile = tiles[current];
      var media;
      if (tile.getAttribute('data-type') === 'video') {
        media = document.createElement('video');
        media.src = tile.getAttribute('href');
        media.controls = media.autoplay = media.loop = media.muted = media.playsInline = true;
      } else {
        media = document.createElement('img');
        media.src = tile.getAttribute('href');
        media.alt = tile.querySelector('img').alt;
      }
      figure.replaceChildren(media);
      counter.textContent = (current + 1) + ' / ' + tiles.length;
    };

    tiles.forEach(function (tile, index) {
      tile.addEventListener('click', function (event) {
        event.preventDefault();
        show(index);
        box.showModal();
      });
    });
    box.addEventListener('click', function (event) {
      var step = event.target.closest('[data-step]');
      if (step) show(current + Number(step.getAttribute('data-step')));
      // A click on the backdrop has the dialog itself as the target.
      else if (event.target === box || event.target.closest('[data-close]')) box.close();
    });
    box.addEventListener('keydown', function (event) {
      if (event.key === 'ArrowLeft') show(current - 1);
      if (event.key === 'ArrowRight') show(current + 1);
    });
    // Stop the video when the lightbox closes.
    box.addEventListener('close', function () { figure.replaceChildren(); });
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
