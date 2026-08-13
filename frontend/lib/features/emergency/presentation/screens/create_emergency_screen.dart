import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../../core/widgets/medical_text_field.dart';
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

    return RedBankScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Request Blood'),
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: MedicalIconButton(
            icon: Icons.arrow_back,
            isGlass: true,
            hasBackground: true,
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPatientSection(isDark),
                const SizedBox(height: AppSpacing.lg),
                _buildBloodRequirementSection(isDark),
                const SizedBox(height: AppSpacing.lg),
                _buildHospitalSection(isDark),
                const SizedBox(height: AppSpacing.lg),
                _buildLocationSection(isDark),
                const SizedBox(height: AppSpacing.lg),
                _buildAdditionalInfoSection(isDark),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  text: 'CREATE EMERGENCY',
                  icon: Icons.health_and_safety_outlined,
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

  Widget _buildPatientSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Patient Information'),
        SurfaceCard(
          elevated: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              MedicalTextField(
                controller: _patientNameController,
                labelText: 'Patient Name *',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  if (value.length < 2) return 'Must be at least 2 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: MedicalTextField(
                      controller: _patientAgeController,
                      labelText: 'Age *',
                      prefixIcon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final age = int.tryParse(value);
                        if (age == null || age <= 0 || age > 120) return 'Invalid age';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Gender *',
                      icon: Icons.wc_outlined,
                      value: _selectedGender,
                      items: const [
                        DropdownMenuItem(value: 'MALE', child: Text('Male')),
                        DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGender = val);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBloodRequirementSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Blood Requirement'),
        SurfaceCard(
          elevated: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildDropdown(
                      label: 'Blood Group *',
                      icon: Icons.water_drop_outlined,
                      value: _selectedBloodGroup,
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
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: MedicalTextField(
                      controller: _unitsController,
                      labelText: 'Units *',
                      prefixIcon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final units = int.tryParse(value);
                        if (units == null || units <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Component *',
                      icon: Icons.science_outlined,
                      value: _selectedComponent,
                      items: const [
                        DropdownMenuItem(value: 'WHOLE_BLOOD', child: Text('Whole Blood')),
                        DropdownMenuItem(value: 'PLASMA', child: Text('Plasma')),
                        DropdownMenuItem(value: 'PLATELETS', child: Text('Platelets')),
                        DropdownMenuItem(value: 'RBC', child: Text('Red Blood Cells')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedComponent = val);
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Priority *',
                      icon: Icons.priority_high,
                      value: _selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 'ROUTINE', child: Text('Routine')),
                        DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
                        DropdownMenuItem(value: 'EMERGENCY', child: Text('Emergency')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriority = val);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Hospital Information'),
        SurfaceCard(
          elevated: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              MedicalTextField(
                controller: _hospitalNameController,
                labelText: 'Hospital Name *',
                prefixIcon: Icons.local_hospital_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  if (value.length < 3) return 'Must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              MedicalTextField(
                controller: _hospitalAddressController,
                labelText: 'Hospital Address *',
                prefixIcon: Icons.map_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: MedicalTextField(
                      controller: _cityController,
                      labelText: 'City *',
                      prefixIcon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: MedicalTextField(
                      controller: _districtController,
                      labelText: 'District *',
                      prefixIcon: Icons.terrain_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Hospital Location *'),
        SurfaceCard(
          elevated: true,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: LocationPickerWidget(
              height: 250,
              onLocationSelected: (location, address) {
                setState(() {
                  _selectedLocation = location;
                  if (address != null && _hospitalAddressController.text.isEmpty) {
                    _hospitalAddressController.text = address;
                  }
                });
              },
            ),
          ),
        ),
        if (_selectedLocation == null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, left: AppSpacing.xs),
            child: Text(
              'Location is required for emergency matching.',
              style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                color: isDark ? AppColors.errorDark : AppColors.errorLight,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Additional Information'),
        SurfaceCard(
          elevated: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              MedicalTextField(
                controller: _medicalNotesController,
                labelText: 'Medical Notes (Optional)',
                prefixIcon: Icons.note_alt_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              MedicalTextField(
                controller: _contactInstructionsController,
                labelText: 'Contact Instructions (Optional)',
                prefixIcon: Icons.phone_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      style: AppTypography.getTextTheme(isDark: isDark).bodyLarge,
    );
  }
}
