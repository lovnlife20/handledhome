// Handled Home — GA4 phone call click tracking
// Fires a 'phone_call_click' event whenever any tel: link is clicked,
// including the floating Call Now button, nav phone link, and hero number.
(function () {
  document.addEventListener('click', function (e) {
    var link = e.target.closest('a[href^="tel:"]');
    if (!link) return;
    if (typeof gtag !== 'function') return;
    gtag('event', 'phone_call_click', {
      event_category: 'Contact',
      event_label: link.getAttribute('href').replace('tel:', '').replace('+1', ''),
      value: 1
    });
  });
})();
