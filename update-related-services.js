// Adds a curated "Related Services" block to every Handled Home service page.
//
//   node update-related-services.js
//
// Run it from anywhere — paths resolve relative to this file, not the cwd.
//
// The link map below is the source of truth for which service pages point at each
// other. Each entry is: page -> intro sentence + a list of [target, link text, why].
// The "why" is not decoration — the reason text is the anchor context Google uses to
// infer how two services relate, so keep it specific rather than generic.
//
// The rendered block is wrapped in <!-- related-services:start --> / :end markers and
// inserted just before the page's <div id="contact"> estimate form. Re-running strips
// any existing block first, so this is safe to run repeatedly and will never stack
// duplicates. That also means: edit the map here and re-run, rather than hand-editing
// the generated block in the HTML — a hand edit gets silently overwritten on the next
// run, and this script goes stale the same way update-schema.ps1 did.
//
// When adding a new service page: add its own entry here, AND add it as a target in
// the lists of a few related pages, so the new page has inbound links too.
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;

const M = {

'appliance-installation-moon-township-pa.html': {
  intro: 'Appliance swaps usually turn up alongside a few other kitchen and laundry jobs. These are the ones homeowners most often bundle in.',
  items: [
    ['dryer-vent-cleaning-moon-township-pa.html', 'Dryer Vent Cleaning', 'The right time to clear the vent line is while the dryer is already pulled out.'],
    ['garbage-disposal-replacement-moon-township-pa.html', 'Garbage Disposal Replacement', 'Another under-the-sink swap that often gets handled on the same visit.'],
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'For when the appliance outlet behind it is loose, scorched, or the wrong type.'],
    ['countertop-installation-moon-township-pa.html', 'Countertop Installation', 'New range or dishwasher going in as part of a wider kitchen update.'],
  ],
},

'baseboard-molding-installation-moon-township-pa.html': {
  intro: 'Trim work almost never happens on its own. Here is what usually gets scheduled with it.',
  items: [
    ['flooring-installation-moon-township-pa.html', 'Flooring Installation', 'New floor first, then baseboard back on &mdash; that order is what makes the edges look clean.'],
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Dings and gouges along the wall are easiest to patch before new trim goes up.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Fresh trim needs paint, and a full run blends better than a spot touch-up.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Casing and door trim in the same rooms, matched to the new baseboard profile.'],
  ],
},

'cabinet-adjustment-repair-moon-township-pa.html': {
  intro: 'Cabinet tune-ups are a common piece of a larger kitchen or bath refresh.',
  items: [
    ['countertop-installation-moon-township-pa.html', 'Countertop Installation', 'Cabinets need to be level and solid before a new counter goes on top.'],
    ['shelving-installation-moon-township-pa.html', 'Shelving Installation', 'Extra storage in the pantry, garage, or closet while we are already there.'],
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'Bathroom cabinet doors that sag are often paired with a vanity swap.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Touching up the cabinet boxes and surrounding trim after the hardware work.'],
  ],
},

'caulking-weatherproofing-moon-township-pa.html': {
  intro: 'Sealing up the outside of a house tends to reveal a few neighboring problems. These are the related jobs we handle.',
  items: [
    ['interior-caulking-sealing-moon-township-pa.html', 'Interior Caulking &amp; Sealing', 'The same work on the inside &mdash; tubs, showers, backsplashes, and trim gaps.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'Where caulk has failed long enough, the wood behind it usually needs attention first.'],
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'Gaps at siding joints and penetrations are a common water entry point.'],
    ['window-screen-repair-moon-township-pa.html', 'Window Screen Repair', 'Easy to knock out while we are already working window to window.'],
    ['seasonal-home-maintenance-moon-township-pa.html', 'Seasonal Home Maintenance', 'Weatherproofing is one item on the fall checklist &mdash; we can handle the rest of it too.'],
  ],
},

'ceiling-fan-installation-moon-township-pa.html': {
  intro: 'Fan installs often come with a short list of other fixture and electrical items.',
  items: [
    ['fixture-replacement-moon-township-pa.html', 'Fixture Replacement', 'Swapping dated light fixtures in the same rooms while the ladder is out.'],
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'For adding or updating the wall switch that controls the fan.'],
    ['smart-home-installation-moon-township-pa.html', 'Smart Home Device Installation', 'Smart switches and dimmers set up alongside the new fan.'],
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Patching the ceiling when the old box or fixture leaves a gap behind.'],
  ],
},

'closet-door-replacement-moon-township-pa.html': {
  intro: 'Closet doors are usually one line on a bigger door and storage list.',
  items: [
    ['door-replacement-moon-township-pa.html', 'Door Replacement', 'Interior and exterior doors replaced on the same visit.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Sticking doors, worn casing, and hardware that no longer lines up.'],
    ['shelving-installation-moon-township-pa.html', 'Shelving Installation', 'New closet shelving and rods while the doors are already off.'],
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'Matching casing and base trim around the new closet opening.'],
  ],
},

