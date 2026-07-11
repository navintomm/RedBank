import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/information_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../domain/blood_group_helper.dart';
import '../domain/donor_models.dart';
import '../providers/donor_provider.dart';

class EditDonorProfileScreen extends ConsumerStatefulWidget {
  const EditDonorProfileScreen({super.key});

  @override
  ConsumerState<EditDonorProfileScreen> createState() => _EditDonorProfileScreenState();
}

class _EditDonorProfileScreenState extends ConsumerState<EditDonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isModified = false;
  bool _isLoading = false;

  late TextEditingController _weightController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _medicalNotesController;

  String? _selectedBloodGroup;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  final List<String> _bloodGroups = [
    'A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE',
    'O_POSITIVE', 'O_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE'
  ];

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER'];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(donorProfileProvider).valueOrNull;

    _weightController = TextEditingController(text: profile?.weight?.toString() ?? '');
    _districtController = TextEditingController(text: profile?.district ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _medicalNotesController = TextEditingController(text: profile?.medicalNotes ?? '');

    _selectedBloodGroup = profile?.bloodGroup;
    _selectedGender = profile?.gender;
    _selectedDateOfBirth = profile?.dateOfBirth;

    // Attach listeners to detect modifications
    _weightController.addListener(_markAsModified);
    _districtController.addListener(_markAsModified);
    _cityController.addListener(_markAsModified);
    _medicalNotesController.addListener(_markAsModified);
  }

  void _markAsModified() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _isModified = true;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Blood Group')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateDonorProfileRequest(
        bloodGroup: _selectedBloodGroup!,
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
        weight: _weightController.text.isNotEmpty ? double.parse(_weightController.text) : null,
        district: _districtController.text.isNotEmpty ? _districtController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        medicalNotes: _medicalNotesController.text.isNotEmpty ? _medicalNotesController.text : null,
      );

      final notifier = ref.read(donorProfileProvider.notifier);
      await notifier.createOrUpdateProfile(request);

      final state = ref.read(donorProfileProvider);
      if (state.hasError) {
        throw state.error!;
      }

      if (mounted) {
        setState(() {
          _isModified = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isModified) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isModified,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InformationCard(
                  title: 'Basic Details',
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: 'Red Bank Hero',
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          helperText: 'Name is managed in account settings',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _selectedBloodGroup,
                        decoration: const InputDecoration(labelText: 'Blood Group *'),
                        items: _bloodGroups.map((bg) {
                          return DropdownMenuItem(
                            value: bg,
                            child: Text(BloodGroupHelper.formatDisplay(bg)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodGroup = value;
                            _isModified = true;
                          });
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InformationCard(
                  title: 'Personal Information',
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedDateOfBirth != null
                                ? "\${_selectedDateOfBirth!.year}-\${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-\${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}"
                                : 'Select Date',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: _genders.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _isModified = true;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) {
                              return 'Please enter a valid weight';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InformationCard(
                  title: 'Location & Medical',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City *'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(labelText: 'District *'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _medicalNotesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Medical Notes (Optional)',
                          hintText: 'Any underlying conditions or medications...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(
              text: 'Save Changes',
              isLoading: _isLoading,
              onPressed: _isModified ? _handleSave : null,
            ),
          ),
        ),
      ),
    );
  }
}
