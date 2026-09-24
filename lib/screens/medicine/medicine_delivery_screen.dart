import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/medicine.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';

class MedicineDeliveryScreen extends StatefulWidget {
  const MedicineDeliveryScreen({super.key});

  @override
  State<MedicineDeliveryScreen> createState() => _MedicineDeliveryScreenState();
}

class _MedicineDeliveryScreenState extends State<MedicineDeliveryScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final List<MedicineItem> _cart = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(MedicineItem item) {
    setState(() {
      _cart.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openCheckoutModal() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your medicine cart is empty! Add items first.')),
      );
      return;
    }

    final provider = Provider.of<PawCareProvider>(context, listen: false);
    final hasPrescriptionItem = _cart.any((i) => i.isPrescriptionRequired);
    final addressController = TextEditingController(text: provider.hospitalsAndClinics.first.address);
    String selectedCaseId = provider.activeCases.first.id;
    bool rxUploaded = hasPrescriptionItem;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalPrice = _cart.fold(0.0, (sum, item) => sum + item.price);

            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medicine Checkout (${_cart.length} items)',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Select Case if needed
                  const Text('Link Animal Case', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCaseId,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: provider.cases.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.id} - ${c.animalType} (${c.condition})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedCaseId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Prescription Check (Requirement #14)
                  if (hasPrescriptionItem)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.orangeContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.orangeLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.assignment_late, color: AppColors.actionOrange, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Prescription Required for this order',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.actionOrange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  rxUploaded ? 'âœ“ Vet Rx Attached (Dr. Prasanna)' : 'Attach Prescription photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: rxUploaded ? AppColors.success : AppColors.textSecondary,
                                    fontWeight: rxUploaded ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setModalState(() {
                                    rxUploaded = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: Text(rxUploaded ? 'Attached' : 'Attach Rx'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  const Text('Delivery Destination Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Medicine Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'â‚¹${totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.actionOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  PawCareButton(
                    text: 'Place Medicine Order',
                    type: PawCareButtonType.orange,
                    onPressed: () {
                      Navigator.pop(context);
                      final newOrder = provider.submitMedicineOrder(
                        caseId: selectedCaseId,
                        items: List.from(_cart),
                        deliveryAddress: addressController.text,
                        prescriptionUrl: hasPrescriptionItem ? 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&w=800&q=80' : '',
                      );

                      setState(() {
                        _cart.clear();
                      });

                      _showOrderConfirmedDialog(context, newOrder);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderConfirmedDialog(BuildContext context, MedicineOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('Order Confirmed', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 6),
            Text('Status: ${order.status.displayName}'),
            const SizedBox(height: 6),
            Text('Total Items: ${order.items.length}'),
            Text('Total Paid: â‚¹${order.totalPrice.toStringAsFixed(0)}'),
            const SizedBox(height: 10),
            const Text(
              'Paws MedExpress runner dispatched to delivery location.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Delivery Tracker'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    final filteredMedicines = provider.medicines.where((m) {
      if (_selectedCategory != 'All' && m.category != _selectedCategory) return false;
      if (_searchController.text.isNotEmpty) {
        return m.name.toLowerCase().contains(_searchController.text.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Veterinary Medicine Store'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _openCheckoutModal,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.actionOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Cart Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search wound spray, antibiotics, first aid...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Wound Care', 'Prescription', 'Supplements', 'First Aid'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Orders Status Timeline Preview Section (Requirement #14)
          if (provider.medicineOrders.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Order Status (${provider.medicineOrders.first.orderId})',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.orangeContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.medicineOrders.first.status.displayName,
                          style: const TextStyle(fontSize: 10, color: AppColors.actionOrange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress mini bar
                  Row(
                    children: List.generate(5, (idx) {
                      final isDone = idx <= provider.medicineOrders.first.status.stepIndex;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.actionOrange : AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

          // Medicines List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final item = filteredMedicines[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      PawCareImage(
                        imageUrl: item.imageUrl,
                        width: 75,
                        height: 75,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.isPrescriptionRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.orangeContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Prescription Required',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.actionOrange),
                                ),
                              ),
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.providerName,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'â‚¹${item.price.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _addToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
