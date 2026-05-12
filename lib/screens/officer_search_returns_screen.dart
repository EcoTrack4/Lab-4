import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Officer Search Returns Screen - Search and filter wildlife returns
class OfficerSearchReturnsScreen extends StatefulWidget {
  const OfficerSearchReturnsScreen({Key? key}) : super(key: key);

  @override
  State<OfficerSearchReturnsScreen> createState() =>
      _OfficerSearchReturnsScreenState();
}

class _OfficerSearchReturnsScreenState extends State<OfficerSearchReturnsScreen> {
  late TextEditingController _searchController;
  String _selectedStatus = 'All';
  String _selectedRegion = 'All Regions';
  String _selectedSpecies = 'All Species';

  final List<String> _statuses = ['All', 'Pending', 'Approved', 'Rejected'];
  final List<String> _regions = [
    'All Regions',
    'Kunene Region',
    'Erongo Region',
    'Hardap Region',
    'Otjozondjupa Region',
    'Omaheke Region',
    'Khomas Region',
    'Karas Region',
  ];
  final List<String> _species = [
    'All Species',
    'Oryx',
    'Kudu',
    'Springbok',
    'Warthog',
    'Giraffe',
    'Lion',
  ];

  final List<Map<String, String>> _returns = [
    {
      'species': 'Oryx',
      'hunter': 'Johannes Botha',
      'region': 'Kunene Region',
      'date': 'May 1, 2024',
      'status': 'Pending',
    },
    {
      'species': 'Kudu',
      'hunter': 'Peter Smith',
      'region': 'Erongo Region',
      'date': 'Apr 28, 2024',
      'status': 'Approved',
    },
    {
      'species': 'Springbok',
      'hunter': 'John Keller',
      'region': 'Hardap Region',
      'date': 'Apr 15, 2024',
      'status': 'Pending',
    },
    {
      'species': 'Warthog',
      'hunter': 'Mike Johnson',
      'region': 'Otjozondjupa Region',
      'date': 'Apr 10, 2024',
      'status': 'Approved',
    },
    {
      'species': 'Giraffe',
      'hunter': 'James Wilson',
      'region': 'Kunene Region',
      'date': 'Apr 5, 2024',
      'status': 'Rejected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredReturns {
    return _returns.where((item) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          item['species']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          item['hunter']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      final matchesStatus =
          _selectedStatus == 'All' || item['status'] == _selectedStatus;

      final matchesRegion = _selectedRegion == 'All Regions' ||
          item['region'] == _selectedRegion;

      final matchesSpecies = _selectedSpecies == 'All Species' ||
          item['species'] == _selectedSpecies;

      return matchesSearch && matchesStatus && matchesRegion && matchesSpecies;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Returns'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search by species or hunter name...',
                  prefixIcon: const Icon(Icons.search),
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
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),

              // Status Filter
              Wrap(
                spacing: 8,
                children: _statuses
                    .map((status) => FilterChip(
                  label: Text(status),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  selectedColor:
                      AppColors.primaryGreen.withOpacity(0.2),
                  backgroundColor: AppColors.lightGrey,
                  labelStyle: TextStyle(
                    color: _selectedStatus == status
                        ? AppColors.primaryGreen
                        : AppColors.mediumGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Region Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  labelText: 'Region',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _regions
                    .map((region) => DropdownMenuItem(
                  value: region,
                  child: Text(region),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Species Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: InputDecoration(
                  labelText: 'Species',
                  prefixIcon: const Icon(
                    Icons.pets_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _species
                    .map((species) => DropdownMenuItem(
                  value: species,
                  child: Text(species),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Results Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Results (${_filteredReturns.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedStatus = 'All';
                        _selectedRegion = 'All Regions';
                        _selectedSpecies = 'All Species';
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Results List
              if (_filteredReturns.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.lightGrey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No returns found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search criteria',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _filteredReturns
                      .map(
                    (item) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppColors.lightGrey,
                        ),
                      ),
                      child: InkWell(
                        onTap: () =>
                            context.push('/officer-dashboard/return-details/1'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['species']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(item['status']!)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _getStatusColor(
                                            item['status']!),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item['status']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(
                                            item['status']!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColors.mediumGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['hunter']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.mediumGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['region']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: AppColors.mediumGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['date']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.pending;
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      default:
        return AppColors.mediumGrey;
    }
  }
}