'countertop-installation-moon-township-pa.html': {
  intro: 'A new countertop touches the sink, the faucet, and the cabinets underneath. We handle all of it.',
  items: [
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'Sink swaps are part of most counter jobs, especially in bathrooms.'],
    ['faucet-replacement-moon-township-pa.html', 'Faucet Replacement', 'Easiest moment to put in a new faucet is while the old counter is out.'],
    ['cabinet-adjustment-repair-moon-township-pa.html', 'Cabinet Adjustments &amp; Repairs', 'Boxes need to be level and sound before a new top goes down.'],
    ['garbage-disposal-replacement-moon-township-pa.html', 'Garbage Disposal Replacement', 'Same trip under the sink, so it rarely makes sense to defer.'],
  ],
},

'curtain-rods-blinds-installation-moon-township-pa.html': {
  intro: 'Hanging window treatments is usually one item on a room-finishing list.',
  items: [
    ['picture-hanging-moon-township-pa.html', 'Picture Hanging &amp; Art Installation', 'Art, mirrors, and gallery walls hung level and anchored properly.'],
    ['shelving-installation-moon-township-pa.html', 'Shelving Installation', 'Floating shelves and closet systems mounted into solid backing.'],
    ['tv-mounting-moon-township-pa.html', 'TV Mounting', 'The other thing that goes on the wall in the same room.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Old bracket holes patched and touched up before the new hardware goes up.'],
  ],
},

'deck-repair-moon-township-pa.html': {
  intro: 'Deck work rarely stops at the deck. These are the services homeowners most often combine with it.',
  items: [
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'Front porch decking, framing, and posts &mdash; the same work, different structure.'],
    ['porch-step-stair-repair-moon-township-pa.html', 'Porch Step &amp; Stair Repair', 'Deck stairs and stringers that have gone soft or pulled loose.'],
    ['railing-installation-moon-township-pa.html', 'Railing Installation', 'New railing when the deck surface itself is still sound.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Cleaning the deck first is what makes a stain or seal actually hold.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'The moisture that rots deck boards is usually working on the house trim too.'],
  ],
},

'deck-repair-robinson-township-pa.html': {
  intro: 'Other services we handle for Robinson Township homeowners.',
  items: [
    ['drywall-repair-robinson-township-pa.html', 'Drywall Repair in Robinson Township', 'Holes, cracks, water damage, and ceiling repairs finished ready for paint.'],
    ['door-trim-repair-robinson-township-pa.html', 'Door &amp; Trim Repair in Robinson Township', 'Sticking doors, worn casing, and failed weatherstripping on older Robinson homes.'],
    ['flooring-installation-robinson-township-pa.html', 'Flooring Installation in Robinson Township', 'LVP, laminate, and vinyl plank installed over prepped subfloor.'],
    ['railing-installation-moon-township-pa.html', 'Railing Installation', 'New deck and stair railing, in Robinson and across the Pittsburgh area.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Getting years of grey off the boards before any stain or sealer goes on.'],
  ],
},

'door-replacement-moon-township-pa.html': {
  intro: 'New doors usually come with a few related items around the opening.',
  items: [
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'When the door is fine and it is the casing, hinges, or latch that is not.'],
    ['storm-screen-door-repair-moon-township-pa.html', 'Storm &amp; Screen Door Repair', 'Storm doors that sag, will not latch, or have a failed closer.'],
    ['closet-door-replacement-moon-township-pa.html', 'Closet Door Replacement', 'Bifold, sliding, and hinged closet doors swapped out to match.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Sealing and weatherstripping the new opening so you are not paying to heat the yard.'],
  ],
},

'door-trim-repair-moon-township-pa.html': {
  intro: 'Door and trim work is usually one part of a room that needs a few things handled.',
  items: [
    ['door-replacement-moon-township-pa.html', 'Door Replacement', 'When the door itself is past repairing and a new slab or unit makes more sense.'],
    ['closet-door-replacement-moon-township-pa.html', 'Closet Door Replacement', 'Bifold and sliding doors that jump the track or will not stay aligned.'],
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'Matching casing, base, and crown so the trim reads as one profile.'],
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Knob holes, cracked corners, and the wall damage doors tend to leave behind.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Repaired trim painted corner to corner so the new coat is not obvious.'],
  ],
},

'door-trim-repair-robinson-township-pa.html': {
  intro: 'Other services we handle for Robinson Township homeowners.',
  items: [
    ['deck-repair-robinson-township-pa.html', 'Deck Repair in Robinson Township', 'Board replacement, framing, and rebuilds on decks from the 90s and 2000s.'],
    ['drywall-repair-robinson-township-pa.html', 'Drywall Repair in Robinson Township', 'Holes, cracks, and ceiling repairs finished ready for paint.'],
    ['flooring-installation-robinson-township-pa.html', 'Flooring Installation in Robinson Township', 'LVP, laminate, and vinyl plank installed over prepped subfloor.'],
    ['door-replacement-moon-township-pa.html', 'Door Replacement', 'For doors past the point where a repair is the right call.'],
  ],
},

