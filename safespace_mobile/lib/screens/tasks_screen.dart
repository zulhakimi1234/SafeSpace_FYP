import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskModel> _tasks = [];

  bool _isLoading = true;
  bool _isMutating = false;
  String? _error;

  bool _showCalendar = false;
  String _statusFilter = 'all';

  final DateTime _today = DateTime.now();

  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime(_today.year, _today.month, _today.day);

    _displayedMonth = DateTime(_today.year, _today.month, 1);

    _loadTasks();
  }

  // =========================================
  // LOAD TASKS
  // =========================================
  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await TaskService.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================================
  // OPEN ADD / EDIT TASK
  // =========================================
  Future<void> _openTaskForm({TaskModel? task}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );

    if (!mounted) return;

    if (saved == true) {
      await _loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task == null
                ? 'Task created successfully!'
                : 'Task updated successfully!',
          ),
        ),
      );
    }
  }

  // =========================================
  // API OPERATIONS
  // =========================================
  Future<void> _performOperation(
    Future<void> Function() operation,
    String successMessage,
  ) async {
    if (_isMutating) return;

    setState(() {
      _isMutating = true;
    });

    try {
      await operation();

      if (!mounted) return;

      await _loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  // Change task status
  Future<void> _changeStatus(TaskModel task, String newStatus) async {
    if (task.status == newStatus) return;

    await _performOperation(() async {
      await TaskService.updateTask(task.copyWith(status: newStatus));
    }, 'Task status updated successfully!');
  }

  // =========================================
  // DELETE TASK
  // =========================================
  Future<void> _confirmDelete(TaskModel task) async {
    if (_isMutating) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await _performOperation(
      () => TaskService.deleteTask(task.id),
      'Task deleted successfully!',
    );
  }

  // =========================================
  // TASK STATISTICS
  // =========================================
  Widget _statCard(String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF8E7AB5), size: 21),
            const SizedBox(height: 7),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF594780),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final pending = _tasks.where((task) => task.status == 'pending').length;

    final completed = _tasks.where((task) => task.status == 'completed').length;

    return Row(
      children: [
        _statCard('Total', _tasks.length, Icons.list_alt_rounded),
        const SizedBox(width: 10),
        _statCard('Pending', pending, Icons.schedule_rounded),
        const SizedBox(width: 10),
        _statCard('Completed', completed, Icons.check_circle_outline_rounded),
      ],
    );
  }

  // =========================================
  // REUSABLE TASK CARD
  // =========================================
  Widget _buildTaskCard(TaskModel task) {
    final statusColor = switch (task.status) {
      'completed' => const Color(0xFF348468),
      'in_progress' => const Color(0xFF936C27),
      _ => const Color(0xFF8E7AB5),
    };

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: statusColor,
                  size: 25,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    onTap: _isMutating ? null : () => _openTaskForm(task: task),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: const Color(0xFF333333),
                          ),
                        ),

                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),

                          Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  tooltip: 'Task Options',
                  enabled: !_isMutating,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openTaskForm(task: task);
                    } else if (value == 'delete') {
                      _confirmDelete(task);
                    } else {
                      _changeStatus(task, value);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Task')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'pending',
                      child: Text('Mark as Pending'),
                    ),
                    PopupMenuItem(
                      value: 'in_progress',
                      child: Text('Mark as In Progress'),
                    ),
                    PopupMenuItem(
                      value: 'completed',
                      child: Text('Mark as Completed'),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(value: 'delete', child: Text('Delete Task')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    task.statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),

                if (task.category != null && task.category!.isNotEmpty)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(task.category!),
                  ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: task.isOverdue ? Colors.redAccent : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      task.displayDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isOverdue ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (task.isOverdue) ...[
              const SizedBox(height: 7),
              const Text(
                'Overdue',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================
  // TASK LIST WITH STATUS FILTER
  // =========================================
  Widget _buildTaskList() {
    final filteredTasks = _statusFilter == 'all'
        ? _tasks
        : _tasks.where((task) {
            return task.status == _statusFilter;
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', 'all'),
              const SizedBox(width: 8),
              _filterChip('Pending', 'pending'),
              const SizedBox(width: 8),
              _filterChip('In Progress', 'in_progress'),
              const SizedBox(width: 8),
              _filterChip('Completed', 'completed'),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (filteredTasks.isEmpty)
          _emptyMessage(
            'No tasks found.',
            'Add a task or select another status.',
          ),

        ...filteredTasks.map(_buildTaskCard),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _statusFilter == value,
      selectedColor: const Color(0xFFE8DFF5),
      onSelected: (_) {
        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  // =========================================
  // CALENDAR HELPERS
  // =========================================
  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TaskModel> _tasksForDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = task.date;

      return taskDate != null && _sameDay(taskDate, date);
    }).toList();
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
        1,
      );

      _selectedDate = _displayedMonth;
    });
  }

  // =========================================
  // CALENDAR GRID
  // =========================================
  Widget _buildCalendar() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    // Monday = 1, Sunday = 7
    final blankDays = firstDay.weekday - 1;

    final totalCells = ((blankDays + daysInMonth + 6) ~/ 7) * 7;

    final selectedTasks = _tasksForDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              // Month Navigation
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous Month',
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),

                  Expanded(
                    child: Text(
                      '${_monthNames[_displayedMonth.month - 1]} '
                      '${_displayedMonth.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF594780),
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Next Month',
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Weekday Header
              const Row(
                children: [
                  _WeekdayLabel('M'),
                  _WeekdayLabel('T'),
                  _WeekdayLabel('W'),
                  _WeekdayLabel('T'),
                  _WeekdayLabel('F'),
                  _WeekdayLabel('S'),
                  _WeekdayLabel('S'),
                ],
              ),

              const SizedBox(height: 8),

              // Calendar Days
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - blankDays + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month,
                    dayNumber,
                  );

                  final isSelected = _sameDay(date, _selectedDate);

                  final isToday = _sameDay(date, _today);

                  final count = _tasksForDate(date).length;

                  return Material(
                    color: isSelected
                        ? const Color(0xFFE8DFF5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isToday
                                  ? const Color(0xFF8E7AB5)
                                  : const Color(0xFF333333),
                            ),
                          ),

                          const SizedBox(height: 5),

                          if (count > 0)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8E7AB5),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 23),

        // Selected Date Heading
        Text(
          'Tasks on '
          '${_selectedDate.day.toString().padLeft(2, '0')}/'
          '${_selectedDate.month.toString().padLeft(2, '0')}/'
          '${_selectedDate.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF594780),
          ),
        ),

        const SizedBox(height: 15),

        if (selectedTasks.isEmpty)
          _emptyMessage(
            'No tasks on this date.',
            'Select another date or add a new task.',
          ),

        ...selectedTasks.map(_buildTaskCard),
      ],
    );
  }

  // =========================================
  // EMPTY STATE
  // =========================================
  Widget _emptyMessage(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_note_outlined,
            size: 45,
            color: Color(0xFF8E7AB5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // =========================================
  // MAIN TASK SCREEN
  // =========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF594780),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Tasks',
            onPressed: _isLoading ? null : _loadTasks,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF594780)),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTasks,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 95),
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DFF5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organize your day 💜',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF594780),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Small steps still move you forward.',
                      style: TextStyle(color: Color(0xFF594780), fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Loading
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(35),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // API Error
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loadTasks,
                  child: const Text('Try Again'),
                ),
              ],

              if (!_isLoading && _error == null) ...[
                _buildStatistics(),

                const SizedBox(height: 22),

                // List / Calendar Switch
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _viewButton(
                          'Task List',
                          Icons.list_alt_rounded,
                          !_showCalendar,
                          () {
                            setState(() {
                              _showCalendar = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _viewButton(
                          'Calendar',
                          Icons.calendar_month_outlined,
                          _showCalendar,
                          () {
                            setState(() {
                              _showCalendar = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (_showCalendar) _buildCalendar() else _buildTaskList(),
              ],
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        backgroundColor: const Color(0xFF8E7AB5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  // Button to switch views
  Widget _viewButton(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onPressed,
  ) {
    return Material(
      color: selected ? const Color(0xFFE8DFF5) : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? const Color(0xFF594780) : Colors.grey,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? const Color(0xFF594780) : Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Weekday header for calendar
class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
