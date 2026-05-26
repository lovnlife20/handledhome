
# update-schema.ps1
Set-Location "C:\Users\aprus\Claude\handledhome"

$AREA = '[{"@type":"City","name":"Moon Township"},{"@type":"City","name":"Coraopolis"},{"@type":"City","name":"Oakdale"},{"@type":"City","name":"Sewickley"},{"@type":"City","name":"Robinson Township"},{"@type":"City","name":"Aliquippa"},{"@type":"City","name":"Ambridge"},{"@type":"City","name":"Cranberry Township"},{"@type":"City","name":"Wexford"},{"@type":"City","name":"Beaver"},{"@type":"City","name":"Monaca"},{"@type":"City","name":"Mt. Lebanon"},{"@type":"City","name":"Pittsburgh"}]'

$CATALOG = '{"@type":"OfferCatalog","name":"Handyman Services","itemListElement":[{"@type":"Offer","itemOffered":{"@type":"Service","name":"Deck Repair and Building"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Drywall Repair"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Door and Trim Repair"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Door Replacement"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Flooring Installation"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Exterior Trim and Wood Rot Repair"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Shed Building"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Shed Assembly"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Shutter Replacement"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"TV Mounting"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Smart Home Installation"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Picture Hanging"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Playset Installation"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Fixture Replacement"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Ceiling Fan Installation"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Faucet Replacement"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Leaking Faucet Repair"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Toilet Replacement"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Window Screen Repair"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Caulking and Weatherproofing"}},{"@type":"Offer","itemOffered":{"@type":"Service","name":"Handyman Services for Seniors"}}]}'

function Get-LB {
  return @"
    {
      "@type": ["LocalBusiness", "HomeAndConstructionBusiness"],
      "@id": "https://handledhome.net/#business",
      "name": "Handled Home",
      "description": "Fully insured handyman and home repair services in Moon Township and the Pittsburgh area. Deck repair, drywall, flooring, doors, sheds, faucets, TV mounting, smart home, and more.",
      "url": "https://handledhome.net/",
      "telephone": "+14123535341",
      "email": "info@handledhome.net",
      "priceRange": "`$`$",
      "image": "https://handledhome.net/social-preview-v3.png",
      "logo": { "@type": "ImageObject", "url": "https://handledhome.net/handled-home-logo-cropped.svg" },
      "address": { "@type": "PostalAddress", "addressLocality": "Moon Township", "addressRegion": "PA", "postalCode": "15108", "addressCountry": "US" },
      "geo": { "@type": "GeoCoordinates", "latitude": 40.5126, "longitude": -80.1673 },
      "areaServed": $AREA,
      "hasOfferCatalog": $CATALOG
    }
"@
}

function Get-SvcNode($name, $desc, $url, $typesJson) {
  return @"
    {
      "@type": "Service",
      "@id": "${url}#service",
      "name": "$name",
      "description": "$desc",
      "serviceType": $typesJson,
      "provider": { "@id": "https://handledhome.net/#business" },
      "areaServed": $AREA,
      "url": "$url"
    }
"@
}

