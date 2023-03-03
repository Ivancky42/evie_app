class AccountModel {
  int id;
  String label;
  List<dynamic>? secondLevelLabel;

  AccountModel({
    required this.id,
    required this.label,
    this.secondLevelLabel,
  });

  factory AccountModel.fromJson(Map json) {
    return AccountModel(
        id: json['id'],
        label: json['label'],
        secondLevelLabel: json['second_level_label'] ?? []
    );
  }
}