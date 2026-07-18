$dir = 'D:\.claude\handledhome'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$skipFiles = @('header.html', 'footer.html', 'nav-update.ps1', 'nav-apple.ps1')

$newNav = '<nav class="nav">
  <div class="nav-inner">
    <a href="index.html" class="nav-logo">
      <img src="handled-home-logo-cropped.svg" alt="Handled Home">
    </a>
    <div class="nav-links">
      <a href="index.html">Home</a>
      <a href="about-handled-home.html">About</a>
      <span class="nav-trigger">
        Services
        <svg width="10" height="6" viewBox="0 0 10 6" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 1l4 4 4-4"/></svg>
        <div class="dropdown">
          <a href="deck-repair-moon-township-pa.html">Deck Repair &amp; Building</a>
          <a href="drywall-repair-moon-township-pa.html">Drywall Repair</a>
          <a href="door-trim-repair-moon-township-pa.html">Doors &amp; Trim</a>
          <a href="flooring-installation-moon-township-pa.html">Flooring</a>
          <a href="shed-building-moon-township-pa.html">Shed Building</a>
          <a href="playset-installation-moon-township-pa.html">Playset Installation</a>
        </div>
      </span>
      <span class="nav-trigger">
        Areas
        <svg width="10" height="6" viewBox="0 0 10 6" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 1l4 4 4-4"/></svg>
        <div class="dropdown">
          <a href="handyman-coraopolis-pa.html">Coraopolis</a>
          <a href="handyman-sewickley-pa.html">Sewickley</a>
          <a href="handyman-robinson-pa.html">Robinson</a>
          <a href="handyman-aliquippa-pa.html">Aliquippa</a>
          <a href="handyman-cranberry-township-pa.html">Cranberry Township</a>
          <a href="handyman-wexford-pa.html">Wexford</a>
          <a href="handyman-beaver-pa.html">Beaver</a>
          <a href="handyman-monaca-pa.html">Monaca</a>
        </div>
      </span>
      <a href="home-repair-tips.html">Blog</a>
      <a href="frequently-asked-questions.html">FAQ</a>
    </div>
    <div class="nav-actions">
      <a href="tel:14123535341" class="nav-phone">412-353-5341</a>
      <a href="index.html#contact" class="nav-cta">Get Estimate</a>
    </div>
  </div>
</nav>'

Get-ChildItem -Path $dir -Filter '*.html' | Where-Object { $_.Name -notin $skipFiles } | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    # Normalize CRLF to LF so regex patterns work uniformly
    $content = $content.Replace("`r`n", "`n")
    $original = $content

    # Replace entire site-header block with new nav
    $content = [regex]::Replace($content, '(?s)<div id="site-header">.*?</div>\n</div>\n</div>', $newNav)

    # Remove any leftover stray </div> after </nav> before page-wrap
    $content = [regex]::Replace($content, '</nav>\n</div>\n\n<div class="page-wrap">', "</nav>`n`n<div class=""page-wrap"">")

    # Remove the mobile overlay JS block
    $content = [regex]::Replace($content,
        "(?s)<script>\s*document\.getElementById\('hamburger-btn'\).*?</script>\s*",
        '')

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
        Write-Host "Updated: $($_.Name)"
    } else {
        Write-Host "No change: $($_.Name)"
    }
}
Write-Host "Done."
