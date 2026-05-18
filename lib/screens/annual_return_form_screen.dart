import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Annual Return Form Screen - Form for hunters to submit wildlife return
class AnnualReturnFormScreen extends StatefulWidget {
  const AnnualReturnFormScreen({Key? key}) : super(key: key);

  @override
  State<AnnualReturnFormScreen> createState() => _AnnualReturnFormScreenState();
}

class _AnnualReturnFormScreenState extends State<AnnualReturnFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _speciesController;
  late TextEditingController _quantityController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _notesController;
  String? _selectedRegion;

  final List<String> _regions = [
    'Kunene Region',
    'Erongo Region',
    'Hardap Region',
    'Otjozondjupa Region',
    'Omaheke Region',
    'Khomas Region',
    'Karas Region',
    'Kavango West',
    'Kavango East',
  ];

  @override
  void initState() {
    super.initState();
    _speciesController = TextEditingController();
    _quantityController = TextEditingController();
    _locationController = TextEditingController();
    _dateController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return submitted successfully!')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit New Return'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.primaryGreen.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complete Return Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.primaryGreen.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Species Field
                _buildSectionHeader('Wildlife Information'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _speciesController,
                  decoration: _buildInputDecoration('Species Name', Icons.pets),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter species name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration:
                            _buildInputDecoration('Quantity', Icons.numbers),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRegion,
                        decoration:
                            _buildInputDecoration('Region', Icons.location_on),
                        items: _regions
                            .map((region) => DropdownMenuItem(
                                  value: region,
                                  child: Text(region),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Location Field
                _buildSectionHeader('Location Details'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration:
                      _buildInputDecoration('Specific Location', Icons.map),
                  maxLines: 2,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter location details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Date Field
                _buildSectionHeader('Date Information'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateController,
                  decoration: _buildInputDecoration(
                      'Date of Hunt', Icons.calendar_today),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _dateController.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Notes Field
                _buildSectionHeader('Additional Information'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration:
                      _buildInputDecoration('Notes', Icons.note, maxLines: 3),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Photo Upload Info
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.info,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  color: AppColors.info.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.info,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add Photos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload photos of the wildlife (optional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.check),
                    label: const Text('Submit Return'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon,
      {int? maxLines}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.primaryGreen,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.lightGrey,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.lightGrey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryGreen,
          width: 2,
        ),
      ),
    );
  }
}
