import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageClasses extends StatefulWidget {
  const ManageClasses({super.key});

  @override
  State<ManageClasses> createState() => _ManageClassesState();
}

class _ManageClassesState extends State<ManageClasses> {
  bool _isLoading = true;

  List<ClassModel> get _classesFromProvider {
    final provider = Provider.of<ClassProvider>(context, listen: false);
    return provider.classes;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final assignmentProvider = Provider.of<AssignmentProvider>(
        context,
        listen: false,
      );

      if (userProvider.currentUser == null) {
        await userProvider.autoLoginUser();
      }

      final instructorId =
          userProvider.currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.uid;
      if (instructorId != null) {
        await classProvider.fetchClasses(instructorId: instructorId);
        // Load assignments so we can show per-class counts
        await assignmentProvider.fetchAssignments();
      }

      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _showCreateClassDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 4, 48, 85),
          title: Text(
            'Create New Class',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Class Name',
                    hintText: 'e.g., Flutter Development',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Class Code',
                    hintText: 'e.g., CS202',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g., Mobile Development',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter class description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    codeController.text.isNotEmpty) {
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );
                  final classProvider = Provider.of<ClassProvider>(
                    context,
                    listen: false,
                  );

                  final instructorId =
                      userProvider.currentUser?.uid ??
                      FirebaseAuth.instance.currentUser?.uid ??
                      '';
                  final instructorName =
                      userProvider.currentUser?.name ?? 'Instructor';

                  final id = FirebaseFirestore.instance
                      .collection('classes')
                      .doc()
                      .id;
                  final now = DateTime.now();
                  final newClass = ClassModel(
                    classId: id,
                    className: nameController.text,
                    description: descriptionController.text,
                    instructorId: instructorId,
                    instructorName: instructorName,
                    studentIds: [],
                    subject: subjectController.text,
                    classCode: codeController.text,
                    createdAt: now,
                    updatedAt: now,
                  );

                  try {
                    await classProvider.addClass(newClass);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Class created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Create',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteClass(int index) {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final classData = _classesFromProvider[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 4, 48, 85),
          title: Text(
            'Delete Class',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete ${classData.className}?',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () async {
                try {
                  await classProvider.deleteClass(classData.classId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Class deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(int index, ClassModel classData) {
    return Dismissible(
      key: Key(classData.classId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) async {
        final classProvider = Provider.of<ClassProvider>(
          context,
          listen: false,
        );
        try {
          await classProvider.deleteClass(classData.classId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${classData.className} deleted'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/classdetails', arguments: classData);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.class_, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData.className,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            classData.classCode ?? '',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<int>(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      color: const Color.fromARGB(255, 4, 48, 85),
                      onSelected: (value) {
                        if (value == 0) {
                          // Edit action: placeholder for future edit flow
                        } else if (value == 1) {
                          _deleteClass(index);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.subject, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      classData.subject,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${classData.studentIds.length}',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Students',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${Provider.of<AssignmentProvider>(context).getAssignmentsByClassId(classData.classId).length}',
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Assignments',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 48, 85),
        title: Text(
          'Manage Classes',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'My Classes (${_classesFromProvider.length})',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_classesFromProvider.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.class_, color: Colors.grey, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      'No classes yet',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first class',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._classesFromProvider.asMap().entries.map((entry) {
              return _buildClassCard(entry.key, entry.value);
            }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateClassDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
