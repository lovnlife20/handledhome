# nh-simplify-footer.ps1
#
# Restructures the shared footer on every "nh"-converted page:
#   1. Moves each page's own final .cta band (whatever it contains --
#      unique H2, optional subtitle paragraph, button -- captured
#      verbatim) to become the first element inside <footer>, so it
#      reads as one merged navy block instead of two stacked sections.
#   2. Drops the email line from the footer's Contact address (keeps
#      phone + location only).
#   3. Removes the "Get a Free Estimate" link from the footer's Site nav
#      (the merged CTA band above is now the one clear CTA).
#   4. Removes the wrapped row of 13 town links entirely (footer-towns);
#      renames the Site nav's "Areas" link to "Service Areas" as the one
#      remaining path to the areas hub.
#
# Line-ending safe: normalizes to LF internally regardless of the
# source file's actual line endings (some are LF, some CRLF depending
# on edit history / git autocrlf), then restores the original style
# before writing.
#
# Idempotent: re-running on an already-simplified page is a no-op (SKIP).

$dir = "D:\.claude\handledhome"
$enc = [System.Text.Encoding]::UTF8
$opts = [System.Text.RegularExpressions.RegexOptions]::Singleline

$ctaPattern = '<div class="cta">([\s\S]*?)</div>\s*(</main>|</div>)\s*<footer class="footer">'

$oldFooterBlock = @'
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
        <a href="/service-areas.html">Areas</a>
        <a href="/home-repair-tips.html">Home Repair Tips</a>
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
'@ -replace "`r`n", "`n"

$newFooterOpen = @'
<footer class="footer">
  {{CTA_BAND}}
  <div class="footer-inner nh-footer-inner">
    <div class="nh-footer-col nh-footer-brand">
      <img src="/handled-home-logo.svg" alt="Handled Home" class="footer-logo">
      <p>Locally owned handyman services based in Moon Township, serving the Pittsburgh area.</p>
    </div>
    <div class="nh-footer-col">
      <div class="nh-footer-heading">Contact</div>
      <address>
        <div><a href="tel:14123535341">412-353-5341</a></div>
        <div>Moon Township, PA</div>
      </address>
    </div>
    <div class="nh-footer-col">
      <div class="nh-footer-heading">Site</div>
      <nav>
        <a href="/">Home</a>
        <a href="/all-services.html">Services</a>
        <a href="/service-areas.html">Service Areas</a>
        <a href="/home-repair-tips.html">Home Repair Tips</a>
        <a href="/about-handled-home.html">About</a>
        <a href="/contact/">Contact</a>
        <a href="/our-work.html">Our Work</a>
        <a href="/frequently-asked-questions.html">FAQ</a>
      </nav>
    </div>
    <div class="nh-footer-fine">
'@ -replace "`r`n", "`n"

$fallbackCtaInner = (@'

    <h2>Ready to Get Something Handled?</h2>
    <div class="buttons">
      <a href="tel:14123535341" class="call">Call or text 412-353-5341</a>
    </div>

'@ -replace "`r`n", "`n")

$files = Get-ChildItem -Recurse -Filter *.html $dir | Where-Object { $_.FullName -notmatch '\\design\\' }
$updated = 0
$skipped = 0

foreach ($f in $files) {
    $raw = [System.IO.File]::ReadAllText($f.FullName, $enc)
    $wasCrlf = $raw -match "`r`n"
    $content = $raw -replace "`r`n", "`n"   # normalize to LF for all processing
    $original = $content

    if ($content -notmatch 'class="nh"') { $skipped++; continue }
    if ($content -match 'footer-cta-merged') { Write-Host "SKIP (already simplified): $($f.Name)"; $skipped++; continue }
    if ($content -notmatch [regex]::Escape('<div class="nh-footer-towns-wrap">')) { Write-Host "SKIP (old footer pattern not found): $($f.Name)"; $skipped++; continue }

    # Step 1: capture + remove the page's own final .cta band (whatever it contains --
    # h2, optional subtitle paragraph, buttons -- captured verbatim, not assumed)
    $ctaMatch = [regex]::Match($content, $ctaPattern, $opts)
    $ctaInner = $fallbackCtaInner
    $logLabel = "(no .cta band found -- generic heading used)"
    if ($ctaMatch.Success) {
        $ctaInner = $ctaMatch.Groups[1].Value
        $closeTag = $ctaMatch.Groups[2].Value
        $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $closeTag + "`n<footer class=`"footer`">" }
        $content = [regex]::Replace($content, $ctaPattern, $evaluator, $opts)
        $h2Match = [regex]::Match($ctaInner, '<h2>(.*?)</h2>')
        $logLabel = if ($h2Match.Success) { $h2Match.Groups[1].Value } else { "(no h2 found in captured band)" }
    } else {
        Write-Host "NOTE: $($f.Name) $logLabel"
    }

    $ctaBand = '<div class="cta footer-cta-merged">' + $ctaInner + '</div>' + "`n"
    $newFooterOpenFilled = $newFooterOpen.Replace('{{CTA_BAND}}', $ctaBand.TrimEnd() + "`n")

    if (-not $content.Contains($oldFooterBlock)) {
        Write-Host "WARNING (old footer block not found as literal substring, skipping footer restructure): $($f.Name)"
        $skipped++
        continue
    }
    $content = $content.Replace($oldFooterBlock, $newFooterOpenFilled)

    if ($content -ne $original) {
        if ($wasCrlf) { $content = $content -replace "`n", "`r`n" }
        [System.IO.File]::WriteAllText($f.FullName, $content, $enc)
        Write-Host "UPDATED: $($f.Name)  [cta: $logLabel]"
        $updated++
    } else {
        Write-Host "UNCHANGED (no match): $($f.Name)"
        $skipped++
    }
}

Write-Host ""
Write-Host "Done. Updated: $updated  Skipped: $skipped"
