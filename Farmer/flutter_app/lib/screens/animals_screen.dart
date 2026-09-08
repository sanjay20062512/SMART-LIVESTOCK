// Animals Screen — lists all registered animals with search and filter.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/animal.dart';
import '../models/herd.dart';
import 'add_animal_screen.dart';
import 'animal_details_screen.dart';

class AnimalsScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const AnimalsScreen({super.key, required this.dataService});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  HealthStatus? _filterStatus;
  AnimalSpecies? _filterSpecies;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() {}));
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  List<Animal> get _filteredAnimals {
    final q = _searchCtrl.text.toLowerCase();
    return widget.dataService.getAnimals().where((a) {
      final matchSearch = q.isEmpty ||
          a.earTag.toLowerCase().contains(q) ||
          a.breed.toLowerCase().contains(q) ||
          a.species.displayName.toLowerCase().contains(q);
      final matchStatus =
          _filterStatus == null || a.healthStatus == _filterStatus;
      final matchSpecies =
          _filterSpecies == null || a.species == _filterSpecies;
      return matchSearch && matchStatus && matchSpecies;
    }).toList();
  }

  void _openAddAnimal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAnimalScreen(dataService: widget.dataService),
      ),
    );
  }

  void _openDetails(Animal animal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalDetailsScreen(
          animalId: animal.id,
          dataService: widget.dataService,
        ),
      ),
    );
  }

  void _confirmDelete(Animal animal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Animal'),
        content: Text(
          'Remove ${animal.species.displayName} — ${animal.earTag}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.dataService.removeAnimal(animal.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${animal.earTag} removed.')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Animals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Health Status'),
                Wrap(
                  spacing: 8,
                  children: HealthStatus.values.map((s) {
                    return FilterChip(
                      label: Text(s.displayName),
                      selected: _filterStatus == s,
                      onSelected: (v) {
                        setSheetState(
                          () => _filterStatus = v ? s : null,
                        );
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Species'),
                Wrap(
                  spacing: 8,
                  children: AnimalSpecies.values.map((s) {
                    return FilterChip(
                      label: Text(s.displayName),
                      selected: _filterSpecies == s,
                      onSelected: (v) {
                        setSheetState(
                          () => _filterSpecies = v ? s : null,
                        );
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setSheetState(() {
                        _filterStatus = null;
                        _filterSpecies = null;
                      });
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear Filters'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final animals = _filteredAnimals;
    final total = widget.dataService.getAnimals().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Animals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Individual'),
            Tab(text: 'Herds'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Individual Animals tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search by tag, breed or species...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Showing ${animals.length} of $total animals',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: animals.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No animals found.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first animal using the + button.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: animals.length,
                        itemBuilder: (ctx, i) =>
                            _AnimalCard(
                          animal: animals[i],
                          onView: () => _openDetails(animals[i]),
                          onEdit: () => _openDetails(animals[i]),
                          onDelete: () => _confirmDelete(animals[i]),
                        ),
                      ),
              ),
            ],
          ),

          // Herds tab
          _HerdsTab(dataService: widget.dataService),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAnimal,
        icon: const Icon(Icons.add),
        label: const Text('Add Animal'),
        tooltip: 'Add a new animal',
      ),
    );
  }
}

// ─── Animal Card ─────────────────────────────────────────────────────────────

class _AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnimalCard({
    required this.animal,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor(HealthStatus s) {
    switch (s) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.underMonitoring:
        return Colors.orange;
      case HealthStatus.activeCase:
        return Colors.red;
      case HealthStatus.critical:
        return Colors.red.shade900;
    }
  }

  IconData _speciesIcon(AnimalSpecies s) {
    switch (s) {
      case AnimalSpecies.cow:
      case AnimalSpecies.buffalo:
        return Icons.agriculture;
      case AnimalSpecies.goat:
      case AnimalSpecies.sheep:
        return Icons.pets;
      case AnimalSpecies.poultry:
        return Icons.egg;
      case AnimalSpecies.pig:
        return Icons.set_meal;
      case AnimalSpecies.other:
        return Icons.cruelty_free;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(animal.healthStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(_speciesIcon(animal.species),
                    color: statusColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          animal.earTag,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            animal.healthStatus.displayName,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${animal.species.displayName} · ${animal.breed}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '${animal.gender.displayName} · ${animal.age}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'view') onView();
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'view', child: Text('View Details')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Remove', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Herds Tab ────────────────────────────────────────────────────────────────

class _HerdsTab extends StatelessWidget {
  final FarmerDataService dataService;

  const _HerdsTab({required this.dataService});

  @override
  Widget build(BuildContext context) {
    final herds = dataService.getHerds();
    return herds.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_work, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No herds added yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: herds.length,
            itemBuilder: (ctx, i) {
              final h = herds[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.group_work),
                  ),
                  title: Text(h.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${h.animalType.displayName} · ${h.totalCount} animals · ${h.breed}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      h.healthStatus.displayName,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