'dryer-vent-cleaning-moon-township-pa.html': {
  intro: 'Vent cleaning is usually part of a wider home maintenance visit.',
  items: [
    ['appliance-installation-moon-township-pa.html', 'Appliance Installation', 'Washer, dryer, and other appliance hookups done at the same time.'],
    ['seasonal-home-maintenance-moon-township-pa.html', 'Seasonal Home Maintenance', 'The recurring checklist a vent cleaning belongs on.'],
    ['smoke-detector-installation-moon-township-pa.html', 'Smoke Detector Installation', 'Another safety item worth handling on the same visit.'],
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'For when the exterior vent hood or the siding around it is damaged.'],
  ],
},

'drywall-repair-moon-township-pa.html': {
  intro: 'Drywall work is a step in a lot of bigger projects. Here is what commonly goes with it.',
  items: [
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'A patch is only invisible once the wall is painted wall-to-wall.'],
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'Trim off, wall repaired, trim back on &mdash; the usual sequence.'],
    ['tv-mounting-moon-township-pa.html', 'TV Mounting', 'Old mount holes patched and a new mount anchored into studs.'],
    ['ceiling-fan-installation-moon-township-pa.html', 'Ceiling Fan Installation', 'Ceiling patching around a new fan box or relocated fixture.'],
  ],
},

'drywall-repair-robinson-township-pa.html': {
  intro: 'Other services we handle for Robinson Township homeowners.',
  items: [
    ['door-trim-repair-robinson-township-pa.html', 'Door &amp; Trim Repair in Robinson Township', 'Sticking doors, worn casing, and failed weatherstripping.'],
    ['flooring-installation-robinson-township-pa.html', 'Flooring Installation in Robinson Township', 'LVP, laminate, and vinyl plank installed over prepped subfloor.'],
    ['deck-repair-robinson-township-pa.html', 'Deck Repair in Robinson Township', 'Board replacement, framing repairs, and full rebuilds.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Patches painted out so the repair does not read as a repair.'],
  ],
},

'exterior-trim-wood-rot-repair-moon-township-pa.html': {
  intro: 'Rot is a water problem, so it usually shows up next to a few other things worth fixing.',
  items: [
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'Damaged siding is often what let water reach the trim in the first place.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Resealing joints and penetrations so the repaired wood stays dry.'],
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'Posts, columns, and porch framing that have gone soft at the base.'],
    ['shutter-replacement-moon-township-pa.html', 'Shutter Replacement', 'Faded or cracked shutters replaced while we are already on the ladder.'],
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'The same rot showing up on deck boards, joists, and posts.'],
  ],
},

'faucet-replacement-moon-township-pa.html': {
  intro: 'Faucet swaps rarely justify a trip on their own. These are the jobs homeowners pair with them.',
  items: [
    ['leaking-faucet-repair-pittsburgh-pa.html', 'Leaking Faucet Repair', 'When a repair makes more sense than replacing the whole fixture.'],
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'New sink or vanity going in under the faucet.'],
    ['garbage-disposal-replacement-moon-township-pa.html', 'Garbage Disposal Replacement', 'Same cabinet, same shutoffs, same visit.'],
    ['toilet-replacement-moon-township-pa.html', 'Toilet Replacement', 'The other fixture people usually want handled while we are there.'],
  ],
},

'fence-gate-repair-moon-township-pa.html': {
  intro: 'Fence work sits alongside the rest of the yard and curb-appeal list.',
  items: [
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'The same post setting and framing work, on a different structure.'],
    ['railing-installation-moon-township-pa.html', 'Railing Installation', 'Porch and deck railing in matching materials.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Cleaning a grey or algae-covered fence before sealing it.'],
    ['mailbox-installation-moon-township-pa.html', 'Mailbox Installation', 'Another post set in concrete out at the curb.'],
  ],
},

'fixture-replacement-moon-township-pa.html': {
  intro: 'Fixture swaps go quickly, so most homeowners have us handle several items at once.',
  items: [
    ['ceiling-fan-installation-moon-township-pa.html', 'Ceiling Fan Installation', 'Fans that need a rated box, not just a fixture swap.'],
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'Dated or loose switches and outlets updated in the same rooms.'],
    ['outdoor-lighting-installation-moon-township-pa.html', 'Outdoor &amp; Patio Lighting', 'Exterior fixtures, post lights, and patio lighting.'],
    ['smoke-detector-installation-moon-township-pa.html', 'Smoke Detector Installation', 'Detectors that are past their ten-year replacement date.'],
  ],
},

