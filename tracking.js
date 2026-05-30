// Handled Home — GA4 contact click tracking
// Fires 'phone_call_click' for any tel: link and 'sms_click' for any sms: link.
(function () {
  document.addEventListener('click', function (e) {
    var link = e.target.closest('a[href^="tel:"], a[href^="sms:"]');
    if (!link) return;
    if (typeof gtag !== 'function') return;
    var href = link.getAttribute('href');
    if (href.indexOf('tel:') === 0) {
      gtag('event', 'phone_call_click', {
        event_category: 'Contact',
        event_label: href.replace('tel:', '').replace('+1', ''),
        value: 1
      });
    } else if (href.indexOf('sms:') === 0) {
      gtag('event', 'sms_click', {
        event_category: 'Contact',
        event_label: href.replace('sms:', '').split('?')[0].replace('+1', ''),
        value: 1
      });
    }
  });
})();
