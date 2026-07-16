# nh-convert-batch.ps1
#
# Mechanically converts a batch of pages to the "nh" (navy/orange) redesign:
#   - adds class="nh" to <body>
#   - swaps the old mega-menu <nav class="nav">...</nav> for the new flat nav
#   - swaps the old <footer class="footer">...</footer> for the new 3-column footer
#   - inserts the Archivo font <link> tags before the stylesheet link
#   - bumps style.css?v=NN to v=53
#   - injects the Quote Modal markup + script before </body>, reusing the page's
#     OWN existing hidden "subject" value so lead-source tracking is preserved
#
# Content sections (hero copy, service grids, FAQs, photo galleries, etc.) are
# NOT touched by this script -- they get their new look "for free" from the
# body.nh-scoped CSS in style.css the moment class="nh" is added.
#
# Usage:
#   .\nh-convert-batch.ps1 -Files "all-services.html","deck-repair-moon-township-pa.html"
#   .\nh-convert-batch.ps1 -Files "contact\index.html"
#   .\nh-convert-batch.ps1 -Files @(...) -DryRun    # report only, no writes

param(
    [Parameter(Mandatory = $true)]
    [string[]]$Files,

    [switch]$DryRun
)

$dir = "D:\.claude\handledhome"
$enc = [System.Text.Encoding]::UTF8
$opts = [System.Text.RegularExpressions.RegexOptions]::Singleline

# ── New templates (absolute paths -- work at any directory depth) ────────────

$newNav = @'
<nav class="nav">
  <div class="nav-inner">
    <a href="/" class="nav-logo">
      <img src="/handled-home-logo.svg" alt="Handled Home">
    </a>
    <div class="nav-links">
      <a href="/">Home</a>
      <a href="/all-services.html">Services</a>
      <a href="/blog.html">Blog</a>
      <a href="/about-handled-home.html">About</a>
      <a href="/contact/">Contact</a>
    </div>
    <div class="nav-actions">
      <a href="tel:14123535341" class="nav-phone">412-353-5341</a>
      <a href="/#contact" class="nav-cta" data-modal-trigger>Get a Free Estimate</a>
      <button class="nav-hamburger" id="nav-hamburger" aria-label="Open menu">
        <svg width="20" height="14" viewBox="0 0 20 14" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
          <rect width="20" height="2" rx="1"/>
          <rect y="6" width="20" height="2" rx="1"/>
          <rect y="12" width="20" height="2" rx="1"/>
        </svg>
      </button>
    </div>
  </div>
  <div class="nav-mobile-menu" id="nav-mobile-menu">
    <a href="/">Home</a>
    <a href="/all-services.html">Services</a>
    <a href="/blog.html">Blog</a>
    <a href="/about-handled-home.html">About</a>
    <a href="/contact/">Contact</a>
    <a href="tel:14123535341">412-353-5341</a>
    <a href="/#contact" class="nav-mobile-cta" data-modal-trigger>Get a Free Estimate</a>
  </div>
</nav>
'@

$newFooter = @'
<footer class="footer">
  <div class="footer-inner nh-footer-inner">
    <div class="nh-footer-col nh-footer-brand">
      <img src="/handled-home-logo.svg" alt="Handled Home" class="footer-logo">
      <p>Locally owned handyman services based in Moon Township, serving the Pittsburgh area.</p>
    </div>
    <div class="nh-footer-col">
      <div class="nh-footer-heading">Contact</div>
      <address>
        <div><a href="tel:14123535341">412-353-5341</a></div>
        <div><a href="mailto:info@handledhome.net">info@handledhome.net</a></div>
        <div>Moon Township, PA</div>
      </address>
    </div>
    <div class="nh-footer-col">
      <div class="nh-footer-heading">Site</div>
      <nav>
        <a href="/">Home</a>
        <a href="/all-services.html">Services</a>
        <a href="/blog.html">Home Repair Tips</a>
        <a href="/about-handled-home.html">About</a>
        <a href="/contact/">Contact</a>
        <a href="/our-work.html">Our Work</a>
        <a href="/frequently-asked-questions.html">FAQ</a>
        <a href="/#contact" class="footer-cta" data-modal-trigger>Get a Free Estimate</a>
      </nav>
    </div>
    <div class="nh-footer-towns-wrap">
      <div class="footer-towns">
        <a href="/handyman-moon-township-pa.html">Moon Township</a>
        <a href="/handyman-coraopolis-pa.html">Coraopolis</a>
        <a href="/handyman-oakdale-pa.html">Oakdale</a>
        <a href="/handyman-sewickley-pa.html">Sewickley</a>
        <a href="/handyman-robinson-pa.html">Robinson</a>
        <a href="/handyman-aliquippa-pa.html">Aliquippa</a>
        <a href="/handyman-ambridge-pa.html">Ambridge</a>
        <a href="/handyman-cranberry-township-pa.html">Cranberry</a>
        <a href="/handyman-wexford-pa.html">Wexford</a>
        <a href="/handyman-beaver-pa.html">Beaver</a>
        <a href="/handyman-monaca-pa.html">Monaca</a>
        <a href="/handyman-mt-lebanon-pa.html">Mt. Lebanon</a>
        <a href="/handyman-north-fayette-township-pa.html">North Fayette</a>
      </div>
    </div>
    <div class="nh-footer-fine">
      Fully insured handyman services for repairs, installations, and home projects.<br>
      Services include home repairs, door installation, fixture replacement, shutter replacement, railing repair, and general handyman services in Moon Township and the Pittsburgh area.<br>
      PA Contractor Registration: PA217831
    </div>
    <div class="nh-footer-copyright">&copy; 2026 Handled Home. Licensed &amp; insured.</div>
  </div>
