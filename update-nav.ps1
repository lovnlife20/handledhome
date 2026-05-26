$dir = "C:\Users\aprus\Claude\handledhome"
$enc = [System.Text.Encoding]::UTF8

# Collect all HTML files, skip all-services.html (already has new nav)
$rootFiles = Get-ChildItem "$dir\*.html" | Where-Object { $_.Name -ne "all-services.html" }
$contactFiles = Get-ChildItem "$dir\contact\*.html" -ErrorAction SilentlyContinue
$allFiles = @($rootFiles) + @($contactFiles)

# ── New desktop dropdown replacement ──────────────────────────────────────────
$desktopNew = '<div class="dropdown">' + "`r`n" +
'          <a href="deck-repair-moon-township-pa.html">Deck Repair &amp; Building</a>' + "`r`n" +
'          <a href="drywall-repair-moon-township-pa.html">Drywall Repair</a>' + "`r`n" +
'          <a href="flooring-installation-moon-township-pa.html">Flooring</a>' + "`r`n" +
'          <a href="door-replacement-moon-township-pa.html">Door Replacement</a>' + "`r`n" +
'          <a href="tv-mounting-moon-township-pa.html">TV Mounting</a>' + "`r`n" +
'          <a href="ceiling-fan-installation-moon-township-pa.html">Ceiling Fan Installation</a>' + "`r`n" +
'          <a href="leaking-faucet-repair-pittsburgh-pa.html">Leaking Faucet Repair</a>' + "`r`n" +
'          <a href="handyman-for-seniors-moon-township-pa.html">Handyman for Seniors</a>' + "`r`n" +
'          <div class="dropdown-divider"></div>' + "`r`n" +
'          <a href="all-services.html" style="font-weight:600;">See All Services &#8594;</a>' + "`r`n" +
'        </div>'

# ── New mobile services section replacement ───────────────────────────────────
$mobileNew = '<span class="nav-mobile-category">Services</span>' + "`r`n" +
'    <a href="deck-repair-moon-township-pa.html">Deck Repair &amp; Building</a>' + "`r`n" +
'    <a href="drywall-repair-moon-township-pa.html">Drywall Repair</a>' + "`r`n" +
'    <a href="flooring-installation-moon-township-pa.html">Flooring</a>' + "`r`n" +
'    <a href="door-replacement-moon-township-pa.html">Door Replacement</a>' + "`r`n" +
'    <a href="tv-mounting-moon-township-pa.html">TV Mounting</a>' + "`r`n" +
'    <a href="ceiling-fan-installation-moon-township-pa.html">Ceiling Fan Installation</a>' + "`r`n" +
'    <a href="leaking-faucet-repair-pittsburgh-pa.html">Leaking Faucet Repair</a>' + "`r`n" +
'    <a href="handyman-for-seniors-moon-township-pa.html">Handyman for Seniors</a>' + "`r`n" +
'    <a href="all-services.html">See All Services &#8594;</a>'

# ── Regex patterns ────────────────────────────────────────────────────────────
$desktopPattern = '<div class="dropdown">\s*<div class="dropdown-category">Repairs[^<]*</div>[\s\S]*?handyman-for-seniors-moon-township-pa\.html">[^<]*</a>\s*</div>'
$mobilePattern  = '<span class="nav-mobile-category">Repairs[^<]*</span>[\s\S]*?handyman-for-seniors-moon-township-pa\.html">[^<]*</a>'

$opts = [System.Text.RegularExpressions.RegexOptions]::Singleline

$updated = 0
$skipped = 0

foreach ($file in $allFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $enc)

    # Check if this file has the old nav
    if (-not [regex]::IsMatch($content, $desktopPattern, $opts)) {
        Write-Host "SKIP (no old nav): $($file.Name)"
        $skipped++
        continue
    }

    # Determine line ending style for this file
    if ($content -match "`r`n") {
        $nl = "`r`n"
    } else {
        $nl = "`n"
        # Rebuild replacement strings with LF line endings
        $desktopNew2 = $desktopNew -replace "`r`n", "`n"
        $mobileNew2  = $mobileNew  -replace "`r`n", "`n"
    }

    if ($nl -eq "`r`n") {
        $newContent = [regex]::Replace($content, $desktopPattern, $desktopNew,  $opts)
        $newContent = [regex]::Replace($newContent, $mobilePattern,  $mobileNew,  $opts)
    } else {
        $newContent = [regex]::Replace($content, $desktopPattern, $desktopNew2, $opts)
        $newContent = [regex]::Replace($newContent, $mobilePattern,  $mobileNew2,  $opts)
    }

    if ($newContent -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $enc)
        Write-Host "UPDATED: $($file.Name)"
        $updated++
    } else {
        Write-Host "UNCHANGED: $($file.Name)"
        $skipped++
    }
}

Write-Host ""
Write-Host "Done. Updated: $updated  Skipped/Unchanged: $skipped"
