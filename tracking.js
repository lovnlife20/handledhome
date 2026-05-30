// Handled Home — GA4 click tracking
(function () {
  document.addEventListener('click', function (e) {
    if (typeof gtag !== 'function') return;

    // Phone call clicks
    var telLink = e.target.closest('a[href^="tel:"]');
    if (telLink) {
      gtag('event', 'phone_call_click', {
        event_category: 'Contact',
        event_label: telLink.getAttribute('href').replace('tel:', '').replace('+1', ''),
        value: 1
      });
      return;
    }

    // SMS / text clicks
    var smsLink = e.target.closest('a[href^="sms:"]');
    if (smsLink) {
      gtag('event', 'sms_click', {
        event_category: 'Contact',
        event_label: smsLink.getAttribute('href').replace('sms:', '').split('?')[0].replace('+1', ''),
        value: 1
      });
      return;
    }

    // Our Work page link clicks
    var ourWorkLink = e.target.closest('a[href="our-work.html"], a[href="/our-work.html"]');
    if (ourWorkLink) {
      gtag('event', 'our_work_click', {
        event_category: 'Navigation',
        event_label: document.title
      });
    }
  });
})();
