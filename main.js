// ── HAMBURGER ──────────────────────────────────────────────────────────────
(function () {
  var btn = document.getElementById('hamburgerBtn');
  var menu = document.getElementById('mobileMenu');
  if (!btn || !menu) return;

  btn.addEventListener('click', function (e) {
    e.stopPropagation();
    var open = menu.classList.toggle('open');
    btn.classList.toggle('open', open);
  });

  menu.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', function () {
      menu.classList.remove('open');
      btn.classList.remove('open');
    });
  });

  document.addEventListener('click', function (e) {
    if (!menu.contains(e.target) && !btn.contains(e.target)) {
      menu.classList.remove('open');
      btn.classList.remove('open');
    }
  });
})();

// ── SCROLL FADE ────────────────────────────────────────────────────────────
(function () {
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });
  document.querySelectorAll('.fade-up').forEach(function (el) { io.observe(el); });
})();

// ── FAQ ────────────────────────────────────────────────────────────────────
function toggleFaq(btn) {
  var item = btn.parentElement;
  var wrap = item.closest('.faq-list');
  var isOpen = item.classList.contains('open');
  if (wrap) wrap.querySelectorAll('.faq-item').forEach(function (i) { i.classList.remove('open'); });
  if (!isOpen) item.classList.add('open');
}