'flooring-installation-moon-township-pa.html': {
  intro: 'New floors change what the trim and doors need. These usually go together.',
  items: [
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'Base and quarter round back on cleanly once the floor is down.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Doors undercut or adjusted to clear a new floor height.'],
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Wall damage along the base, easiest to fix with the trim off.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Painting before the new floor goes in saves the cleanup after.'],
  ],
},

'flooring-installation-robinson-township-pa.html': {
  intro: 'Other services we handle for Robinson Township homeowners.',
  items: [
    ['drywall-repair-robinson-township-pa.html', 'Drywall Repair in Robinson Township', 'Holes, cracks, and ceiling repairs finished ready for paint.'],
    ['door-trim-repair-robinson-township-pa.html', 'Door &amp; Trim Repair in Robinson Township', 'Doors adjusted to clear a new floor height, plus casing and base repairs.'],
    ['deck-repair-robinson-township-pa.html', 'Deck Repair in Robinson Township', 'Board replacement, framing repairs, and full rebuilds.'],
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'Base and quarter round back on cleanly once the floor is down.'],
  ],
},

'furniture-assembly-moon-township-pa.html': {
  intro: 'If there is a box in the garage, there is usually more than one. These are the related jobs.',
  items: [
    ['shelving-installation-moon-township-pa.html', 'Shelving Installation', 'Shelving that needs to be anchored to the wall, not just assembled.'],
    ['tv-mounting-moon-township-pa.html', 'TV Mounting', 'The TV that goes above the console we just built.'],
    ['picture-hanging-moon-township-pa.html', 'Picture Hanging &amp; Art Installation', 'Finishing the room once the furniture is placed.'],
    ['playset-installation-moon-township-pa.html', 'Playset Installation', 'The much bigger box, assembled and anchored in the yard.'],
  ],
},

'garbage-disposal-replacement-moon-township-pa.html': {
  intro: 'Under-sink work tends to come in groups. Here is what usually gets handled together.',
  items: [
    ['faucet-replacement-moon-township-pa.html', 'Faucet Replacement', 'Same cabinet, same shutoffs &mdash; worth doing on one visit.'],
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'A new sink or vanity going in above the disposal.'],
    ['countertop-installation-moon-township-pa.html', 'Countertop Installation', 'Disposal and plumbing reconnected as part of a counter swap.'],
    ['appliance-installation-moon-township-pa.html', 'Appliance Installation', 'Dishwasher hookups, which tie straight into the disposal.'],
  ],
},

'handyman-for-seniors-moon-township-pa.html': {
  intro: 'The requests we get most often for aging-in-place and safety work.',
  items: [
    ['railing-installation-moon-township-pa.html', 'Railing Installation', 'Grab-friendly handrails on steps and porches, anchored properly.'],
    ['porch-step-stair-repair-moon-township-pa.html', 'Porch Step &amp; Stair Repair', 'Uneven, soft, or loose steps &mdash; the most common fall hazard we see.'],
    ['smoke-detector-installation-moon-township-pa.html', 'Smoke Detector Installation', 'Replacing detectors that are past date, so no ladder is needed.'],
    ['handyman-punch-list-maintenance-moon-township-pa.html', 'Punch List &amp; Maintenance Visits', 'One visit for the whole list instead of a call per item.'],
    ['storm-screen-door-repair-moon-township-pa.html', 'Storm &amp; Screen Door Repair', 'Doors that have gotten heavy or hard to latch.'],
  ],
},

'handyman-punch-list-maintenance-moon-township-pa.html': {
  intro: 'A punch list visit is usually made up of these. Any of them can be its own job too.',
  items: [
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Holes, dings, and cracks patched and finished ready for paint.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Doors that stick, latches that miss, and casing that has pulled loose.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Failed exterior seals, gaps, and worn weatherstripping.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Touch-ups that follow the repairs so nothing is left half-done.'],
    ['rental-property-turnover-repairs-moon-township-pa.html', 'Rental Turnover Repairs', 'The same approach on a deadline, between tenants.'],
  ],
},

'interior-caulking-sealing-moon-township-pa.html': {
  intro: 'Interior sealing usually shows up alongside bath and trim work.',
  items: [
    ['shower-door-installation-moon-township-pa.html', 'Shower Door Installation', 'A new door and a fresh seal at the base go hand in hand.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'The same work on the exterior of the house.'],
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'Sealing a vanity and backsplash after a swap.'],
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'Caulked trim joints are what make new molding look finished.'],
  ],
},

'interior-painting-touch-ups-moon-township-pa.html': {
  intro: 'Paint is almost always the last step. These are the repairs that come before it.',
  items: [
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Patches sanded and primed so they disappear under the topcoat.'],
    ['baseboard-molding-installation-moon-township-pa.html', 'Baseboard &amp; Molding Installation', 'New trim painted in place, run to run.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Repaired casing and doors finished ready for paint.'],
    ['interior-caulking-sealing-moon-township-pa.html', 'Interior Caulking &amp; Sealing', 'Caulking trim gaps before painting is what keeps the lines sharp.'],
  ],
},

