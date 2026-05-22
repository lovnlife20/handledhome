$dir = 'C:\Users\aprus\Claude\handledhome'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$skipFiles = @('header.html', 'footer.html', 'nav-update.ps1', 'nav-apple.ps1', 'nav-mobile.ps1')

$hamburger = '      <button class="nav-hamburger" id="nav-hamburger" aria-label="Open menu">
        <svg width="20" height="14" viewBox="0 0 20 14" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
          <rect width="20" height="2" rx="1"/>
          <rect y="6" width="20" height="2" rx="1"/>
          <rect y="12" width="20" height="2" rx="1"/>
        </svg>
      </button>'

$mobileMenu = '  <div class="nav-mobile-menu" id="nav-mobile-menu">
    <a href="index.html">Home</a>
    <a href="about-handled-home.html">About</a>
    <a href="deck-repair-moon-township-pa.html">Decks</a>
    <a href="drywall-repair-moon-township-pa.html">Drywall</a>
    <a href="door-trim-repair-moon-township-pa.html">Doors &amp; Trim</a>
    <a href="flooring-installation-moon-township-pa.html">Flooring</a>
    <a href="shed-building-moon-township-pa.html">Sheds</a>
    <a href="playset-installation-moon-township-pa.html">Playsets</a>
    <a href="frequently-asked-questions.html">FAQ</a>
    <a href="blog.html">Blog</a>
    <a href="index.html#contact" class="nav-mobile-cta">Get Estimate</a>
  </div>'

$navJS = '<script>
(function() {
  var btn = document.getElementById(''nav-hamburger'');
  var menu = document.getElementById(''nav-mobile-menu'');
  if (!btn || !menu) return;
  btn.addEventListener(''click'', function() {
    var open = menu.classList.toggle(''open'');
    document.body.style.overflow = open ? ''hidden'' : '''';
  });
  menu.querySelectorAll(''a'').forEach(function(link) {
    link.addEventListener(''click'', function() {
      menu.classList.remove(''open'');
      document.body.style.overflow = '''';
    });
  });
})();
</script>'

Get-ChildItem -Path $dir -Filter '*.html' | Where-Object { $_.Name -notin $skipFiles } | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $content = $content.Replace("`r`n", "`n")
    $original = $content

    # 1. Add hamburger button inside nav-actions before closing </div>
    $content = [regex]::Replace($content,
        '(<a href="index\.html#contact" class="nav-cta">Get Estimate</a>)\n    </div>',
        '$1' + "`n" + $hamburger + "`n    </div>")

    # 2. Add mobile menu inside <nav> after nav-inner closing </div>
    $content = [regex]::Replace($content,
        '  </div>\n</nav>',
        "  </div>`n" + $mobileMenu + "`n</nav>")

    # 3. Add JS before </body>
    $content = [regex]::Replace($content,
        '\n</body>',
        "`n" + $navJS + "`n</body>")

    # 4. Bump CSS version
    $content = $content -replace 'style\.css\?v=\d+', 'style.css?v=21'

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
        Write-Host "Updated: $($_.Name)"
    } else {
        Write-Host "No change: $($_.Name)"
    }
}
Write-Host "Done."
