import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/emergency_models.dart';
import '../../providers/emergency_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/widgets/maps/location_picker_widget.dart';

class CreateEmergencyScreen extends ConsumerStatefulWidget {
  const CreateEmergencyScreen({super.key});

  @override
  ConsumerState<CreateEmergencyScreen> createState() => _CreateEmergencyScreenState();
}

class _CreateEmergencyScreenState extends ConsumerState<CreateEmergencyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _contactInstructionsController = TextEditingController();

  // Dropdown States
  String _selectedGender = 'MALE';
  String _selectedBloodGroup = 'O_POSITIVE';
  String _selectedComponent = 'WHOLE_BLOOD';
  String _selectedPriority = 'EMERGENCY';
  LatLng? _selectedLocation;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _unitsController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _medicalNotesController.dispose();
    _contactInstructionsController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hospital location on the map'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final dto = CreateEmergencyRequestDto(
      patientName: _patientNameController.text.trim(),
      patientAge: int.tryParse(_patientAgeController.text.trim()) ?? 0,
      patientGender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      emergencyType: _selectedComponent,
      unitsRequired: int.tryParse(_unitsController.text.trim()) ?? 1,
      priority: _selectedPriority,
      hospitalName: _hospitalNameController.text.trim(),
      hospitalAddress: _hospitalAddressController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      medicalNotes: _medicalNotesController.text.trim(),
      contactInstructions: _contactInstructionsController.text.trim(),
    );

    final request = await ref.read(emergencyNotifierProvider.notifier).createRequest(dto);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (request != null) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency Request Created Successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh provider done inside the notifier
        context.pop();
      } else {
        // Error handling
        final errorState = ref.read(emergencyNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorState?.toString() ?? 'Failed to create request. Try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Create Emergency Request'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPatientSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildBloodRequirementSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildHospitalSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildLocationSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildAdditionalInfoSection(),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  text: 'CREATE EMERGENCY',
                  onPressed: _isSubmitting ? null : _submitForm,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Patient Information'),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _patientNameController,
          decoration: const InputDecoration(labelText: 'Patient Name *', prefixIcon: Icon(Icons.person_outline)),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Patient name is required';
            if (value.length < 2) return 'Name must be at least 2 characters';
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _patientAgeController,
                decoration: const InputDecoration(labelText: 'Age *', prefixIcon: Icon(Icons.cake_outlined)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final age = int.tryParse(value);
                  if (age == null || age <= 0 || age > 120) return 'Invalid age';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.wc_outlined)),
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('Male')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBloodRequirementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Blood Requirement'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group *', prefixIcon: Icon(Icons.water_drop_outlined, color: AppColors.primary)),
                items: const [
                  DropdownMenuItem(value: 'A_POSITIVE', child: Text('A+')),
                  DropdownMenuItem(value: 'A_NEGATIVE', child: Text('A-')),
                  DropdownMenuItem(value: 'B_POSITIVE', child: Text('B+')),
                  DropdownMenuItem(value: 'B_NEGATIVE', child: Text('B-')),
                  DropdownMenuItem(value: 'O_POSITIVE', child: Text('O+')),
                  DropdownMenuItem(value: 'O_NEGATIVE', child: Text('O-')),
                  DropdownMenuItem(value: 'AB_POSITIVE', child: Text('AB+')),
                  DropdownMenuItem(value: 'AB_NEGATIVE', child: Text('AB-')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBloodGroup = val);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _unitsController,
                decoration: const InputDecoration(labelText: 'Units *', prefixIcon: Icon(Icons.format_list_numbered)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final units = int.tryParse(value);
                  if (units == null || units <= 0) return 'Must be > 0';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedComponent,
                decoration: const InputDecoration(labelText: 'Component *', prefixIcon: Icon(Icons.science_outlined)),
                items: const [
                  DropdownMenuItem(value: 'WHOLE_BLOOD', child: Text('Whole Blood')),
                  DropdownMenuItem(value: 'PLASMA', child: Text('Plasma')),
                  DropdownMenuItem(value: 'PLATELETS', child: Text('Platelets')),
                  DropdownMenuItem(value: 'RBC', child: Text('Red Blood Cells')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedComponent = val);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority *', prefixIcon: Icon(Icons.priority_high)),
                items: const [
                  DropdownMenuItem(value: 'ROUTINE', child: Text('Routine (24h)')),
                  DropdownMenuItem(value: 'URGENT', child: Text('Urgent (12h)')),
                  DropdownMenuItem(value: 'EMERGENCY', child: Text('Emergency (Now)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPriority = val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHospitalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Hospital Information'),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _hospitalNameController,
          decoration: const InputDecoration(labelText: 'Hospital Name *', prefixIcon: Icon(Icons.local_hospital_outlined)),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Hospital name is required';
            if (value.length < 3) return 'Name must be at least 3 characters';
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _hospitalAddressController,
          decoration: const InputDecoration(labelText: 'Hospital Address *', prefixIcon: Icon(Icons.map_outlined)),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Hospital address is required';
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City *', prefixIcon: Icon(Icons.location_city_outlined)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District *', prefixIcon: Icon(Icons.terrain_outlined)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Hospital Location *'),
        const SizedBox(height: AppSpacing.sm),
        LocationPickerWidget(
          height: 250,
          onLocationSelected: (location, address) {
            setState(() {
              _selectedLocation = location;
              // Optionally autofill address if empty
              if (address != null && _hospitalAddressController.text.isEmpty) {
                _hospitalAddressController.text = address;
              }
            });
          },
        ),
        if (_selectedLocation == null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Location is required for emergency matching.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Additional Information'),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _medicalNotesController,
          decoration: const InputDecoration(
            labelText: 'Medical Notes (Optional)',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.note_alt_outlined),
          ),
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _contactInstructionsController,
          decoration: const InputDecoration(
            labelText: 'Contact Instructions (Optional)',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          maxLines: 2,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