'leaking-faucet-repair-pittsburgh-pa.html': {
  intro: 'A drip is often one of several small plumbing items on the list.',
  items: [
    ['faucet-replacement-moon-township-pa.html', 'Faucet Replacement', 'When parts are no longer available or the fixture is past repairing.'],
    ['toilet-replacement-moon-township-pa.html', 'Toilet Replacement', 'Running or leaking toilets, handled on the same visit.'],
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'For leaks that turn out to be the drain or the vanity itself.'],
    ['garbage-disposal-replacement-moon-township-pa.html', 'Garbage Disposal Replacement', 'The other common source of a wet cabinet floor.'],
  ],
},

'mailbox-installation-moon-township-pa.html': {
  intro: 'Mailbox work is usually one item on a bigger curb-appeal list. These are the jobs homeowners pair with it most.',
  items: [
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'The other thing at the front of the house guests actually look at.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Driveway, walkway, and siding cleaned while we are out front.'],
    ['fence-gate-repair-moon-township-pa.html', 'Fence &amp; Gate Repair', 'The same post setting work, further down the property line.'],
    ['outdoor-lighting-installation-moon-township-pa.html', 'Outdoor &amp; Patio Lighting', 'Post and path lighting to go with the new mailbox.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'If the mailbox post rotted out, the trim on the house may be next.'],
  ],
},

'outdoor-lighting-installation-moon-township-pa.html': {
  intro: 'Exterior lighting is usually part of a larger outdoor project.',
  items: [
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'Post cap and stair lighting worked in while the deck is open.'],
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'Fixtures updated as part of a front porch refresh.'],
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'Exterior outlets and the switches that control the new lights.'],
    ['smart-home-installation-moon-township-pa.html', 'Smart Home Device Installation', 'Timers, smart switches, and cameras set up with the lighting.'],
    ['fixture-replacement-moon-township-pa.html', 'Fixture Replacement', 'Dated porch and garage fixtures swapped out.'],
  ],
},

'outlet-switch-replacement-moon-township-pa.html': {
  intro: 'Device swaps go fast, so they are usually bundled with other electrical items.',
  items: [
    ['fixture-replacement-moon-township-pa.html', 'Fixture Replacement', 'Lights updated in the same rooms as the switches.'],
    ['ceiling-fan-installation-moon-township-pa.html', 'Ceiling Fan Installation', 'Fan control and wall switch handled together.'],
    ['smart-home-installation-moon-township-pa.html', 'Smart Home Device Installation', 'Smart switches, dimmers, and video doorbells.'],
    ['smoke-detector-installation-moon-township-pa.html', 'Smoke Detector Installation', 'Hardwired and battery detectors replaced on the same visit.'],
  ],
},

'pergola-installation-moon-township-pa.html': {
  intro: 'Other outdoor structure and assembly work we handle.',
  items: [
    ['shed-assembly-moon-township-pa.html', 'Shed Assembly', 'Customer-supplied shed kits assembled, leveled, and anchored.'],
    ['shed-building-moon-township-pa.html', 'Shed Building', 'For a shed built on site rather than out of a kit.'],
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'The deck or patio a pergola kit usually goes over.'],
    ['playset-installation-moon-township-pa.html', 'Playset Installation', 'Another kit that needs to be assembled level and anchored properly.'],
    ['outdoor-lighting-installation-moon-township-pa.html', 'Outdoor &amp; Patio Lighting', 'String and post lighting run once the structure is up.'],
  ],
},

'picture-hanging-moon-township-pa.html': {
  intro: 'Hanging things on walls is rarely a one-item job. Here is what goes with it.',
  items: [
    ['tv-mounting-moon-township-pa.html', 'TV Mounting', 'The heaviest thing on the wall, anchored into studs.'],
    ['curtain-rods-blinds-installation-moon-township-pa.html', 'Curtain Rods &amp; Blinds', 'Window treatments hung level in the same rooms.'],
    ['shelving-installation-moon-township-pa.html', 'Shelving Installation', 'Floating shelves that need real backing behind them.'],
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Old anchor holes patched before the new layout goes up.'],
  ],
},

'playset-installation-moon-township-pa.html': {
  intro: 'Other assembly and backyard work we take on.',
  items: [
    ['shed-assembly-moon-township-pa.html', 'Shed Assembly', 'The same kit assembly work, scaled up.'],
    ['furniture-assembly-moon-township-pa.html', 'Furniture Assembly', 'Flat-pack furniture built and anchored indoors.'],
    ['pergola-installation-moon-township-pa.html', 'Gazebo &amp; Pergola Kit Installation', 'Customer-supplied outdoor structure kits assembled and anchored.'],
    ['fence-gate-repair-moon-township-pa.html', 'Fence &amp; Gate Repair', 'Fencing and gates around the play area.'],
  ],
},

