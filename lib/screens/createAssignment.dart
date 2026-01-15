import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAssignment extends StatefulWidget {
  const CreateAssignment({super.key});

  @override
  State<CreateAssignment> createState() => _CreateAssignmentState();
}

class _CreateAssignmentState extends State<CreateAssignment> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController marksController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _selectedClassId;
  List<ClassModel> _instructorClasses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? uid =
          userProvider.currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await classProvider.fetchClasses(instructorId: uid);
        _instructorClasses = classProvider.getClassesByInstructorId(uid);
        if (_instructorClasses.isNotEmpty) {
          _selectedClassId ??= _instructorClasses.first.classId;
        }
        if (mounted) setState(() {});
      }
    });
  }

  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _createAssignment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a due date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final assignmentProvider = Provider.of<AssignmentProvider>(
          context,
          listen: false,
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Combine date and time
        DateTime dueDateTime = _selectedDate!;
        if (_selectedTime != null) {
          dueDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }

        // Ensure class selected
        if (_selectedClassId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a class'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Create assignment model
        final assignment = AssignmentModel(
          assignmentId: DateTime.now().millisecondsSinceEpoch.toString(),
          classId: _selectedClassId!,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          instructorId: userProvider.currentUser?.uid ?? 'demo_instructor',
          dueDate: dueDateTime,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalMarks: double.tryParse(marksController.text),
        );

        // Add assignment using provider
        await assignmentProvider.addAssignment(assignment);

        // Increment assignments counter on the class document for visibility in ManageClasses
        try {
          final classProvider = Provider.of<ClassProvider>(
            context,
            listen: false,
          );
          await classProvider.incrementAssignmentsCount(assignment.classId, 1);
        } catch (_) {}

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assignment created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 48, 85),
        title: Text(
          'Create Assignment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignment Information',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Class selector
                    if (_instructorClasses.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        isExpanded: true,
                        dropdownColor: const Color.fromARGB(255, 4, 48, 85),
                        decoration: InputDecoration(
                          labelText: 'Class',
                          prefixIcon: Icon(Icons.class_, color: Colors.grey),
                        ),
                        items: _instructorClasses
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.classId,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F3B57),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF082432),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            c.className.isNotEmpty
                                                ? c.className[0]
                                                : 'C',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.className,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        selectedItemBuilder: (context) {
                          return _instructorClasses.map((c) {
                            return Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF082432),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.className.isNotEmpty
                                          ? c.className[0]
                                          : 'C',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    c.className,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                        onChanged: (v) => setState(() => _selectedClassId = v),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please select a class';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Assignment Title',
                        hintText: 'Enter assignment title',
                        prefixIcon: Icon(Icons.title, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter assignment title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      style: TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter assignment description',
                        prefixIcon: Icon(Icons.description, color: Colors.grey),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: marksController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Total Marks',
                        hintText: 'Enter total marks',
                        prefixIcon: Icon(Icons.grade, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter total marks';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date & Time',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.grey),
                      title: Text(
                        _selectedDate == null
                            ? 'Select Due Date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    Divider(color: Colors.grey),
                    ListTile(
                      leading: Icon(Icons.access_time, color: Colors.grey),
                      title: Text(
                        _selectedTime == null
                            ? 'Select Time (Optional)'
                            : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: _isLoading ? null : _createAssignment,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create Assignment',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    marksController.dispose();
    super.dispose();
  }
}
