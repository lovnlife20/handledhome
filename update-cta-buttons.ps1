# Handled Home - sitewide .cta button cleanup
#
# For each HTML page whose .cta block matches the expected two-link structure:
#   1. Removes the redundant   <a href="#contact"|"/#contact" class="email">Get Free Estimate</a>
#   2. Standardizes the remaining tel: call link's visible text to:
#         Call or text 412-353-5341
#
# The href="tel:14123535341" and the link's class are left unchanged.
# Heading <h2> and any subtext <p> are left untouched.
# style.css is not touched.
#
# Safety: only .cta blocks matching the exact two-link pattern are changed.
# Any page with a .cta block that does NOT match (e.g. a cross-link button,
# a differently-labeled button, or a single-button block) is left untouched
# and listed under SKIP for manual review.

$dir = $PSScriptRoot
$enc = [System.Text.Encoding]::UTF8   # UTF-8 with BOM, matches existing files

$rootFiles    = Get-ChildItem "$dir\*.html"
$contactFiles = Get-ChildItem "$dir\contact\*.html" -ErrorAction SilentlyContinue
$allFiles     = @($rootFiles) + @($contactFiles)

# Matches ONLY the cta two-anchor sequence:
#   <a href="tel:14123535341" class="call">ANY TEXT</a>
#   <a href="#contact"|"/#contact" class="email">Get Free Estimate</a>
# Group 1 = call link opening tag, Group 2 = its </a>, Group 3 = whitespace between anchors.
# (The hero buttons use `class="call" href="#contact"` / an sms: link, so they do NOT match.)
$pattern     = '(<a href="tel:14123535341" class="call">)[^<]*(</a>)(\s*)<a href="/?#contact" class="email">Get Free Estimate</a>'
$replacement = '${1}Call or text 412-353-5341${2}'
$opts        = [System.Text.RegularExpressions.RegexOptions]::Singleline

$updated = 0
$skipped = @()

foreach ($file in $allFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $enc)

    if (-not [regex]::IsMatch($content, $pattern, $opts)) {
        if ($content -match '<div class="cta">') {
            $skipped += $file.Name
            Write-Host "SKIP (cta present, non-standard buttons): $($file.Name)"
        }
        continue
    }

    $newContent = [regex]::Replace($content, $pattern, $replacement, $opts)

    if ($newContent -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $enc)
        Write-Host "UPDATED: $($file.Name)"
        $updated++
    }
}

Write-Host ""
Write-Host "Done. Updated: $updated   Skipped (manual review): $($skipped.Count)"
if ($skipped.Count) { Write-Host ("Skipped: " + ($skipped -join ', ')) }