'porch-repair-moon-township-pa.html': {
  intro: 'Porch projects usually pull in a couple of neighboring repairs.',
  items: [
    ['porch-step-stair-repair-moon-township-pa.html', 'Porch Step &amp; Stair Repair', 'Steps, stringers, and treads that have gone soft or loose.'],
    ['railing-installation-moon-township-pa.html', 'Railing Installation', 'New or replacement railing to code height.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'Rotted columns, skirting, and trim around the porch.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Cleaning the porch and walkway before any paint or sealer.'],
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'The same framing and decking work out back.'],
  ],
},

'porch-step-stair-repair-moon-township-pa.html': {
  intro: 'Step repairs are usually part of a larger porch or deck job.',
  items: [
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'Decking, framing, columns, and the rest of the structure.'],
    ['railing-installation-moon-township-pa.html', 'Railing Installation', 'Adding a handrail alongside the step repair.'],
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'Deck stairs and stringers built or replaced.'],
    ['handyman-for-seniors-moon-township-pa.html', 'Handyman Services for Seniors', 'Safe steps and grab-friendly rails for aging in place.'],
  ],
},

'pressure-washing-moon-township-pa.html': {
  intro: 'Washing is often step one. These are the repairs it tends to lead into.',
  items: [
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'Once it is clean, the boards that need replacing are obvious.'],
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'Cracked and loose panels found during a house wash.'],
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'Porch floors, columns, and skirting cleaned and repaired.'],
    ['fence-gate-repair-moon-township-pa.html', 'Fence &amp; Gate Repair', 'Grey, algae-covered fencing cleaned and reset.'],
    ['mailbox-installation-moon-township-pa.html', 'Mailbox Installation', 'A leaning or weathered mailbox post, while we are out front.'],
  ],
},

'railing-installation-moon-township-pa.html': {
  intro: 'Railing work connects to the rest of the porch or deck. We handle all of it.',
  items: [
    ['porch-step-stair-repair-moon-township-pa.html', 'Porch Step &amp; Stair Repair', 'Steps and stringers repaired before the handrail goes on.'],
    ['porch-repair-moon-township-pa.html', 'Porch Repair', 'Decking, framing, and columns on the front porch.'],
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'Board replacement, framing repairs, and rebuilds out back.'],
    ['handyman-for-seniors-moon-township-pa.html', 'Handyman Services for Seniors', 'Handrails and safety work for aging in place.'],
  ],
},

'rental-property-turnover-repairs-moon-township-pa.html': {
  intro: 'The repairs that make up most turnovers. Any of them can be booked on its own.',
  items: [
    ['drywall-repair-moon-township-pa.html', 'Drywall Repair', 'Anchor holes, dings, and damage patched between tenants.'],
    ['interior-painting-touch-ups-moon-township-pa.html', 'Interior Painting &amp; Touch-Ups', 'Wall-to-wall touch-ups so the unit shows clean.'],
    ['flooring-installation-moon-township-pa.html', 'Flooring Installation', 'LVP that holds up to the next tenant.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Doors, latches, and casing back in working order.'],
    ['handyman-punch-list-maintenance-moon-township-pa.html', 'Punch List &amp; Maintenance Visits', 'One visit for the whole list, on your timeline.'],
  ],
},

