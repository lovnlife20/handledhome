$dir = 'D:\.claude\handledhome'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$skipFiles = @('header.html', 'footer.html')

$newDesktopNav = '<nav class="desktop-nav">
        <a href="index.html">Home</a>
        <a href="about-handled-home.html">About</a>
        <div class="nav-dropdown">
          <a href="#" class="nav-dropdown-toggle">Services &#9660;</a>
          <div class="nav-dropdown-menu">
            <a href="deck-repair-moon-township-pa.html">Decks</a>
            <a href="drywall-repair-moon-township-pa.html">Drywall</a>
            <a href="door-trim-repair-moon-township-pa.html">Doors &amp; Trim</a>
            <a href="flooring-installation-moon-township-pa.html">Flooring</a>
            <a href="shed-building-moon-township-pa.html">Sheds</a>
            <a href="playset-installation-moon-township-pa.html">Playsets</a>
            <a href="frequently-asked-questions.html">FAQ</a>
          </div>
        </div>
        <a href="home-repair-tips.html">Home Repair Tips</a>
        <div class="nav-dropdown">
          <a href="#" class="nav-dropdown-toggle">Areas &#9660;</a>
          <div class="nav-dropdown-menu">
            <a href="handyman-coraopolis-pa.html">Coraopolis</a>
            <a href="handyman-sewickley-pa.html">Sewickley</a>
            <a href="handyman-robinson-pa.html">Robinson</a>
            <a href="handyman-aliquippa-pa.html">Aliquippa</a>
            <a href="handyman-ambridge-pa.html">Ambridge</a>
            <a href="handyman-cranberry-township-pa.html">Cranberry</a>
            <a href="handyman-wexford-pa.html">Wexford</a>
            <a href="handyman-beaver-pa.html">Beaver</a>
            <a href="handyman-monaca-pa.html">Monaca</a>
          </div>
        </div>
        <a href="index.html#contact" class="nav-cta">Get Estimate</a>
      </nav>'

$newMobileOverlay = '<div class="mobile-overlay" id="mobile-overlay">
      <button class="mobile-overlay-close" id="mobile-overlay-close" aria-label="Close menu">&#10005;</button>
      <nav class="mobile-overlay-nav">
        <a href="index.html">Home</a>
        <a href="about-handled-home.html">About</a>
        <a href="deck-repair-moon-township-pa.html">Decks</a>
        <a href="drywall-repair-moon-township-pa.html">Drywall</a>
        <a href="door-trim-repair-moon-township-pa.html">Doors &amp; Trim</a>
        <a href="flooring-installation-moon-township-pa.html">Flooring</a>
        <a href="shed-building-moon-township-pa.html">Sheds</a>
        <a href="playset-installation-moon-township-pa.html">Playsets</a>
        <a href="frequently-asked-questions.html">FAQ</a>
        <a href="home-repair-tips.html">Home Repair Tips</a>
        <a href="index.html#contact" class="mobile-overlay-cta">Get Estimate</a>
      </nav>
    </div>'

$newJS = '<script>
document.getElementById(''hamburger-btn'').addEventListener(''click'', function () {
  document.getElementById(''mobile-overlay'').classList.add(''open'');
  document.body.style.overflow = ''hidden'';
});
document.getElementById(''mobile-overlay-close'').addEventListener(''click'', function () {
  document.getElementById(''mobile-overlay'').classList.remove(''open'');
  document.body.style.overflow = '''';
});
document.querySelectorAll(''.mobile-overlay-nav a'').forEach(function (link) {
  link.addEventListener(''click'', function () {
    document.getElementById(''mobile-overlay'').classList.remove(''open'');
    document.body.style.overflow = '''';
  });
});
</script>'

Get-ChildItem -Path $dir -Filter '*.html' | Where-Object { $_.Name -notin $skipFiles } | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $original = $content

    # 1. Remove email from topbar (keep phone only)
    $content = [regex]::Replace($content,
        '(<a href="tel:14123535341">412-353-5341</a>)\s*\|\s*<a href="mailto:info@handledhome\.net">info@handledhome\.net</a>',
        '$1')

    # 2. Replace desktop nav
    $content = [regex]::Replace($content, '(?s)<nav class="desktop-nav">.*?</nav>', $newDesktopNav)

    # 3. Replace mobile drawer with overlay div
    $content = [regex]::Replace($content, '(?s)<nav class="mobile-drawer"[^>]*>.*?</nav>', $newMobileOverlay)

    # 4. Replace JS block
    $content = [regex]::Replace($content,
        "(?s)<script>\s*document\.getElementById\('hamburger-btn'\).*?</script>",
        $newJS)

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
        Write-Host "Updated: $($_.Name)"
    } else {
        Write-Host "No change: $($_.Name)"
    }
}
Write-Host "Done."
