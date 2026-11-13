/// Represents an automotive vehicle, spare part, or accessory listing in
/// Roadlink's marketplace.
class MarketplaceItem {
  final String id;
  final String category;
  final String imageAsset;
  final String title;
  final String price;
  final String location;
  final String sellerType;
  final String condition;
  final String description;

  const MarketplaceItem({
    required this.id,
    required this.category,
    required this.imageAsset,
    required this.title,
    required this.price,
    required this.location,
    required this.sellerType,
    required this.condition,
    required this.description,
  });

  String get subtitle => '$location · $sellerType';
}

/// Curated Zimbabwe automotive marketplace listings shared by the Home
/// Dashboard and the full Marketplace page.
const List<MarketplaceItem> kMarketplaceItems = [
  MarketplaceItem(
    id: 'car-vitz-2016',
    category: 'Cars',
    imageAsset: 'assets/images/marketplace_car.png',
    title: 'Silver compact hatchback',
    price: 'US\$6,800',
    location: 'Harare',
    sellerType: 'Seller listing',
    condition: 'Clean import · 84,000 km',
    description:
        'Economical 1.3L automatic hatchback, fresh ZIMRA clearance, '
        'service history available in Avondale.',
  ),
  MarketplaceItem(
    id: 'parts-alloy-16',
    category: 'Parts & tyres',
    imageAsset: 'assets/images/marketplace_wheels.png',
    title: 'Alloy wheels · set of 4',
    price: 'US\$320',
    location: 'Bulawayo',
    sellerType: 'Seller listing',
    condition: 'Used · Good tread',
    description:
        '16-inch 5-stud alloy rims with matching 205/55R16 tyres, balanced '
        'and ready to fit.',
  ),
  MarketplaceItem(
    id: 'acc-roof-rack',
    category: 'Accessories',
    imageAsset: 'assets/images/marketplace_rack.png',
    title: 'SUV roof rack',
    price: 'US\$180',
    location: 'Mutare',
    sellerType: 'Seller listing',
    condition: 'New · Heavy duty',
    description:
        'Powder-coated steel overland roof basket with universal gutter '
        'clamps for SUVs and double cabs.',
  ),
  MarketplaceItem(
    id: 'car-hilux-2018',
    category: 'Cars',
    imageAsset: 'assets/images/marketplace_car.png',
    title: 'Double cab 4x4 pickup',
    price: 'US\$24,500',
    location: 'Rusape',
    sellerType: 'Verified dealer',
    condition: 'Used · 112,000 km',
    description:
        'Well-maintained 2.4 GD-6 4x4 with canopy, bullbar and full '
        'Manicaland service record.',
  ),
  MarketplaceItem(
    id: 'parts-brake-kit',
    category: 'Parts & tyres',
    imageAsset: 'assets/images/marketplace_wheels.png',
    title: 'Front brake pads & rotors',
    price: 'US\$95',
    location: 'Msasa, Harare',
    sellerType: 'Auto spares shop',
    condition: 'Brand new OEM spec',
    description:
        'Ceramic low-dust brake pad and ventilated disc set for popular '
        'Toyota and Honda sedans.',
  ),
  MarketplaceItem(
    id: 'acc-recovery-kit',
    category: 'Accessories',
    imageAsset: 'assets/images/marketplace_rack.png',
    title: '4x4 recovery & tow kit',
    price: 'US\$110',
    location: 'Harare CBD',
    sellerType: 'Auto spares shop',
    condition: 'Brand new',
    description:
        '9-tonne snatch strap, two D-shackles, heavy-duty gloves and '
        'compact 12V tyre compressor.',
  ),
];