'seasonal-home-maintenance-moon-township-pa.html': {
  intro: 'The individual jobs a seasonal visit is usually made of.',
  items: [
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Sealing up before winter, the highest-value item on the fall list.'],
    ['dryer-vent-cleaning-moon-township-pa.html', 'Dryer Vent Cleaning', 'A lint-packed vent line cleared out.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Spring cleanup for siding, decks, and walkways.'],
    ['smoke-detector-installation-moon-township-pa.html', 'Smoke Detector Installation', 'Detectors past their ten-year date, replaced.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'Catching soft trim before another winter gets into it.'],
  ],
},

'shed-assembly-moon-township-pa.html': {
  intro: 'Other assembly and outdoor structure work we handle.',
  items: [
    ['shed-building-moon-township-pa.html', 'Shed Building', 'For a shed built on site instead of assembled from a kit.'],
    ['playset-installation-moon-township-pa.html', 'Playset Installation', 'Swing sets and playsets assembled, leveled, and anchored.'],
    ['pergola-installation-moon-township-pa.html', 'Gazebo &amp; Pergola Kit Installation', 'Customer-supplied kits assembled, leveled, and anchored.'],
    ['furniture-assembly-moon-township-pa.html', 'Furniture Assembly', 'The same work indoors, on a smaller scale.'],
  ],
},

'shed-building-moon-township-pa.html': {
  intro: 'Related outdoor building and assembly services.',
  items: [
    ['shed-assembly-moon-township-pa.html', 'Shed Assembly', 'For a kit you have already bought and want put together right.'],
    ['pergola-installation-moon-township-pa.html', 'Gazebo &amp; Pergola Kit Installation', 'Customer-supplied outdoor structure kits assembled and anchored.'],
    ['deck-repair-moon-township-pa.html', 'Deck Repair &amp; Building', 'The same framing and decking work on a deck.'],
    ['fence-gate-repair-moon-township-pa.html', 'Fence &amp; Gate Repair', 'Posts, panels, and gates around the yard.'],
  ],
},

'shelving-installation-moon-township-pa.html': {
  intro: 'Storage jobs usually come with a few other things that need mounting.',
  items: [
    ['furniture-assembly-moon-township-pa.html', 'Furniture Assembly', 'Flat-pack units built and anchored to the wall.'],
    ['cabinet-adjustment-repair-moon-township-pa.html', 'Cabinet Adjustments &amp; Repairs', 'Doors, hinges, and drawer slides brought back into alignment.'],
    ['closet-door-replacement-moon-township-pa.html', 'Closet Door Replacement', 'New closet doors to go with the new closet system.'],
    ['tv-mounting-moon-township-pa.html', 'TV Mounting', 'Another wall load that has to hit real framing.'],
  ],
},

'shower-door-installation-moon-township-pa.html': {
  intro: 'Shower door work is usually part of a wider bathroom update.',
  items: [
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'Vanity and sink swapped in the same bathroom.'],
    ['interior-caulking-sealing-moon-township-pa.html', 'Interior Caulking &amp; Sealing', 'Resealing the tub, base, and surround so water stays in.'],
    ['toilet-replacement-moon-township-pa.html', 'Toilet Replacement', 'The other fixture people handle at the same time.'],
    ['faucet-replacement-moon-township-pa.html', 'Faucet Replacement', 'New fixtures to match the new door hardware.'],
  ],
},

'shutter-installation-moon-township-pa.html': {
  intro: 'Shutter work goes with the rest of the exterior. Here is what we handle alongside it.',
  items: [
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'Cracked or loose panels behind and around the shutters.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'Soft window trim found once old shutters come off.'],
    ['window-screen-repair-moon-township-pa.html', 'Window Screen Repair', 'Torn and sagging screens, done window by window.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Washing the siding so new shutters do not sit against grime.'],
  ],
},

'shutter-replacement-moon-township-pa.html': {
  intro: 'Replacing shutters usually happens alongside other exterior work.',
  items: [
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'Damaged panels behind the old shutters, repaired first.'],
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'Window trim that has gone soft under years of trapped moisture.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Sealing old fastener holes and window joints.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Cleaning the siding so the new shutters do not sit against grime.'],
  ],
},

'siding-repair-moon-township-pa.html': {
  intro: 'Siding is one layer of the exterior. These are the neighboring jobs we handle.',
  items: [
    ['exterior-trim-wood-rot-repair-moon-township-pa.html', 'Exterior Trim &amp; Wood Rot Repair', 'Fascia, corner boards, and window trim behind failing siding.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Sealing joints and penetrations that let water in.'],
    ['shutter-installation-moon-township-pa.html', 'Shutter Installation &amp; Replacement', 'Shutters remounted cleanly on the repaired wall.'],
    ['pressure-washing-moon-township-pa.html', 'Pressure Washing', 'Washing the house to find the damage in the first place.'],
  ],
},

'sink-vanity-installation-moon-township-pa.html': {
  intro: 'Sink and vanity work touches a few other fixtures. We handle them together.',
  items: [
    ['faucet-replacement-moon-township-pa.html', 'Faucet Replacement', 'New faucet installed with the new sink.'],
    ['countertop-installation-moon-township-pa.html', 'Countertop Installation', 'Vanity tops and kitchen counters replaced above the sink.'],
    ['shower-door-installation-moon-township-pa.html', 'Shower Door Installation', 'The other big bathroom item people bundle in.'],
    ['garbage-disposal-replacement-moon-township-pa.html', 'Garbage Disposal Replacement', 'Reconnected or replaced during a kitchen sink swap.'],
  ],
},

'smart-home-installation-moon-township-pa.html': {
  intro: 'Smart devices tie into the wiring and fixtures already in the house.',
  items: [
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'Smart switches and dimmers put in where the old ones were.'],
    ['smoke-detector-installation-moon-township-pa.html', 'Smoke Detector Installation', 'Connected and standard detectors installed and tested.'],
    ['outdoor-lighting-installation-moon-township-pa.html', 'Outdoor &amp; Patio Lighting', 'Exterior lighting on timers, sensors, or app control.'],
    ['tv-mounting-moon-township-pa.html', 'TV Mounting', 'Mounting and cable management for the display side of the setup.'],
  ],
},

