/// Editorial "design story" — a real-feeling home makeover used on the home
/// screen. Prototype content written in-house.
class StorySection {
  final String heading;
  final String body;
  const StorySection(this.heading, this.body);
}

class DesignStory {
  final String id;
  final String image;
  final String tag;
  final String title;
  final String subtitle;
  final String meta;
  final String author;
  final String room; // project room the materials map to
  final String budget;
  final String area;
  final String carbonCut;
  final String intro;
  final List<StorySection> sections;
  final String quote;
  final String quoteBy;
  final List<(String before, String after)> changes;
  final List<String> materialIds;
  final List<String> plantIds;

  const DesignStory({
    required this.id,
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.author,
    required this.room,
    required this.budget,
    required this.area,
    required this.carbonCut,
    required this.intro,
    required this.sections,
    required this.quote,
    required this.quoteBy,
    required this.changes,
    required this.materialIds,
    required this.plantIds,
  });
}

const designStories = <DesignStory>[
  DesignStory(
    id: 'delhi-breathing-flat',
    image: 'assets/images/hero-living.jpg',
    tag: 'Living room · Delhi',
    title: 'A Delhi flat that breathes with the seasons',
    subtitle: 'Bamboo floors, lime walls and 14 air-purifying plants for 620 sqft.',
    meta: '8 min read',
    author: 'Words by the Vana studio',
    room: 'Living room',
    budget: '₹4.2L',
    area: '620 sqft',
    carbonCut: '−38%',
    intro:
        'Ananya and Rohit bought a 1990s DDA flat in Saket with sealed windows, vitrified tiles and walls '
        'that sweated every monsoon. They wanted a home that stayed cool in May, dry in August and did not '
        'need an air purifier running all winter.',
    sections: [
      StorySection(
        'Start with the walls',
        'The acrylic emulsion came off first. Two coats of hand-trowelled lime plaster went on instead — it '
            'pulls moisture out of the air when it is humid and releases it when it is dry. By the second '
            'monsoon the musty corner behind the sofa had simply stopped smelling.',
      ),
      StorySection(
        'A floor you can walk on barefoot',
        'Strand-woven bamboo was laid straight over the old tiles on a cork underlay, so there was no '
            'demolition debris to cart away. It is harder than oak, warm underfoot in January and was '
            'refinished in a weekend after a year of dog claws.',
      ),
      StorySection(
        'Plants as infrastructure',
        'Fourteen plants are placed where air stalls: areca palms by the balcony door, snake plants in the '
            'bedroom corners, a monstera where the old AC used to drip. During the November smog the indoor '
            'PM2.5 reading sat 40% lower than the flat next door.',
      ),
      StorySection(
        'What they would do differently',
        'Order lime early — skilled plasterers are booked months ahead in winter — and budget for a second '
            'sealing coat on the bamboo near the kitchen.',
      ),
    ],
    quote: 'We stopped noticing the house. It just feels like good weather indoors.',
    quoteBy: 'Ananya, homeowner',
    changes: [
      ('Vitrified tiles, cold in winter', 'Strand-woven bamboo on cork underlay'),
      ('Acrylic emulsion, peeling each monsoon', 'Breathable lime plaster'),
      ('Air purifier running 10 hrs a day', '14 plants, purifier off most days'),
    ],
    materialIds: ['strand-bamboo', 'lime-plaster', 'reclaimed-teak'],
    plantIds: ['areca-palm', 'snake-plant', 'monstera'],
  ),
  DesignStory(
    id: 'pune-teak-bedroom',
    image: 'assets/images/story-bedroom.jpg',
    tag: 'Bedroom · Pune',
    title: 'The 100-year-old teak bed that anchors a modern room',
    subtitle: 'One heirloom, lime walls and a single snake plant — nothing new that did not need to be.',
    meta: '6 min read',
    author: 'Words by the Vana studio',
    room: 'Bedroom',
    budget: '₹1.6L',
    area: '160 sqft',
    carbonCut: '−52%',
    intro:
        'When Meera inherited her grandmother\'s teak four-poster from a wada in Satara, it was too big for '
        'every room in her Baner apartment. Instead of cutting it down, she designed the bedroom around it.',
    sections: [
      StorySection(
        'Let the heirloom lead',
        'The bed was stripped by hand, the joints re-pegged and the posts shortened by 20 cm using offcuts '
            'from the same timber. Everything else in the room was chosen to step back from it.',
      ),
      StorySection(
        'Quiet, breathable walls',
        'Warm off-white lime plaster replaced gypsum and emulsion. There is nothing to off-gas near the '
            'pillow, and the soft texture catches the evening light the way old wada walls did.',
      ),
      StorySection(
        'A bedroom plant that works at night',
        'A snake plant sits in the darkest corner. It releases oxygen after dark and needs water only '
            'twice a month — ideal for someone who travels for work.',
      ),
    ],
    quote: 'It is the oldest thing I own and it makes the room feel brand new.',
    quoteBy: 'Meera, homeowner',
    changes: [
      ('Storage bed in HDF laminate', 'Restored 100-year-old teak four-poster'),
      ('Gypsum board + emulsion', 'Lime plaster, zero VOC'),
      ('No plants', 'Snake plant for night-time oxygen'),
    ],
    materialIds: ['reclaimed-teak', 'lime-plaster'],
    plantIds: ['snake-plant'],
  ),
  DesignStory(
    id: 'bengaluru-bamboo-kitchen',
    image: 'assets/images/story-kitchen.jpg',
    tag: 'Kitchen · Bengaluru',
    title: 'A bamboo kitchen that grows its own herbs',
    subtitle: 'Terracotta underfoot, reclaimed shelving and a monstera that loves the steam.',
    meta: 'Before & After',
    author: 'Words by the Vana studio',
    room: 'Kitchen',
    budget: '₹2.3L',
    area: '110 sqft',
    carbonCut: '−41%',
    intro:
        'Karthik cooks three meals a day in a 110 sqft galley in Indiranagar. The old kitchen had glossy '
        'tiles that chipped, a granite counter shipped from Rajasthan and no natural ventilation.',
    sections: [
      StorySection(
        'Cool clay underfoot',
        'Handmade terracotta tiles from a kiln in Kanakapura replaced the vitrified floor. They are kinder '
            'on the knees during long cooking sessions and hide the odd turmeric spill.',
      ),
      StorySection(
        'Open shelves from old doors',
        'Upper cabinets came down. In their place: open shelves cut from reclaimed teak door frames, oiled '
            'with food-safe linseed. The kitchen instantly felt twice as wide.',
      ),
      StorySection(
        'A window that earns its keep',
        'A herb rail of tulsi, mint and curry leaf now lines the window, with a monstera by the fridge that '
            'thrives on the steam. The exhaust fan runs half as often as it used to.',
      ),
    ],
    quote: 'I pick curry leaves while the tadka is heating. That alone was worth it.',
    quoteBy: 'Karthik, homeowner',
    changes: [
      ('Vitrified tile, chipped within a year', 'Handmade Kanakapura terracotta'),
      ('Imported granite counter', 'Reclaimed teak shelving + local stone'),
      ('Closed upper cabinets', 'Open shelves and a window herb rail'),
      ('Exhaust fan on all day', 'Cross-ventilation + monstera'),
    ],
    materialIds: ['terracotta-tile', 'reclaimed-teak'],
    plantIds: ['monstera'],
  ),
];

DesignStory? storyById(String id) {
  for (final s in designStories) {
    if (s.id == id) return s;
  }
  return null;
}
