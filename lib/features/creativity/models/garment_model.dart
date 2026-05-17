class GarmentSpec {
  final String type; // تيشرت، هودي، إلخ
  final List<String> machines; // أوفر، سنجر، فلات
  final String folderSize; // مقاس الفولدر (المسلك)
  final String stitchType; // نوع الغرزة
  final String material; // نوع القماش

  const GarmentSpec({
    required this.type,
    required this.machines,
    required this.folderSize,
    required this.stitchType,
    required this.material,
  });
}

class CreativityProject {
  final String id;
  final String name;
  final GarmentSpec spec;
  final DateTime createdAt;

  const CreativityProject({
    required this.id,
    required this.name,
    required this.spec,
    required this.createdAt,
  });
}