'smoke-detector-installation-moon-township-pa.html': {
  intro: 'Detector work is usually part of a broader safety or electrical visit.',
  items: [
    ['smart-home-installation-moon-township-pa.html', 'Smart Home Device Installation', 'Connected detectors, sensors, and doorbells set up.'],
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'Loose or dated devices swapped on the same visit.'],
    ['fixture-replacement-moon-township-pa.html', 'Fixture Replacement', 'Ceiling and wall fixtures updated while the ladder is out.'],
    ['handyman-for-seniors-moon-township-pa.html', 'Handyman Services for Seniors', 'Safety work so nobody is on a stepladder to change a battery.'],
  ],
},

'storm-screen-door-repair-moon-township-pa.html': {
  intro: 'Storm door work sits next to the rest of the entry and screen jobs.',
  items: [
    ['window-screen-repair-moon-township-pa.html', 'Window Screen Repair', 'Torn screens rescreened at the same time.'],
    ['door-replacement-moon-township-pa.html', 'Door Replacement', 'When the entry door behind it needs replacing too.'],
    ['door-trim-repair-moon-township-pa.html', 'Door &amp; Trim Repair', 'Casing, hinges, and latches that have pulled out of alignment.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Sealing and weatherstripping the opening once the door hangs right.'],
  ],
},

'toilet-replacement-moon-township-pa.html': {
  intro: 'Toilet swaps are usually one item on a short bathroom list.',
  items: [
    ['faucet-replacement-moon-township-pa.html', 'Faucet Replacement', 'The other fixture that gets dated at the same rate.'],
    ['sink-vanity-installation-moon-township-pa.html', 'Sink &amp; Vanity Installation', 'Vanity and sink replaced in the same bathroom.'],
    ['leaking-faucet-repair-pittsburgh-pa.html', 'Leaking Faucet Repair', 'Drips and running fixtures diagnosed and fixed.'],
    ['shower-door-installation-moon-township-pa.html', 'Shower Door Installation', 'New shower door as part of the same refresh.'],
  ],
},

'tv-mounting-moon-township-pa.html': {
  intro: 'Mounting a TV usually comes with a few other things in the same room.',
  items: [
    ['picture-hanging-moon-township-pa.html', 'Picture Hanging &amp; Art Installation', 'Art and mirrors hung level around the new mount.'],
    ['smart-home-installation-moon-township-pa.html', 'Smart Home Device Installation', 'Streaming devices, soundbars, and smart switches set up.'],
    ['outlet-switch-replacement-moon-township-pa.html', 'Outlet &amp; Switch Replacement', 'For adding a receptacle behind the TV instead of a visible cord.'],
    ['shelving-installation-moon-township-pa.html', 'Shelving Installation', 'Floating shelves under the TV for components.'],
    ['curtain-rods-blinds-installation-moon-township-pa.html', 'Curtain Rods &amp; Blinds', 'Cutting the glare on the wall opposite the window.'],
  ],
},

'window-screen-repair-moon-township-pa.html': {
  intro: 'Screen work is usually one item on a window-by-window pass around the house.',
  items: [
    ['storm-screen-door-repair-moon-township-pa.html', 'Storm &amp; Screen Door Repair', 'The door version of the same job &mdash; closers, latches, and screens.'],
    ['shutter-installation-moon-township-pa.html', 'Shutter Installation &amp; Replacement', 'Faded or missing shutters replaced on the same elevation.'],
    ['caulking-weatherproofing-moon-township-pa.html', 'Caulking &amp; Weatherproofing', 'Sealing around window frames while we are already there.'],
    ['siding-repair-moon-township-pa.html', 'Siding Repair', 'Damaged panels and trim around the windows.'],
  ],
},

};

const START = '  <!-- related-services:start -->';
const END = '  <!-- related-services:end -->';

function block(cfg) {
  const lis = cfg.items
    .map(([href, text, why]) => `        <li><a href="${href}">${text}</a> &mdash; ${why}</li>`)
    .join('\n');
  return [
    START,
    '  <div class="section">',
    '',
    '    <h2>Related Services</h2>',
    '',
    '    <p class="muted-center">',
    `      ${cfg.intro}`,
    '    </p>',
    '',
    '    <div class="box" style="margin-top:34px;">',
    '',
    '      <ul class="services-list">',
    lis,
    '      </ul>',
    '',
    '    </div>',
    '',
    '  </div>',
    END,
    '',
    '',
  ].join('\n');
}

let changed = 0;
for (const [file, cfg] of Object.entries(M)) {
  const p = path.join(ROOT, file);
  let html = fs.readFileSync(p, 'utf8');

  // strip a previous block so re-runs are idempotent
  const re = new RegExp(`${START}[\\s\\S]*?${END}\\r?\\n(\\r?\\n)?`, '');
  html = html.replace(re, '');

  const anchor = '  <div id="contact" class="section">';
  const i = html.indexOf(anchor);
  if (i === -1) { console.error('NO ANCHOR: ' + file); continue; }

  html = html.slice(0, i) + block(cfg) + html.slice(i);
  fs.writeFileSync(p, html);
  changed++;
}
console.log('updated ' + changed + ' pages');
