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

  // Replace the form with a confirmation right where it sat, so people stay
  // on the page they were reading instead of being sent to thank-you.html.
  function showConfirmation(form) {
    var card = form.closest('.nh-modal-card');
    if (card) {
      var heading = card.querySelector('h3');
      if (heading) heading.style.display = 'none';
    }

    var box = document.createElement('div');
    box.className = 'nh-form-success';
    box.setAttribute('role', 'status');
    box.setAttribute('tabindex', '-1');
    box.innerHTML =
      '<h3>Thanks &#8212; your request is in.</h3>' +
      '<p>We\'ll email you back within 1 business day with any questions ' +
      'and next steps.</p>' +
      '<p>Need it handled sooner? Call or text ' +
      '<a href="tel:14123535341">412-353-5341</a>.</p>';

    form.parentNode.replaceChild(box, form);
    box.focus();
    box.scrollIntoView({ block: 'center', behavior: 'smooth' });
  }

  document.addEventListener('submit', function (e) {
    var form = e.target.closest('form');
    if (!form || !/web3forms\.com/.test(form.action)) return;

    if (typeof gtag === 'function') {
      gtag('event', 'form_submit', { event_category: 'Contact', event_label: document.title, value: 1 });
    }

    // No fetch/FormData support: let the browser submit and land on thank-you.html.
    if (!window.fetch || !window.FormData) return;

    e.preventDefault();

    var button = form.querySelector('button[type="submit"], button');
    var label = button ? button.innerHTML : '';
    if (button) {
      button.disabled = true;
      button.innerHTML = 'Sending&hellip;';
    }

    fetch(form.action, {
      method: 'POST',
      headers: { 'Accept': 'application/json' },
      body: new FormData(form)
    }).then(function (res) {
      if (!res.ok) throw new Error(res.status);
      showConfirmation(form);
    }).catch(function () {
      // Background send failed — fall back to a normal submit, which honors
      // the hidden redirect field. form.submit() does not re-fire this handler.
      if (button) {
        button.disabled = false;
        button.innerHTML = label;
      }
      form.submit();
    });
  });
})();
