class BikeSettingModel {
  int id;
  String label;
  List<dynamic>? secondLevelLabel;

  BikeSettingModel({
    required this.id,
    required this.label,
    this.secondLevelLabel,
  });

  factory BikeSettingModel.fromJson(Map json) {
    return BikeSettingModel(
        id: json['id'],
        label: json['label'],
        secondLevelLabel: json['second_level_label'] ?? []
    );
  }
}