$dir = "D:\.claude\handledhome"
$enc = [System.Text.Encoding]::UTF8

$rootFiles    = Get-ChildItem "$dir\*.html"
$contactFiles = Get-ChildItem "$dir\contact\*.html" -ErrorAction SilentlyContinue
$allFiles     = @($rootFiles) + @($contactFiles)

$pattern = '<span class="nav-mobile-category">Services</span>[\s\S]*?<a href="all-services\.html">See All Services[^<]*</a>'

$newMobile = '<details class="nav-mobile-services">' + "`r`n" +
'      <summary>Services <svg width="10" height="6" viewBox="0 0 10 6" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 1l4 4 4-4"/></svg></summary>' + "`r`n" +
'      <a href="deck-repair-moon-township-pa.html">Deck Repair &amp; Building</a>' + "`r`n" +
'      <a href="drywall-repair-moon-township-pa.html">Drywall Repair</a>' + "`r`n" +
'      <a href="flooring-installation-moon-township-pa.html">Flooring</a>' + "`r`n" +
'      <a href="door-replacement-moon-township-pa.html">Door Replacement</a>' + "`r`n" +
'      <a href="tv-mounting-moon-township-pa.html">TV Mounting</a>' + "`r`n" +
'      <a href="ceiling-fan-installation-moon-township-pa.html">Ceiling Fan Installation</a>' + "`r`n" +
'      <a href="leaking-faucet-repair-pittsburgh-pa.html">Leaking Faucet Repair</a>' + "`r`n" +
'      <a href="handyman-for-seniors-moon-township-pa.html">Handyman for Seniors</a>' + "`r`n" +
'      <a href="all-services.html">See All Services &#8594;</a>' + "`r`n" +
'    </details>'

$opts    = [System.Text.RegularExpressions.RegexOptions]::Singleline
$updated = 0
$skipped = 0

foreach ($file in $allFiles) {
    $content  = [System.IO.File]::ReadAllText($file.FullName, $enc)
    $original = $content

    if (-not [regex]::IsMatch($content, $pattern, $opts)) {
        Write-Host "SKIP: $($file.Name)"
        $skipped++
        continue
    }

    # Adjust line endings to match the file
    if ($content -notmatch "`r`n") {
        $replacement = $newMobile -replace "`r`n", "`n"
    } else {
        $replacement = $newMobile
    }

    $newContent = [regex]::Replace($content, $pattern, $replacement, $opts)

    if ($newContent -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $enc)
        Write-Host "UPDATED: $($file.Name)"
        $updated++
    } else {
        Write-Host "UNCHANGED: $($file.Name)"
        $skipped++
    }
}

Write-Host ""
Write-Host "Done. Updated: $updated  Skipped: $skipped"
