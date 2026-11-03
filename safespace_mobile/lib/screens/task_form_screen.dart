import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime? _dueDate;
  String _status = 'pending';
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _categoryController.text = task.category ?? '';
      _dueDate = task.date;
      _status = task.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // Choose due date
  Future<void> _selectDueDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Task Due Date',
    );

    if (selected != null && mounted) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  // Format date for Laravel DATE column
  String? _formattedDueDate() {
    final date = _dueDate;

    if (date == null) return null;

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String? _optionalText(String text) {
    final value = text.trim();
    return value.isEmpty ? null : value;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // Create or update task
  Future<void> _saveTask() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _optionalText(_descriptionController.text);
      final category = _optionalText(_categoryController.text);
      final dueDate = _formattedDueDate();

      if (_isEditing) {
        final updatedTask = TaskModel(
          id: widget.task!.id,
          title: title,
          description: description,
          category: category,
          dueDate: dueDate,
          status: _status,
        );

        await TaskService.updateTask(updatedTask);
      } else {
        await TaskService.createTask(
          title: title,
          description: description,
          category: category,
          dueDate: dueDate,
          status: _status,
        );
      }

      if (!mounted) return;

      // Notify task list to refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: Text(
          _isEditing ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF594780),
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DFF5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            color: Color(0xFF594780),
                            size: 30,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Every small step counts. Take your time and focus on what matters.',
                              style: TextStyle(
                                color: Color(0xFF594780),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Task Title
                    TextFormField(
                      controller: _titleController,
                      enabled: !_isSaving,
                      maxLength: 150,
                      decoration: InputDecoration(
                        labelText: 'Task Title *',
                        hintText: 'e.g. Complete FYP report',
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter task title';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Task Description
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isSaving,
                      maxLines: 4,
                      maxLength: 5000,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Write task details or notes...',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category
                    TextFormField(
                      controller: _categoryController,
                      enabled: !_isSaving,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Category (Optional)',
                        hintText: 'e.g. Study, Personal, Health',
                        prefixIcon: const Icon(Icons.category_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Due Date
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF8E7AB5),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'No due date selected'
                                  : '${_dueDate!.day.toString().padLeft(2, '0')}/'
                                        '${_dueDate!.month.toString().padLeft(2, '0')}/'
                                        '${_dueDate!.year}',
                            ),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              tooltip: 'Clear Due Date',
                              onPressed: _isSaving
                                  ? null
                                  : () {
                                      setState(() {
                                        _dueDate = null;
                                      });
                                    },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          IconButton(
                            tooltip: 'Choose Due Date',
                            onPressed: _isSaving ? null : _selectDueDate,
                            icon: const Icon(
                              Icons.date_range_rounded,
                              color: Color(0xFF594780),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Task Status
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: InputDecoration(
                        labelText: 'Task Status',
                        prefixIcon: const Icon(Icons.flag_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _status = value;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveTask,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : _isEditing
                            ? 'Update Task'
                            : 'Create Task',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8E7AB5),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
