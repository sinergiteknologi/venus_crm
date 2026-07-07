import 'dart:async';

import 'package:flutter/material.dart';
import '../models/dropdown_option.dart';

class CrmDropdownField extends StatelessWidget {
  final String label;
  final List<DropdownOption> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final Future<List<DropdownOption>> Function(String query)? onSearch;
  final String? hint;

  const CrmDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onSearch,
    this.hint,
  });

  String? _selectedLabel() {
    if (value == null) return null;
    for (final item in items) {
      if (item.code == value) return item.name;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SearchableDropdownSheet(
        title: label,
        items: items,
        selectedCode: value,
        onSearch: onSearch,
      ),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _selectedLabel();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: enabled ? () => _openPicker(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 20),
             
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          child: Text(
            selectedLabel ?? hint ?? 'Select $label',
            style: TextStyle(
              fontSize: 14,
              color: selectedLabel != null ? Colors.black87 : Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _SearchableDropdownSheet extends StatefulWidget {
  final String title;
  final List<DropdownOption> items;
  final String? selectedCode;
  final Future<List<DropdownOption>> Function(String query)? onSearch;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.selectedCode,
    this.onSearch,
  });

  @override
  State<_SearchableDropdownSheet> createState() => _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState extends State<_SearchableDropdownSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<DropdownOption> _displayItems = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _displayItems = widget.items;
    _searchCtrl.addListener(_onSearchChanged);
    if (widget.onSearch != null) {
      _fetchFromApi('');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (widget.onSearch != null) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () => _fetchFromApi(query));
      return;
    }
    setState(() => _displayItems = _filterLocal(query));
  }

  List<DropdownOption> _filterLocal(String query) {
    if (query.isEmpty) return widget.items;
    final lower = query.toLowerCase();
    return widget.items
        .where((e) =>
            e.name.toLowerCase().contains(lower) ||
            e.code.toLowerCase().contains(lower))
        .toList();
  }

  Future<void> _fetchFromApi(String query) async {
    setState(() => _loading = true);
    try {
      final results = await widget.onSearch!(query);
      if (mounted) setState(() => _displayItems = results);
    } catch (_) {
      if (mounted) setState(() => _displayItems = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title.toLowerCase()}...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF1E4CCB)),
              )
            else if (_displayItems.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _displayItems.length,
                  itemBuilder: (context, index) {
                    final item = _displayItems[index];
                    final isSelected = item.code == widget.selectedCode;
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF1E4CCB) : Colors.black87,
                        ),
                      ),
                      subtitle: item.code != item.name
                          ? Text(item.code, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF1E4CCB))
                          : null,
                      onTap: () => Navigator.pop(context, item.code),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CrmTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  const CrmTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E4CCB), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          labelStyle: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

void showCrmSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class CrmSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CrmSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
