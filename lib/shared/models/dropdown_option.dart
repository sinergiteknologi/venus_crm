class DropdownOption {
  final String code;
  final String name;

  const DropdownOption({required this.code, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownOption && code == other.code && name == other.name;

  @override
  int get hashCode => code.hashCode ^ name.hashCode;
}
