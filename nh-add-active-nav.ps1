# nh-add-active-nav.ps1
# Injects a small script (once, idempotently) into every "nh"-converted page
# that highlights the current page's nav link in orange, matching the design
# mockup's active-nav-state behavior. Inserted right before </body>.

$dir = "D:\.claude\handledhome"
$enc = [System.Text.Encoding]::UTF8

$script = @'
<script>
(function() {
  var path = location.pathname.replace(/index\.html$/, '').replace(/\/$/, '') || '/';
  document.querySelectorAll('.nav-links a, .nav-mobile-menu a').forEach(function(link) {
    var href = link.getAttribute('href');
    if (!href || href.charAt(0) === '#') return;
    var linkPath = href.split('#')[0].replace(/index\.html$/, '').replace(/\/$/, '') || '/';
    if (linkPath === path) link.classList.add('nav-active');
  });
})();
</script>
'@

$files = Get-ChildItem -Recurse -Filter *.html $dir | Where-Object { $_.FullName -notmatch '\\design\\' }
$updated = 0
$skipped = 0

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, $enc)

    if ($content -notmatch 'class="nh"') {
        $skipped++
        continue
    }
    if ($content -match 'nav-active') {
        Write-Host "SKIP (already has it): $($f.Name)"
        $skipped++
        continue
    }

    if ($content -match "`r`n") { $nl = "`r`n" } else { $nl = "`n" }
    $scriptT = if ($nl -eq "`n") { $script -replace "`r`n", "`n" } else { $script }

    $bodyCloseIdx = $content.LastIndexOf('</body>')
    if ($bodyCloseIdx -lt 0) {
        Write-Host "SKIP (no </body> found): $($f.Name)"
        $skipped++
        continue
    }

    $newContent = $content.Insert($bodyCloseIdx, $scriptT + $nl)
    [System.IO.File]::WriteAllText($f.FullName, $newContent, $enc)
    Write-Host "UPDATED: $($f.Name)"
    $updated++
}

Write-Host ""
Write-Host "Done. Updated: $updated  Skipped: $skipped"
