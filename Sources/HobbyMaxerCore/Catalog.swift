import Foundation

// Trait order in every entry: social, outdoor, active, handsOn, creative, structured (each 0...1).
private func h(_ name: String, _ emoji: String, _ tagline: String,
               _ t: (Double, Double, Double, Double, Double, Double),
               _ cost: Cost, _ time: TimeNeed, _ space: Space,
               _ goals: Set<Goal>, _ interests: [Interest],
               _ steps: [(String, String)]) -> Hobby {
    Hobby(name: name, emoji: emoji, tagline: tagline,
          traits: Traits(social: t.0, outdoor: t.1, active: t.2, handsOn: t.3, creative: t.4, structured: t.5),
          cost: cost, time: time, space: space, goals: goals, interests: interests,
          steps: steps.map { PlanStep(title: $0.0, detail: $0.1) })
}

public enum Catalog {
    public static let all: [Hobby] = [
        // MARK: Sports & movement
        h("Bouldering", "🧗", "Short, puzzle-like climbs on padded walls — no ropes, no partner needed.",
          (0.6, 0.1, 0.9, 0.7, 0.3, 0.7), .low, .moderate, .desk, [.challenge, .getFit, .meetPeople], [.sports], [
            ("Book an intro session", "Most climbing gyms run a one-hour beginner class with shoe rental for about $25–35."),
            ("Climb twice a week on easy grades", "Stick to the easiest problems (V0–V1) for a month, focus on footwork, and buy your own shoes once you're hooked (~$90)."),
            ("Send a V3 and join a meetup", "Most gyms have beginner nights or group chats — climbing with others helps you read routes and keeps you coming back."),
          ]),
        h("Pickleball", "🏓", "An easy-to-learn paddle sport played in friendly doubles.",
          (0.85, 0.6, 0.7, 0.4, 0.1, 0.5), .low, .light, .desk, [.meetPeople, .getFit, .relax], [.sports], [
            ("Drop in to open play", "Look up parks or rec centers with open play — many lend paddles, and regulars teach the rules in five minutes."),
            ("Get a paddle and learn the kitchen rule", "A $40–60 paddle is plenty. Watch one beginner video on dinking and the non-volley zone, then play twice a week."),
            ("Join a ladder or clinic", "Sign up for a beginner ladder or a 4-week clinic so you play people at your level and see your progress."),
          ]),
        h("Yoga", "🧘", "Stretch, breathe and build strength — at home or in a studio.",
          (0.3, 0.2, 0.5, 0.3, 0.2, 0.5), .free, .light, .desk, [.relax, .getFit], [.sports], [
            ("Do three 20-minute beginner sessions", "Pick one free beginner series online and follow it on a towel or cheap mat."),
            ("Take an in-person beginner class", "A teacher fixes alignment in ways video can't. Most studios offer an intro week for $20–40."),
            ("Build a three-times-a-week habit", "Settle on a style you like (vinyasa, yin, hatha), get a decent mat, and track your sessions."),
          ]),
        h("Brazilian Jiu-Jitsu", "🥋", "A grappling martial art that plays like physical chess.",
          (0.8, 0.0, 1.0, 0.6, 0.2, 0.9), .medium, .moderate, .desk, [.challenge, .getFit, .meetPeople], [.sports], [
            ("Take a free trial class", "Nearly every gym offers one. Wear athletic clothes without zippers; they'll loan you a gi."),
            ("Do two classes a week for a month", "Buy a gi ($60–100), stick to fundamentals classes, and tap early and often — nobody minds."),
            ("Roll at open mat and earn a stripe", "Open mats let you practice with different partners; a first belt stripe usually comes around month 2–4."),
          ]),
        h("Trail Running", "🏃", "Running, but on dirt paths through woods and hills.",
          (0.3, 1.0, 1.0, 0.2, 0.1, 0.4), .low, .moderate, .desk, [.getFit, .relax, .challenge], [.sports, .nature], [
            ("Walk-run a local trail", "Find an easy, well-marked trail and alternate two minutes running with one minute walking for 20–30 minutes."),
            ("Get trail shoes and run three times a week", "Trail shoes ($100–140) grip loose ground. Build to 30 minutes of easy running and walk hills without guilt."),
            ("Enter a 5K or 10K trail race", "Pick a beginner-friendly race 8–10 weeks out — a date on the calendar does wonders."),
          ]),
        h("Cycling", "🚴", "Explore miles of road or gravel under your own power.",
          (0.4, 1.0, 0.9, 0.4, 0.1, 0.5), .high, .moderate, .room, [.getFit, .relax, .challenge], [.sports, .nature], [
            ("Ride what you have, or rent", "Dust off any bike or rent one for an afternoon and ride a quiet 10-mile loop or bike path."),
            ("Get a bike that fits and learn basic repair", "Buy a used road or gravel bike that fits you ($400–900) plus a helmet, and learn to fix a flat."),
            ("Join a no-drop group ride", "Bike shops host weekly no-drop rides where nobody gets left behind — aim for 30 miles by month three."),
          ]),
        h("Swimming", "🏊", "Full-body, low-impact laps with a meditative rhythm.",
          (0.2, 0.3, 0.9, 0.1, 0.0, 0.6), .low, .moderate, .desk, [.getFit, .relax], [.sports], [
            ("Swim a 30-minute session", "Go during lap swim at a local pool, rest as much as you need, and count your lengths."),
            ("Fix your stroke", "Take a few adult lessons or a stroke clinic — breathing and body position are where the gains are."),
            ("Swim 1,000 meters without stopping", "Follow a simple beginner plan three times a week, or join a masters group for coaching and company."),
          ]),
        h("Salsa Dancing", "💃", "Partner dancing with great music and a social night out built in.",
          (0.95, 0.0, 0.8, 0.2, 0.6, 0.6), .low, .light, .desk, [.meetPeople, .getFit, .learn], [.performance, .music], [
            ("Go to a lesson before a social", "Many venues run a cheap 45-minute lesson right before the social dance. No partner needed — you rotate."),
            ("Take a 4-week fundamentals series", "Learn the basic step, cross-body lead and turns properly; practice footwork to music for 10 minutes a day."),
            ("Dance a full social night", "Go to a social and dance at least five songs. Everyone there was a beginner once."),
          ]),
        h("Archery", "🏹", "Focus, form and the satisfaction of hitting the center.",
          (0.3, 0.5, 0.4, 0.6, 0.1, 0.8), .medium, .light, .desk, [.relax, .challenge], [.sports], [
            ("Book an intro lesson at a range", "Indoor ranges rent equipment and run one-hour beginner sessions for about $30."),
            ("Practice form weekly", "Shoot weekly on rental gear and work on a consistent stance and anchor before buying a bow ($150–300)."),
            ("Shoot a scored round", "Join a beginner league or score a full round, then set a number to beat next month."),
          ]),
        h("Skateboarding", "🛹", "Learn to roll, carve and eventually pop your first ollie.",
          (0.5, 0.9, 0.8, 0.5, 0.6, 0.3), .low, .moderate, .desk, [.challenge, .getFit], [.sports], [
            ("Get a real board and pads", "A $70–120 complete from a skate shop beats a toy-store board. Add a helmet and wrist guards."),
            ("Practice pushing, turning and stopping", "Spend 20 minutes a day in a smooth parking lot until riding feels boring — then you're ready for tricks."),
            ("Land an ollie and visit a skatepark", "Go during quiet morning hours, watch the etiquette, and make the ollie your month-three goal."),
          ]),
        h("Rec Sports League", "⚽", "Casual adult teams — kickball, soccer, volleyball and more.",
          (1.0, 0.8, 0.8, 0.2, 0.0, 0.5), .low, .light, .desk, [.meetPeople, .getFit], [.sports], [
            ("Find a league that takes free agents", "Search for adult social leagues in your city; most let you sign up solo and place you on a team."),
            ("Play a full season", "Seasons run 6–10 weeks with one game a week — show up, go to the post-game hangout, learn names."),
            ("Re-up with your favorite people", "Join the players you liked for next season, or bring friends and captain your own team."),
          ]),

        // MARK: Nature
        h("Hiking", "🥾", "Walk somewhere beautiful and let your head clear.",
          (0.4, 1.0, 0.6, 0.1, 0.1, 0.3), .free, .light, .desk, [.relax, .getFit], [.nature], [
            ("Do a 3–5 mile marked trail", "Pick a well-rated easy trail nearby, bring water and a snack, and tell someone where you're going."),
            ("Get proper shoes and a daypack", "That's all the gear you need. Hike every other weekend and gradually add elevation."),
            ("Complete a 10-mile or summit hike", "Choose a signature hike in your region as a goal, or join a hiking club's group outing."),
          ]),
        h("Kayaking", "🛶", "Paddle calm lakes and rivers at water level.",
          (0.4, 1.0, 0.6, 0.3, 0.1, 0.4), .medium, .light, .desk, [.relax, .getFit], [.nature, .sports], [
            ("Rent a kayak for two hours", "Lakes and rivers often have rental shacks — pick a calm, sheltered day and wear the life vest."),
            ("Take a basic paddling course", "Learn strokes, steering and how to get back in after a capsize in a half-day course."),
            ("Paddle a longer route or join a club", "Plan a half-day trip, or join a paddling club for group outings and boats before you buy your own."),
          ]),
        h("Birdwatching", "🐦", "Learn to spot and name the birds that are already around you.",
          (0.2, 0.9, 0.2, 0.0, 0.1, 0.6), .free, .light, .desk, [.relax, .learn], [.nature, .animals], [
            ("Install Merlin and take a walk", "The free Merlin Bird ID app identifies birds by sound. Walk a park for 30 minutes and see what it hears."),
            ("Get binoculars and keep a list", "Basic 8x42 binoculars (~$100) change everything. Log sightings in eBird and learn your 20 most common birds."),
            ("Join a local bird walk", "Audubon chapters and nature centers run free guided walks — experienced birders teach tricks no app can."),
          ]),
        h("Container Gardening", "🌱", "Grow herbs, vegetables and flowers in pots — even on a balcony.",
          (0.1, 0.6, 0.3, 0.8, 0.4, 0.4), .free, .light, .desk, [.relax, .makeThings], [.nature, .food], [
            ("Pot three easy herbs", "Basil, mint and chives in a sunny window or balcony — pots, soil and starts cost about $20."),
            ("Plan a small container garden", "Learn your growing zone and sun hours, then add tomatoes, lettuce or peppers in bigger pots."),
            ("Cook something you grew", "Aim for one homegrown meal by month three, and swap seeds and cuttings with a local gardening group."),
          ]),
        h("Foraging", "🍄", "Find wild edibles on walks — mushrooms, berries and greens.",
          (0.3, 1.0, 0.4, 0.4, 0.1, 0.6), .free, .light, .desk, [.learn, .relax], [.nature, .food], [
            ("Learn three foolproof plants", "Start with easy, no-lookalike plants in your area (blackberries, dandelion) using a regional field guide."),
            ("Go on a guided foraging walk", "Naturalists and mushroom societies run walks — the safest way to learn. Never eat anything you're not certain of."),
            ("Cook a foraged meal", "Keep a journal of finds and seasons, and cook one dish from something an expert has confirmed."),
          ]),
        h("Stargazing", "🔭", "Find planets, galaxies and constellations from your backyard.",
          (0.2, 0.8, 0.0, 0.3, 0.1, 0.6), .free, .light, .desk, [.relax, .learn], [.science, .nature], [
            ("Learn five constellations", "Use a free sky app on a clear night to find Orion, the Big Dipper, Cassiopeia and more."),
            ("Point binoculars at the Moon and planets", "Ordinary binoculars show lunar craters and Jupiter's moons. Learn to read a monthly sky chart."),
            ("Go to a star party", "Astronomy clubs host free public nights where you can look through big telescopes before buying one."),
          ]),
        h("Fly Fishing", "🎣", "An elegant, absorbing way to fish rivers and streams.",
          (0.2, 1.0, 0.4, 0.7, 0.2, 0.7), .medium, .moderate, .desk, [.relax, .challenge], [.nature, .sports], [
            ("Take a casting lesson", "Fly shops often run free or cheap casting clinics on a lawn — no license needed to practice."),
            ("Get a starter setup and license", "A beginner rod and reel ($150–250) plus a fishing license. Practice casting 15 minutes a day."),
            ("Catch your first fish on a guided trip", "A half-day guided trip on an easy river teaches you to read water — and you'll likely land a trout."),
          ]),
        h("Geocaching", "🗺️", "A real-world treasure hunt using GPS and hidden containers.",
          (0.3, 0.9, 0.4, 0.3, 0.1, 0.4), .free, .light, .desk, [.relax, .challenge], [.nature, .games], [
            ("Find your first three caches", "Install the free Geocaching app and look for easy traditional caches near you."),
            ("Try harder cache types", "Move on to multi-caches and puzzle caches, and carry small trinkets to trade."),
            ("Hide your own cache", "After about 20 finds, hide one in a spot you love and go to a local geocaching event."),
          ]),
        h("Bonsai", "🌳", "Shape living miniature trees over seasons and years.",
          (0.1, 0.4, 0.1, 0.8, 0.7, 0.6), .free, .light, .desk, [.relax, .makeThings, .learn], [.nature, .art], [
            ("Buy a nursery juniper or ficus", "Skip mall bonsai. A $15–30 nursery shrub is the classic starter — learn its watering and light needs."),
            ("Do your first styling", "Get basic shears and wire, watch a styling demo, then prune and wire your tree into a simple shape."),
            ("Join a bonsai club workshop", "Clubs run hands-on workshops where experienced members guide you — invaluable at repotting time."),
          ]),
        h("Beekeeping", "🐝", "Keep a hive, help pollinators and harvest your own honey.",
          (0.3, 1.0, 0.4, 0.8, 0.1, 0.7), .high, .moderate, .workshop, [.learn, .makeThings], [.animals, .nature], [
            ("Visit a local beekeepers' association", "Go to a meeting or open-hive day — many pair new keepers with mentors and run winter courses."),
            ("Take a course and check local rules", "Learn hive biology, confirm zoning rules, and order a hive, suit and bees ($500–800) for spring."),
            ("Install your first colony", "Install bees in spring with your mentor nearby and inspect weekly; first honey usually comes in year two."),
          ]),
        h("Aquascaping", "🐠", "Design planted underwater landscapes in a fish tank.",
          (0.1, 0.0, 0.1, 0.8, 0.8, 0.6), .medium, .light, .room, [.relax, .makeThings], [.animals, .art, .nature], [
            ("Study scapes you love", "Browse aquascaping galleries, pick a style, and visit a local fish store to see planted tanks."),
            ("Set up a small planted tank", "A 10–20 gallon tank, light, filter, substrate and easy plants ($150–300). Let it cycle 4–6 weeks before fish."),
            ("Add fish and refine", "Add hardy fish or shrimp, trim and rearrange plants, and post your scape to a forum for feedback."),
          ]),

        // MARK: Food & drink
        h("Sourdough Baking", "🍞", "Bake crackly, chewy bread from wild yeast you keep alive.",
          (0.1, 0.0, 0.2, 0.9, 0.5, 0.7), .free, .moderate, .desk, [.makeThings, .relax, .learn], [.food], [
            ("Start a starter", "Mix flour and water in a jar and feed it daily for 7–10 days until it doubles reliably."),
            ("Bake a basic loaf every weekend", "Follow one well-tested beginner recipe exactly, bake in a Dutch oven, and take notes each time."),
            ("Nail an open crumb, then share", "Aim for a loaf with good rise and open crumb, and give one away — or share some starter."),
          ]),
        h("Fermentation", "🫙", "Make kimchi, sauerkraut, kombucha and hot sauce.",
          (0.1, 0.0, 0.1, 0.8, 0.5, 0.6), .free, .light, .desk, [.makeThings, .learn], [.food, .science], [
            ("Make a jar of sauerkraut", "Just cabbage and salt in a jar — about $5. Taste it every few days."),
            ("Branch out to three ferments", "Try kimchi, pickles and kombucha. A kitchen scale and airlock lids make it easy."),
            ("Invent your own recipe", "Create a hot sauce or kraut flavor, serve it at a meal, and swap jars with friends."),
          ]),
        h("Cooking World Cuisines", "🍳", "Cook your way around the world, one cuisine at a time.",
          (0.4, 0.0, 0.2, 0.8, 0.7, 0.5), .low, .moderate, .desk, [.makeThings, .learn, .meetPeople], [.food], [
            ("Pick a cuisine and cook one dish", "Choose a cuisine you love eating, find a trusted recipe, and shop a specialty grocery for ingredients."),
            ("Master five dishes and the pantry", "Cook from one good cookbook for a month and learn its core techniques and staples."),
            ("Host a themed dinner", "Invite friends for a full meal from that cuisine — then pick your next one."),
          ]),
        h("Home Coffee", "☕", "Dial in pour-overs and espresso like a café.",
          (0.1, 0.0, 0.1, 0.7, 0.3, 0.8), .medium, .light, .desk, [.learn, .relax, .makeThings], [.food, .science], [
            ("Buy fresh beans and try a pour-over", "A $20 pour-over cone and fresh beans from a local roaster beat most café drip."),
            ("Get a burr grinder and weigh everything", "A decent grinder ($100–150) and scale let you experiment with ratio, grind and temperature."),
            ("Taste side by side", "Cup three origins together, then decide whether to go deeper into espresso or roasting."),
          ]),
        h("Homebrewing", "🍺", "Brew your own beer or cider from scratch.",
          (0.3, 0.0, 0.2, 0.8, 0.5, 0.8), .low, .moderate, .room, [.makeThings, .learn, .meetPeople], [.food, .science], [
            ("Brew a one-gallon kit", "A 1-gallon kit (~$50) fits on a stovetop and teaches sanitation and fermentation."),
            ("Bottle it and brew batch two", "Bottle your first batch after two weeks, then brew a different style and compare."),
            ("Share at a homebrew club", "Bring bottles to a homebrew club for honest feedback, or enter a beginner competition."),
          ]),

        // MARK: Art
        h("Watercolor Painting", "🎨", "Loose, luminous paintings with just water and pigment.",
          (0.1, 0.2, 0.0, 0.6, 1.0, 0.3), .low, .light, .desk, [.relax, .makeThings], [.art], [
            ("Paint with a starter set", "A student pan set, two brushes and real watercolor paper cost about $30. Follow one beginner tutorial."),
            ("Practice washes, then paint daily", "Spend two weeks on washes, gradients and layering, then paint one small subject a day."),
            ("Finish a series and share it", "Paint five on a theme (your street, plants, mugs) and post them or join a local art group."),
          ]),
        h("Urban Sketching", "✏️", "Draw the world around you, on location, in a pocket sketchbook.",
          (0.4, 0.7, 0.2, 0.5, 0.9, 0.2), .free, .light, .desk, [.relax, .makeThings, .meetPeople], [.art], [
            ("Fill five pages at a café", "A pocket sketchbook and a pen. Draw what's in front of you for 15 minutes — wobbly lines are the point."),
            ("Learn basic perspective", "Learn one- and two-point perspective, and add a water brush or a few markers for color."),
            ("Join an Urban Sketchers meetup", "Urban Sketchers groups meet worldwide to draw together and share sketchbooks — free and welcoming."),
          ]),
        h("Pottery", "🏺", "Throw bowls and mugs on the wheel and glaze them yourself.",
          (0.5, 0.0, 0.3, 1.0, 0.8, 0.6), .medium, .moderate, .desk, [.makeThings, .relax, .learn], [.crafts, .art], [
            ("Take a one-night wheel class", "Studios run taster sessions for about $40–60 — you'll get your hands in clay right away."),
            ("Sign up for a 6–8 week course", "Courses include clay, glazes, firing and studio time ($250–400). Expect a lot of collapsed pots at first."),
            ("Make a matching set of four", "Aim for four mugs or bowls that roughly match — then look into a studio membership."),
          ]),
        h("Calligraphy", "🖋️", "Turn handwriting into art with brush pens or a dip nib.",
          (0.1, 0.0, 0.0, 0.7, 0.8, 0.8), .free, .light, .desk, [.relax, .makeThings, .learn], [.art, .words], [
            ("Practice drills with a brush pen", "One brush pen (~$5) and printer paper: learn thin upstrokes and thick downstrokes."),
            ("Work through a full alphabet", "Follow practice sheets for a lowercase alphabet in one style, 15 minutes a day."),
            ("Letter a real piece", "Make a card, a quote print or place cards for an event — real use makes it stick."),
          ]),
        h("Photography", "📷", "Learn to see light and composition — with your phone or a camera.",
          (0.3, 0.7, 0.3, 0.4, 0.9, 0.5), .free, .light, .desk, [.makeThings, .learn], [.art, .tech], [
            ("Shoot one deliberate photo a day", "Use your phone's manual mode and take one considered photo every day for a week."),
            ("Learn the exposure triangle", "Understand aperture, shutter speed and ISO; if you're hooked, a used mirrorless camera runs $300–500."),
            ("Complete a themed project", "Shoot a 10-photo series, edit it consistently, and join a photo walk or critique group."),
          ]),
        h("Digital Illustration", "🖌️", "Draw and paint on a tablet with unlimited undo.",
          (0.1, 0.0, 0.0, 0.3, 1.0, 0.4), .low, .moderate, .desk, [.makeThings, .learn], [.art, .tech], [
            ("Draw with what you have", "Try a free app like Krita (or Procreate on an iPad) and copy a simple illustration you like."),
            ("Learn fundamentals with a course", "Follow a beginner course on shapes, values and color. A pen tablet starts around $60."),
            ("Finish three polished pieces", "Take three illustrations start to finish and post them, or join a weekly drawing challenge."),
          ]),
        h("Linocut Printmaking", "🖼️", "Carve designs into blocks and print them by hand.",
          (0.2, 0.0, 0.1, 0.9, 0.9, 0.5), .low, .light, .desk, [.makeThings, .relax], [.art, .crafts], [
            ("Carve a simple block", "A starter kit with lino, cutters, ink and a roller is about $30. Carve a bold, simple shape."),
            ("Print an edition of ten", "Print ten copies on decent paper, experimenting with pressure and ink thickness."),
            ("Make a two-color print", "Learn registration for a two-color design, then make cards or posters to give away or sell."),
          ]),

        // MARK: Crafts
        h("Knitting", "🧶", "Make cozy things with two needles and a ball of yarn.",
          (0.3, 0.0, 0.0, 0.9, 0.6, 0.7), .free, .light, .desk, [.relax, .makeThings], [.crafts], [
            ("Cast on and knit a square", "Medium-weight yarn and size 8 needles (~$15) plus a beginner video is all you need."),
            ("Knit a scarf or hat", "Learn purling and ribbing, then finish your first wearable project."),
            ("Join a knitting circle", "Yarn shops and libraries host knit nights — bring your project and learn your next technique there."),
          ]),
        h("Woodworking", "🪚", "Build furniture and useful objects with your own hands.",
          (0.2, 0.1, 0.5, 1.0, 0.6, 0.7), .high, .heavy, .workshop, [.makeThings, .challenge, .learn], [.crafts], [
            ("Take an intro class at a makerspace", "Makerspaces and community colleges run intro classes with safety training and tool access."),
            ("Build a box or cutting board", "Start with a simple project — measure twice, cut once, finish with oil."),
            ("Build a small piece of furniture", "A step stool, bookshelf or side table — then decide which tools are worth owning."),
          ]),
        h("Leathercraft", "👜", "Hand-stitch wallets, belts and bags that last for decades.",
          (0.1, 0.0, 0.1, 1.0, 0.6, 0.7), .low, .light, .desk, [.makeThings, .learn], [.crafts], [
            ("Make a card wallet from a kit", "A beginner kit with pre-cut leather and tools runs $40–60 and teaches saddle stitching."),
            ("Learn edge finishing and patterns", "Get a few tools and veg-tan leather; practice burnishing edges and cutting your own patterns."),
            ("Design an original piece", "Design and make a belt, watch strap or small bag from scratch — a great gift."),
          ]),
        h("Sewing", "🧵", "Make and alter your own clothes, exactly how you like them.",
          (0.2, 0.0, 0.1, 0.9, 0.8, 0.6), .medium, .moderate, .room, [.makeThings, .learn], [.crafts, .art], [
            ("Fix something you own", "Borrow or buy a basic machine and hem trousers, replace a button or take in a shirt."),
            ("Sew a beginner pattern", "Pick a pattern labelled beginner (tote bag, pajama pants) and learn to cut, pin and press."),
            ("Make a garment you'll wear", "Sew a simple top or skirt you actually wear out — then take a fit class at a sewing studio."),
          ]),
        h("Embroidery", "🪡", "Paint with thread — patches, hoops and custom clothes.",
          (0.1, 0.0, 0.0, 0.9, 0.9, 0.4), .free, .light, .desk, [.relax, .makeThings], [.crafts, .art], [
            ("Stitch a sampler", "A hoop, needles, floss and cotton (~$15). Learn back stitch, satin stitch and French knots."),
            ("Complete a printed pattern", "Follow a beginner pattern start to finish and frame it in its hoop."),
            ("Embroider something you wear", "Add your own design to a jacket, tote or shirt."),
          ]),
        h("Bookbinding", "📚", "Hand-make journals and books that open flat.",
          (0.1, 0.0, 0.0, 0.9, 0.6, 0.8), .free, .light, .desk, [.makeThings, .relax], [.crafts, .words], [
            ("Make a stitched notebook", "Paper, an awl, waxed thread and a needle — under $20 — make a simple pamphlet-stitch notebook."),
            ("Try coptic and case binding", "Learn two classic bindings and how to cover boards with cloth or paper."),
            ("Bind a full hardcover book", "Bind a hardcover journal as a gift, or rebind a beloved paperback."),
          ]),
        h("Miniature Painting", "🐉", "Paint tiny fantasy figures in astonishing detail.",
          (0.3, 0.0, 0.0, 0.8, 0.8, 0.7), .low, .light, .desk, [.relax, .makeThings], [.crafts, .games, .art], [
            ("Paint one starter mini", "A starter set with minis, paints and a brush is $30–50. Prime, base coat and wash."),
            ("Learn layering and highlighting", "Paint a small squad, practicing one technique each: drybrushing, layering, edge highlights."),
            ("Paint a display piece", "Finish one mini with a detailed base, or bring a painted team to a local game night."),
          ]),
        h("Origami", "🦢", "Fold a single square of paper into almost anything.",
          (0.0, 0.0, 0.0, 0.8, 0.6, 0.9), .free, .light, .desk, [.relax, .challenge], [.crafts, .art], [
            ("Fold five classic models", "Crane, jumping frog, box, boat and lily — printer paper cut square works fine."),
            ("Get origami paper and learn diagrams", "A pack of origami paper (~$10) and a beginner book; learn to read folding notation."),
            ("Fold an intermediate model", "Take on a modular or complex model like a kusudama or dragon, and gift a few."),
          ]),

        // MARK: Music & performing
        h("Guitar", "🎸", "Strum songs you love within weeks.",
          (0.3, 0.0, 0.1, 0.8, 0.7, 0.6), .medium, .moderate, .desk, [.learn, .makeThings, .challenge], [.music], [
            ("Learn four chords", "Borrow or buy a beginner acoustic (~$150) and learn G, C, D and Em — they cover hundreds of songs."),
            ("Practice 15 minutes a day", "Follow a structured beginner course (many are free) for chord changes and strumming patterns."),
            ("Play a full song for someone", "Play one complete song start to finish for a friend — or at an open mic."),
          ]),
        h("Piano", "🎹", "Learn chords, melodies and the foundations of all music.",
          (0.2, 0.0, 0.0, 0.7, 0.6, 0.8), .medium, .moderate, .room, [.learn, .challenge, .relax], [.music], [
            ("Try an app on a keyboard", "A used 61-key keyboard ($80–150) plus a learning app gets you playing simple melodies."),
            ("Learn to read basic notation", "Spend a month on treble and bass clef, hand independence and simple chords."),
            ("Play a full piece", "Learn one beginner piece end to end — a few lessons early on will fix technique."),
          ]),
        h("Choir Singing", "🎤", "Sing with others — no solo pressure, one big shared sound.",
          (0.95, 0.0, 0.2, 0.1, 0.6, 0.7), .free, .light, .desk, [.meetPeople, .learn, .relax], [.music, .performance], [
            ("Find a no-audition community choir", "Many community choirs welcome anyone. Go to an open rehearsal — they'll place you in a section."),
            ("Learn your part", "Practice with rehearsal tracks during the week and learn basic breathing and posture."),
            ("Sing in a concert", "Perform in the end-of-term concert — the moment it all comes together."),
          ]),
        h("DJing", "🎧", "Blend tracks together and read a room.",
          (0.6, 0.0, 0.3, 0.6, 0.7, 0.5), .medium, .moderate, .desk, [.makeThings, .meetPeople], [.music, .tech], [
            ("Mix in free software", "Try free DJ software on your laptop and learn to beatmatch two tracks."),
            ("Get a controller and build a crate", "A beginner two-channel controller ($150–250) and a library of tracks sorted by energy and tempo."),
            ("Play a 30-minute set for people", "Record a mix, then play for friends or at a local open-decks night."),
          ]),
        h("Music Production", "🎛️", "Make your own tracks on a laptop.",
          (0.1, 0.0, 0.0, 0.4, 1.0, 0.4), .free, .moderate, .desk, [.makeThings, .learn], [.music, .tech], [
            ("Make a loop in GarageBand", "GarageBand is free on your Mac — follow a beginner tutorial and make an 8-bar loop."),
            ("Learn arrangement and mixing basics", "Recreate a song you love to understand its structure, then learn EQ and compression."),
            ("Release a finished track", "Finish a 2–3 minute track and share it — finishing is the real skill."),
          ]),
        h("Improv Comedy", "🎭", "Make up scenes on the spot — and get braver everywhere.",
          (1.0, 0.0, 0.5, 0.0, 0.9, 0.4), .low, .light, .desk, [.meetPeople, .challenge], [.performance], [
            ("Take a drop-in workshop", "Improv theaters run cheap drop-in classes for total beginners. It's mostly games and laughing."),
            ("Sign up for a Level 1 course", "A 6–8 week course ($200–350) teaches yes-and, listening and building scenes."),
            ("Perform in a class show", "Most courses end in a low-stakes showcase for friends — then join a jam or practice group."),
          ]),
        h("Community Theater", "🎬", "Act, build sets or run lights for local productions.",
          (1.0, 0.0, 0.4, 0.3, 0.8, 0.6), .free, .moderate, .desk, [.meetPeople, .makeThings], [.performance], [
            ("See a show and ask to volunteer", "Crew is always needed and is the easiest way in."),
            ("Audition or join a crew", "Audition for a small role, or join set building, props or lighting for the next show."),
            ("Be part of opening night", "See a production through rehearsals to opening night — the cast party is the reward."),
          ]),
        h("Card Magic", "🃏", "Learn sleight of hand and amaze people up close.",
          (0.5, 0.0, 0.0, 0.6, 0.6, 0.7), .free, .light, .desk, [.challenge, .learn, .meetPeople], [.performance], [
            ("Learn three self-working tricks", "A standard deck and a beginner book or video — self-working tricks need no sleight of hand."),
            ("Practice one sleight daily", "Learn a double lift and a basic control in front of a mirror, 10 minutes a day."),
            ("Perform a five-minute routine", "Put three tricks into a short routine and perform it for friends — then visit a magic club."),
          ]),

        // MARK: Words
        h("Creative Writing", "✍️", "Write short stories, essays or poetry.",
          (0.1, 0.0, 0.0, 0.1, 1.0, 0.3), .free, .light, .desk, [.makeThings, .relax], [.words], [
            ("Write three 500-word pieces", "Use a prompt and write a little each day — don't edit, just finish."),
            ("Read like a writer, then draft a story", "Read short stories in your genre, then write and revise one 2,000-word story."),
            ("Share it with a writing group", "Join a critique group, or submit to a small magazine or contest."),
          ]),
        h("Learning a Language", "🗣️", "Pick up a new language and a new way of seeing.",
          (0.5, 0.0, 0.0, 0.1, 0.3, 0.8), .free, .moderate, .desk, [.learn, .challenge, .meetPeople], [.words], [
            ("Do 15 minutes a day", "Start an app streak and learn greetings and your first 100 common words."),
            ("Add a course and easy listening", "Work through a structured course and watch easy shows or videos in the language."),
            ("Have a real conversation", "Book a tutor session or go to a language exchange and speak for 20 minutes."),
          ]),
        h("Book Club", "📖", "Read more and talk about it with interesting people.",
          (0.8, 0.0, 0.0, 0.0, 0.3, 0.4), .free, .light, .desk, [.meetPeople, .relax, .learn], [.words], [
            ("Find a club at a library or bookstore", "Libraries and bookstores host free monthly clubs — find the next pick and get a copy."),
            ("Read it and show up", "Jot a few notes on what you liked and didn't, and go to the meeting."),
            ("Pick a book, or start your own club", "After three meetings, suggest a book — or start a club with friends around a theme you love."),
          ]),
        h("Podcasting", "🎙️", "Talk about what you love and publish it to the world.",
          (0.5, 0.0, 0.0, 0.3, 0.8, 0.5), .low, .moderate, .desk, [.makeThings, .learn, .meetPeople], [.words, .tech], [
            ("Record a 10-minute pilot", "Use your phone or a USB mic and record yourself, or with a friend, on a topic you care about."),
            ("Learn basic editing and pick a format", "Edit in a free tool like GarageBand, settle on a format, and record three episodes."),
            ("Publish your first three episodes", "Upload to a free host that sends episodes to Apple Podcasts and Spotify, and share them."),
          ]),

        // MARK: Games & puzzles
        h("Chess", "♟️", "Endless strategy on 64 squares.",
          (0.4, 0.0, 0.0, 0.0, 0.1, 0.9), .free, .light, .desk, [.challenge, .learn], [.games], [
            ("Play 10 games online", "Make a free account on Lichess or Chess.com and play 10-minute games against people at your level."),
            ("Do daily puzzles and learn openings", "Solve 10 tactics puzzles a day and learn one opening each for white and black."),
            ("Go to a chess club night", "Clubs and cafés host casual nights — play over the board and watch your rating climb."),
          ]),
        h("Board Game Nights", "🎲", "Modern tabletop games with friends — strategy, co-op and party.",
          (0.9, 0.0, 0.0, 0.2, 0.2, 0.6), .low, .light, .desk, [.meetPeople, .relax, .challenge], [.games], [
            ("Visit a board game café", "Cafés have big libraries and staff who'll teach you. Try three different kinds of game."),
            ("Buy a gateway game and host", "Pick up a great gateway game (Ticket to Ride, Cascadia, Codenames) and host a night."),
            ("Join a regular game group", "Find a local meetup or library game night and become a regular."),
          ]),
        h("Tabletop Roleplaying", "🧙", "Collaborative storytelling games like Dungeons & Dragons.",
          (0.9, 0.0, 0.0, 0.1, 0.9, 0.4), .free, .light, .desk, [.meetPeople, .makeThings], [.games, .words], [
            ("Play a one-shot", "Game stores and online groups run beginner one-shots with ready-made characters."),
            ("Join a campaign", "Join a weekly or biweekly group and build your own character with the free basic rules."),
            ("Run a one-shot yourself", "Run a short pre-written adventure for friends — game-mastering is where the creativity kicks in."),
          ]),
        h("Speedcubing", "🧩", "Solve a Rubik's Cube — then do it faster and faster.",
          (0.2, 0.0, 0.0, 0.5, 0.0, 1.0), .free, .light, .desk, [.challenge, .learn], [.games], [
            ("Solve it once with the beginner method", "Buy a modern speedcube ($10–15) and follow a layer-by-layer beginner tutorial."),
            ("Solve it without notes", "Memorize the beginner method and time yourself every day."),
            ("Get under one minute", "Learn the basic CFOP steps, aim for sub-60 seconds, and look up a local competition."),
          ]),

        // MARK: Tech & science
        h("Electronics & Arduino", "🔌", "Build blinking, beeping, sensing gadgets.",
          (0.1, 0.0, 0.0, 0.8, 0.5, 0.7), .low, .moderate, .desk, [.makeThings, .learn, .challenge], [.tech, .science], [
            ("Blink an LED", "An Arduino starter kit (~$40) and its first tutorial: wire an LED and make it blink."),
            ("Work through the kit projects", "Build the sensor, motor and display projects and learn basic circuits and code."),
            ("Build something useful", "Design your own project — a plant-watering alert or a weather display — and show it at a makerspace."),
          ]),
        h("Game Development", "👾", "Make your own video games.",
          (0.1, 0.0, 0.0, 0.1, 0.9, 0.6), .free, .heavy, .desk, [.makeThings, .learn, .challenge], [.tech, .games], [
            ("Follow a beginner tutorial", "Install a free engine (Godot is friendly) and make a tiny game following a tutorial."),
            ("Clone a classic", "Recreate Pong or Flappy Bird yourself to learn the game loop, input and collisions."),
            ("Ship a game in a game jam", "Join an online game jam and finish a small game in a weekend."),
          ]),
        h("3D Printing", "🖨️", "Design and print real objects at home.",
          (0.1, 0.0, 0.0, 0.7, 0.7, 0.6), .medium, .light, .desk, [.makeThings, .learn], [.tech, .crafts], [
            ("Print something at a library or makerspace", "Many offer printing — download a model from a site like Printables and print it."),
            ("Get a printer and learn slicing", "A reliable beginner printer is $200–350; learn slicer settings and calibration."),
            ("Design your own part", "Learn basic CAD (Tinkercad is free) and print something that solves a real problem at home."),
          ]),
        h("Mechanical Keyboards", "⌨️", "Build a keyboard that sounds and feels exactly how you like.",
          (0.1, 0.0, 0.0, 0.8, 0.6, 0.6), .medium, .light, .desk, [.makeThings, .learn], [.tech, .crafts], [
            ("Try switches with a tester", "A $10–15 switch tester shows the difference between linear, tactile and clicky."),
            ("Build a hot-swap kit", "A hot-swappable kit needs no soldering ($100–200) — assemble it with switches and keycaps you chose."),
            ("Mod or solder your next board", "Lube switches, add foam, or solder a kit — and share it with a keyboard community."),
          ]),
        h("Ham Radio", "📻", "Talk across town or across the world on amateur radio.",
          (0.4, 0.3, 0.0, 0.6, 0.1, 0.9), .low, .moderate, .desk, [.learn, .meetPeople, .challenge], [.tech, .science], [
            ("Listen in first", "Use a free online web SDR or a cheap receiver to hear hams before getting licensed."),
            ("Study for your license", "Use a free practice-exam site to prepare for the entry-level license test."),
            ("Get licensed and make a contact", "Take the exam at a local club, get a handheld radio, and check in to a local net."),
          ]),

        // MARK: Animals & community
        h("Shelter Volunteering", "🐶", "Walk dogs, socialize cats and help animals get adopted.",
          (0.6, 0.4, 0.4, 0.6, 0.1, 0.5), .free, .light, .desk, [.meetPeople, .relax], [.animals], [
            ("Sign up for a volunteer orientation", "Most shelters require a short orientation — sign up online."),
            ("Commit to a weekly shift", "Pick one regular two-hour slot walking dogs or socializing cats."),
            ("Take on a bigger role", "Foster an animal, help at adoption events, or photograph animals for their adoption profiles."),
          ]),
    ]
}
