import 'package:flutter/material.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class CalendarActivityPage extends StatefulWidget {
  const CalendarActivityPage({super.key});

  @override
  State<CalendarActivityPage> createState() => _CalendarActivityPageState();
}

class _CalendarActivityPageState extends State<CalendarActivityPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  int _loadRequestId = 0;
  List<Map<String, String>> _monthActivities = [];

  List<Map<String, String>> get _activities => _monthActivities
      .where((activity) => _isSameDay(_parseActivityDate(activity['Pref6'])))
      .toList();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final requestId = ++_loadRequestId;
    final selectedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    setState(() => _isLoading = true);
    try {
      await _session.load();
      final bus = _session.busAuthority;
      final auth = _session.userAuth;

      final date1 = '${selectedMonth.month}/1/${selectedMonth.year}';
      final result = await _crmService.getDataActivity(
        bus,
        auth,
        'All',
        '',
        date1,
        '-',
      );

      if (!mounted ||
          requestId != _loadRequestId ||
          selectedMonth.year != _selectedDate.year ||
          selectedMonth.month != _selectedDate.month) {
        return;
      }
      setState(() {
        _monthActivities = result == null
            ? []
            : PipeDataParser.parseRows(
                result.toJson().cast<String, String?>(),
                13,
              );
      });
    } catch (e) {
      if (mounted && requestId == _loadRequestId) {
        setState(() => _monthActivities = []);
        showCrmSnackBar(context, 'Error loading activities: $e', isError: true);
      }
    } finally {
      if (mounted && requestId == _loadRequestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isSameDay(DateTime? date) {
    return date != null &&
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  DateTime? _parseActivityDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final datePart = value.trim().split(RegExp(r'\s+')).first;
    final parts = datePart.split(RegExp(r'[/.-]'));
    if (parts.length < 3) return DateTime.tryParse(value);

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final third = int.tryParse(parts[2]);
    if (first == null || second == null || third == null) return null;

    return first > 31
        ? DateTime(first, second, third)
        : DateTime(third, first, second);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCalendarCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daily Activities (${_activities.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _loadActivities,
                  child: const Text("Refresh"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _activities.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: _activities
                        .map((activity) => _buildActivityItem(activity))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              "No activities for this day",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_today_rounded, color: Colors.red),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Activity Calendar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        onDateChanged: (date) {
          setState(() => _selectedDate = date);
        },
        onDisplayedMonthChanged: (month) {
          if (month.year == _selectedDate.year &&
              month.month == _selectedDate.month) {
            return;
          }
          setState(() {
            _selectedDate = DateTime(month.year, month.month, 1);
            _monthActivities = [];
          });
          _loadActivities();
        },
      ),
    );
  }

  Widget _buildActivityItem(Map<String, String> row) {
    bool isCompleted = row['Pref7'] == 'Finished';
    String time = row['Pref6'] ?? '--:--';
    if (time.contains(' ')) time = time.split(' ')[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.1)
                  : const Color(0xFF1E4CCB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isCompleted ? Colors.green : const Color(0xFF1E4CCB),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row['Pref5'] ?? 'No Subject',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                Text(
                  "${row['Pref2']} - ${row['Pref3']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? Colors.green : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