function Set-Schema($file, $nodes) {
  $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
  $content = [regex]::Replace($content, '<script type="application/ld\+json">[\s\S]*?</script>\s*', '')
  $joined = $nodes -join ",`n"
  $block = "<script type=`"application/ld+json`">`n{`n  `"@context`": `"https://schema.org`",`n  `"@graph`": [`n$joined`n  ]`n}`n</script>`n"
  $content = $content -replace '</body>', "$block</body>"
  [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
  Write-Output "OK $file"
}

# ── SERVICE PAGES ──────────────────────────────────────────────────────────────

$svcs = @(
  ('deck-repair-moon-township-pa.html','Deck Repair and Building','Deck repair and building in Moon Township and the Pittsburgh area. Rotted boards, stair repair, railing repair, framing, and new deck construction.','["Deck Repair","Deck Building","Deck Board Replacement","Deck Stair Repair","Deck Railing Repair","Deck Framing Repair"]'),
  ('drywall-repair-moon-township-pa.html','Drywall Repair','Drywall hole patching, ceiling repair, crack repair, water-damage repair, and paint-ready finishing in Moon Township and Pittsburgh area.','["Drywall Repair","Ceiling Repair","Drywall Hole Patching","Drywall Crack Repair","Water Damage Drywall Repair"]'),
  ('door-trim-repair-moon-township-pa.html','Door and Trim Repair','Interior and exterior door adjustment, hinge repair, strike plate fix, and wood trim repair in Moon Township and Pittsburgh area.','["Door Repair","Trim Repair","Door Adjustment","Hinge Repair","Strike Plate Repair"]'),
  ('door-replacement-moon-township-pa.html','Door Replacement','Interior and exterior door replacement including slab doors, pre-hung doors, storm doors, and hardware in Moon Township and Pittsburgh area.','["Door Replacement","Interior Door Installation","Exterior Door Installation","Storm Door Installation","Bifold Door Installation"]'),
  ('flooring-installation-moon-township-pa.html','Flooring Installation','LVP, laminate, hardwood, and tile flooring installation in Moon Township and the Pittsburgh area.','["Flooring Installation","LVP Flooring Installation","Laminate Flooring","Hardwood Flooring","Tile Flooring"]'),
  ('exterior-trim-wood-rot-repair-moon-township-pa.html','Exterior Trim and Wood Rot Repair','Exterior trim repair, wood rot removal and replacement, fascia, soffit, and porch repair in Moon Township and Pittsburgh area.','["Wood Rot Repair","Exterior Trim Repair","Fascia Repair","Soffit Repair","Porch Repair"]'),
  ('shed-building-moon-township-pa.html','Shed Building','Custom shed construction and shed building services in Moon Township and the Pittsburgh area.','["Shed Building","Custom Shed Construction","Shed Foundation","Storage Building Construction"]'),
  ('shed-assembly-moon-township-pa.html','Shed Assembly','Pre-built and kit shed assembly, anchoring, and leveling in Moon Township and the Pittsburgh area.','["Shed Assembly","Shed Kit Assembly","Shed Anchoring","Shed Leveling"]'),
  ('shutter-replacement-moon-township-pa.html','Shutter Replacement','Exterior shutter removal and installation in Moon Township and the Pittsburgh area.','["Shutter Replacement","Shutter Installation","Exterior Shutter Repair"]'),
  ('tv-mounting-moon-township-pa.html','TV Mounting','TV wall mounting with wire concealment, stud-finding, and bracket installation in Moon Township and Pittsburgh area.','["TV Mounting","TV Wall Mount Installation","Wire Concealment"]'),
  ('smart-home-installation-moon-township-pa.html','Smart Home Installation','Smart thermostat, smart doorbell, smart lock, and smart home device installation in Moon Township and Pittsburgh area.','["Smart Home Installation","Smart Thermostat Installation","Smart Doorbell Installation","Smart Lock Installation"]'),
  ('picture-hanging-moon-township-pa.html','Picture Hanging','Professional picture hanging, gallery wall installation, and mirror mounting in Moon Township and Pittsburgh area.','["Picture Hanging","Gallery Wall Installation","Mirror Mounting"]'),
  ('playset-installation-moon-township-pa.html','Playset Installation','Playset assembly, swing set installation, leveling, and anchoring in Moon Township and Pittsburgh area.','["Playset Installation","Swing Set Assembly","Playset Assembly","Playset Anchoring"]'),
  ('fixture-replacement-moon-township-pa.html','Fixture Replacement','Light fixture, bathroom vanity light, and electrical fixture replacement in Moon Township and Pittsburgh area.','["Fixture Replacement","Light Fixture Installation","Vanity Light Installation"]'),
  ('ceiling-fan-installation-moon-township-pa.html','Ceiling Fan Installation','Ceiling fan installation and replacement in Moon Township and the Pittsburgh area.','["Ceiling Fan Installation","Ceiling Fan Replacement"]'),
  ('faucet-replacement-moon-township-pa.html','Faucet Replacement','Kitchen faucet, bathroom faucet, shower head, and outdoor hose bib replacement in Moon Township and Pittsburgh area.','["Faucet Replacement","Kitchen Faucet Installation","Bathroom Faucet Replacement","Shower Head Replacement","Outdoor Faucet Replacement"]'),
  ('leaking-faucet-repair-pittsburgh-pa.html','Leaking Faucet Repair','Leaking and dripping faucet repair in Pittsburgh, Moon Township, Coraopolis, Sewickley, Aliquippa, Cranberry Township, and surrounding areas.','["Leaking Faucet Repair","Faucet Leak Repair","Dripping Faucet Fix","Supply Line Replacement","Faucet Cartridge Replacement"]'),
  ('toilet-replacement-moon-township-pa.html','Toilet Replacement','Toilet removal and replacement in Moon Township and the Pittsburgh area. You supply the toilet, we handle the install.','["Toilet Replacement","Toilet Installation"]'),
  ('window-screen-repair-moon-township-pa.html','Window Screen Repair','Window screen repair and replacement in Moon Township and the Pittsburgh area.','["Window Screen Repair","Window Screen Replacement"]'),
  ('caulking-weatherproofing-moon-township-pa.html','Caulking and Weatherproofing','Caulking, weatherstripping, and weatherproofing services in Moon Township and the Pittsburgh area.','["Caulking","Weatherproofing","Weatherstripping Installation","Window Caulking","Door Weatherproofing"]'),
  ('handyman-for-seniors-moon-township-pa.html','Handyman Services for Seniors','Handyman services for seniors including grab bar installation, safety assessments, and home modification in Moon Township and Pittsburgh area.','["Handyman Services for Seniors","Grab Bar Installation","Senior Home Safety","Home Accessibility Modification"]')
)

Write-Output "Service pages..."
foreach ($s in $svcs) {
  $url = "https://handledhome.net/$($s[0])"
  Set-Schema $s[0] @((Get-LB), (Get-SvcNode $s[1] $s[2] $url $s[3]))
}

# ── LOCATION PAGES ─────────────────────────────────────────────────────────────

$locs = @(
  ('handyman-moon-township-pa.html','Moon Township','Handyman services in Moon Township, PA. Deck repair, drywall, flooring, doors, sheds, installations, and more. Fully insured.'),
  ('handyman-coraopolis-pa.html','Coraopolis','Handyman services in Coraopolis, PA. Repairs, installations, and home projects. Fully insured, serving Allegheny County.'),
  ('handyman-oakdale-pa.html','Oakdale','Handyman services in Oakdale, PA. Deck repair, drywall, flooring, doors, and installations. Fully insured.'),
  ('handyman-sewickley-pa.html','Sewickley','Handyman services in Sewickley, PA. Deck repair, drywall, flooring, doors, sheds, and more. Fully insured.'),
  ('handyman-robinson-pa.html','Robinson Township','Handyman services in Robinson Township, PA. Repairs, installations, and home projects. Fully insured.'),
  ('handyman-aliquippa-pa.html','Aliquippa','Handyman services in Aliquippa, PA. Deck repair, drywall, flooring, doors, and home repairs. Fully insured.'),
  ('handyman-ambridge-pa.html','Ambridge','Handyman services in Ambridge, PA. Repairs, installations, and home projects. Fully insured.'),
  ('handyman-cranberry-township-pa.html','Cranberry Township','Handyman services in Cranberry Township, PA. Deck repair, drywall, flooring, doors, and more. Fully insured.'),
  ('handyman-wexford-pa.html','Wexford','Handyman services in Wexford, PA. Repairs, installations, and home projects. Fully insured.'),
  ('handyman-beaver-pa.html','Beaver','Handyman services in Beaver, PA. Deck repair, drywall, flooring, doors, and home repairs. Fully insured.'),
  ('handyman-monaca-pa.html','Monaca','Handyman services in Monaca, PA. Repairs, installations, and home projects. Fully insured.'),
  ('handyman-mt-lebanon-pa.html','Mt. Lebanon','Handyman services in Mt. Lebanon, PA. Deck repair, drywall, flooring, doors, and more. Fully insured.')
)

Write-Output "Location pages..."
foreach ($l in $locs) {
  $url = "https://handledhome.net/$($l[0])"
  $sn = @"
    {
      "@type": "Service",
      "@id": "${url}#service",
      "name": "Handyman Services in $($l[1]), PA",
      "description": "$($l[2])",
      "serviceType": ["Handyman Services","Home Repair","Home Improvement"],
      "provider": { "@id": "https://handledhome.net/#business" },
      "areaServed": { "@type": "City", "name": "$($l[1])" },
      "url": "$url"
    }
"@
  Set-Schema $l[0] @((Get-LB), $sn)
}

# ── GENERIC PAGES ──────────────────────────────────────────────────────────────

Write-Output "Generic pages..."
foreach ($f in @('index.html','about-handled-home.html','our-work.html','blog.html','thank-you.html','contact/index.html')) {
  Set-Schema $f @((Get-LB))
}

# ── FAQ PAGE ──────────────────────────────────────────────────────────────────

Write-Output "FAQ page..."
$faqNode = @'
    {
      "@type": "FAQPage",
      "mainEntity": [
        { "@type": "Question", "name": "What areas do you serve?", "acceptedAnswer": { "@type": "Answer", "text": "Handled Home serves Moon Township, Coraopolis, Oakdale, Sewickley, Robinson Township, Aliquippa, Ambridge, Cranberry Township, Wexford, Beaver, Monaca, Mt. Lebanon, and nearby Pittsburgh-area communities." } },
        { "@type": "Question", "name": "Are you insured?", "acceptedAnswer": { "@type": "Answer", "text": "Yes. Handled Home is fully insured for handyman services, repairs, installations, and home projects." } },
        { "@type": "Question", "name": "Are you a registered contractor?", "acceptedAnswer": { "@type": "Answer", "text": "Yes. PA Contractor Registration number: T002900." } },
        { "@type": "Question", "name": "Do you offer free estimates?", "acceptedAnswer": { "@type": "Answer", "text": "Yes. Request a free estimate through the website, by calling 412-353-5341, or by texting project photos directly to that number." } },
        { "@type": "Question", "name": "Can I provide my own materials?", "acceptedAnswer": { "@type": "Answer", "text": "Yes. Homeowners can supply fixtures, flooring, fans, faucets, doors, or other materials. Have them on hand before the appointment." } },
        { "@type": "Question", "name": "Do you do plumbing work?", "acceptedAnswer": { "@type": "Answer", "text": "We handle handyman-level plumbing: faucet replacement, leaking faucet repair, toilet replacement, supply line replacement, and shower head replacement. We do not do full pipe runs or rough plumbing." } }
      ]
    }
'@
Set-Schema 'frequently-asked-questions.html' @((Get-LB), $faqNode)

# ── BLOG POSTS ────────────────────────────────────────────────────────────────

Write-Output "Blog posts..."
$posts = @(
  ('5-signs-your-deck-needs-repair.html','5 Signs Your Deck Needs Repair Before Summer','Walk your deck for these 5 warning signs before summer, with DIY fixes and when to call a pro.','2025-05-21'),
  ('energy-efficient-home-improvements-pittsburgh.html','Energy-Efficient Home Improvements for Pittsburgh Homeowners','Practical energy-saving upgrades for Pittsburgh homes including weatherproofing, insulation, and smart thermostats.','2025-05-21'),
  ('home-repairs-before-selling-pittsburgh.html','Home Repairs to Make Before Selling in Pittsburgh','The most important repairs Pittsburgh homeowners should make before listing their home.','2025-05-21'),
  ('home-repairs-you-should-never-ignore.html','Home Repairs You Should Never Ignore','Deferred repairs that get expensive fast and the warning signs to act on before a small issue becomes a big problem.','2025-05-21'),
  ('how-to-fix-a-hole-in-drywall.html','How to Fix a Hole in Drywall','Step-by-step guide to patching drywall holes of any size, from nail pops to fist-sized damage.','2025-05-21'),
  ('how-to-fix-squeaky-floors.html','How to Fix Squeaky Floors','Why floors squeak and the best fixes for hardwood, engineered wood, and subfloor squeaks.','2025-05-21'),
  ('why-doors-stick-in-summer.html','Why Doors Stick in Summer (And How to Fix It)','Why doors stick during humid Pittsburgh summers and the right ways to fix swollen, sticking doors.','2025-05-21'),
  ('how-to-fix-a-running-toilet.html','How to Fix a Running Toilet','Diagnose and fix a constantly running toilet with step-by-step instructions.','2025-05-21'),
  ('local-handyman-vs-big-contractor-moon-township-pa.html','Local Handyman vs. Big Contractor: Which Is Right for Your Job?','When to hire a local handyman and when a general contractor makes more sense for Pittsburgh-area home projects.','2025-05-21')
)

foreach ($p in $posts) {
  $url = "https://handledhome.net/$($p[0])"
  $bn = @"
    {
      "@type": "BlogPosting",
      "headline": "$($p[1])",
      "description": "$($p[2])",
      "datePublished": "$($p[3])",
      "url": "$url",
      "mainEntityOfPage": "$url",
      "author": { "@type": "Organization", "@id": "https://handledhome.net/#business" },
      "publisher": { "@id": "https://handledhome.net/#business" }
    }
"@
  Set-Schema $p[0] @((Get-LB), $bn)
}

Write-Output "All done."