</footer>
'@

$fontLinks = @'
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600;700;800&display=swap" rel="stylesheet">
'@

# {{SUBJECT}} gets swapped per-file for that page's own existing subject value
$modalMarkup = @'
<div class="nh-modal-overlay" id="nh-modal">
  <div class="nh-modal-card">
    <button class="nh-modal-close" id="nh-modal-close" aria-label="Close">&times;</button>
    <h3>Request a Free Estimate</h3>
    <form action="https://api.web3forms.com/submit" method="POST">
      <input type="hidden" name="access_key" value="1bc639e8-2922-410a-841d-aa1ca1fb2a68">
      <input type="hidden" name="subject" value="{{SUBJECT}}">
      <input type="hidden" name="redirect" value="https://handledhome.net/thank-you.html">
      <input type="text" name="name" placeholder="Name" required>
      <input type="tel" name="phone" placeholder="Phone" required>
      <input type="email" name="email" placeholder="Email">
      <input type="text" name="address" placeholder="Address">
      <textarea name="message" rows="4" placeholder="What needs handling?"></textarea>
      <button type="submit">Submit Request</button>
    </form>
  </div>
</div>
'@

$modalScript = @'
<script>
(function() {
  var modal = document.getElementById('nh-modal');
  if (!modal) return;
  var closeBtn = document.getElementById('nh-modal-close');
  function openModal(e) {
    e.preventDefault();
    modal.classList.add('open');
  }
  function closeModal() {
    modal.classList.remove('open');
  }
  document.querySelectorAll('[data-modal-trigger]').forEach(function(el) {
    el.addEventListener('click', openModal);
  });
  closeBtn.addEventListener('click', closeModal);
  modal.addEventListener('click', function(e) {
    if (e.target === modal) closeModal();
  });
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModal();
  });
})();
</script>
'@

# ── Patterns for locating old markup ──────────────────────────────────────────
$navPattern     = '<nav class="nav">[\s\S]*?</nav>'
$footerPattern  = '<footer class="footer">[\s\S]*?</footer>'
$bodyPattern    = '<body(\s[^>]*)?>'
$subjectPattern = '<input\s+type="hidden"\s+name="subject"\s+value="([^"]*)"'

$updated = 0
$skipped = 0

foreach ($rel in $Files) {
    $path = Join-Path $dir $rel

    if (-not (Test-Path $path)) {
        Write-Host "SKIP (not found): $rel"
        $skipped++
        continue
    }

    $content = [System.IO.File]::ReadAllText($path, $enc)
    $original = $content

    if ($content -match 'class="nh"') {
        Write-Host "SKIP (already converted): $rel"
        $skipped++
        continue
    }
    if (-not [regex]::IsMatch($content, $navPattern, $opts)) {
        Write-Host "SKIP (no recognizable old nav -- needs manual conversion): $rel"
        $skipped++
        continue
    }
    if (-not [regex]::IsMatch($content, $footerPattern, $opts)) {
        Write-Host "SKIP (no recognizable old footer -- needs manual conversion): $rel"
        $skipped++
        continue
    }

    if ($content -match "`r`n") { $nl = "`r`n" } else { $nl = "`n" }

    $navT    = $newNav
    $footerT = $newFooter
    $fontT   = $fontLinks
    $modalT  = $modalMarkup
    $scriptT = $modalScript
    if ($nl -eq "`n") {
        $navT    = $navT    -replace "`r`n", "`n"
        $footerT = $footerT -replace "`r`n", "`n"
        $fontT   = $fontT   -replace "`r`n", "`n"
        $modalT  = $modalT  -replace "`r`n", "`n"
        $scriptT = $scriptT -replace "`r`n", "`n"
    }

    # Capture this page's own subject value before anything else changes
    $subjectMatch = [regex]::Match($content, $subjectPattern)
    $subject = if ($subjectMatch.Success) { $subjectMatch.Groups[1].Value } else { "New Estimate Request - Handled Home" }
    $modalT = $modalT.Replace('{{SUBJECT}}', $subject)

    # body class
    $content = [regex]::Replace($content, $bodyPattern, '<body class="nh">', $opts)

    # nav / footer swap
    $content = [regex]::Replace($content, $navPattern, $navT, $opts)
    $content = [regex]::Replace($content, $footerPattern, $footerT, $opts)

    # css version bump (preserves whatever path prefix each file already uses)
    $content = [regex]::Replace($content, 'style\.css\?v=\d+', 'style.css?v=53')

    # insert Archivo font links immediately before the stylesheet <link>
    $marker = '<link rel="stylesheet" href='
    $idx = $content.IndexOf($marker)
    if ($idx -ge 0) {
        $content = $content.Insert($idx, $fontT + $nl)
    }

    # inject quote modal + script before </body>, once
    if ($content -notmatch 'id="nh-modal"') {
        $bodyCloseIdx = $content.LastIndexOf('</body>')
        if ($bodyCloseIdx -ge 0) {
            $content = $content.Insert($bodyCloseIdx, $modalT + $nl + $scriptT + $nl)
        }
    }

    if ($content -ne $original) {
        if (-not $DryRun) {
            [System.IO.File]::WriteAllText($path, $content, $enc)
        }
        Write-Host "UPDATED$(if ($DryRun) { ' (dry-run)' }): $rel  [subject: $subject]"
        $updated++
    } else {
        Write-Host "UNCHANGED: $rel"
        $skipped++
    }
}

Write-Host ""
Write-Host "Done. Updated: $updated  Skipped/Unchanged: $skipped"
