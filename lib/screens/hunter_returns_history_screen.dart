import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Hunter Returns History Screen - View all submitted wildlife returns
class HunterReturnsHistoryScreen extends StatefulWidget {
  const HunterReturnsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<HunterReturnsHistoryScreen> createState() =>
      _HunterReturnsHistoryScreenState();
}

class _HunterReturnsHistoryScreenState
    extends State<HunterReturnsHistoryScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Approved', 'Pending', 'Rejected'];

  final List<Map<String, String>> _returns = [
    {
      'species': 'Oryx',
      'location': 'Kunene Region',
      'date': 'May 1, 2024',
      'status': 'Approved',
    },
    {
      'species': 'Kudu',
      'location': 'Kunene Region',
      'date': 'Apr 28, 2024',
      'status': 'Approved',
    },
    {
      'species': 'Springbok',
      'location': 'Kunene Region',
      'date': 'Apr 15, 2024',
      'status': 'Pending',
    },
    {
      'species': 'Warthog',
      'location': 'Kunene Region',
      'date': 'Mar 20, 2024',
      'status': 'Approved',
    },
  ];

  List<Map<String, String>> get _filteredReturns {
    if (_selectedFilter == 'All') {
      return _returns;
    }
    return _returns.where((item) => item['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returns History'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              const SectionHeader(title: 'Your Returns Summary'),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        label: 'Total',
                        value: '${_returns.length}',
                        icon: Icons.folder_outlined,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        label: 'Approved',
                        value:
                            '${_returns.where((r) => r['status'] == 'Approved').length}',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        label: 'Pending',
                        value:
                            '${_returns.where((r) => r['status'] == 'Pending').length}',
                        icon: Icons.schedule,
                        color: AppColors.pending,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Filter Chips
              const Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _filters
                    .map((filter) => FilterChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  selectedColor:
                      AppColors.primaryGreen.withOpacity(0.2),
                  backgroundColor: AppColors.lightGrey,
                  labelStyle: TextStyle(
                    color: _selectedFilter == filter
                        ? AppColors.primaryGreen
                        : AppColors.mediumGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 28),

              // Results Header
              Text(
                'Returns (${_filteredReturns.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 12),

              // Returns List
              if (_filteredReturns.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
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
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _filteredReturns
                      .map(
                    (item) => ReturnItemCard(
                      species: item['species']!,
                      location: item['location']!,
                      date: item['date']!,
                      status: item['status']!,
                      onTap: () => context
                          .push('/hunter-dashboard/return-status/1'),
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
}
