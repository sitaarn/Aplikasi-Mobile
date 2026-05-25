import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// ==================== THEME COLORS ====================
// Mix palette: Lion #C7A07A + Ivory #FDFCE8
class AppColors {
  // Backgrounds
  static const Color base       = Color(0xFFFDFCE8); // Ivory — kartu & body list
  static const Color header     = Color(0xFFC7A07A); // Lion — area header scaffold
  static const Color headerMid  = Color(0xFFDDBE98); // Transisi lion ke ivory (chip, search)
  static const Color chipBg     = Color(0xFFEEE4CC); // Chip non-aktif
  static const Color surface    = Color(0xFFF5F0D8); // Ivory warm — dialog, popup, snackbar
  static const Color shadowDark = Color(0xFFAA8858); // Shadow satu arah

  // Accent
  static const Color accent     = Color(0xFFC7A07A); // Lion — FAB, tombol
  static const Color accentSoft = Color(0xFFE8D5B5); // Lion muda — border, handle

  // Text
  static const Color textPrimary   = Color(0xFF3D2B14); // Cokelat tua
  static const Color textSecondary = Color(0xFF7A5C3A); // Cokelat medium
  static const Color textHint      = Color(0xFFB8966E); // Hint/placeholder
  static const Color textOnHeader  = Color(0xFFFDFCE8); // Ivory — teks di atas Lion

  // Kategori — tidak diubah
  static const Map<String, Color> category = {
    'Elektronik': Color(0xFF6B7FA3),
    'Pakaian'   : Color(0xFFA3756B),
    'Makanan'   : Color(0xFF8A9E6B),
    'Perabot'   : Color(0xFF9B7FA3),
    'Umum'      : Color(0xFFC7A07A),
  };
}

// ==================== NEUMORPHISM BOX ====================
// Dipakai di area IVORY — shadow cokelat hangat satu arah
class NeuBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isPressed;
  final bool isCircle;
  final Color? color;

  const NeuBox({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.isPressed = false,
    this.isCircle = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.base;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [BoxShadow(color: AppColors.shadowDark.withOpacity(0.55), offset: const Offset(3, 3), blurRadius: 6)]
            : [BoxShadow(color: AppColors.shadowDark.withOpacity(0.65), offset: const Offset(6, 6), blurRadius: 14)],
      ),
      child: child,
    );
  }
}

// ==================== APP ====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.header,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
      ),
      home: const ItemListPage(),
    );
  }
}

// ==================== MODEL ====================
class ItemModel {
  final int id;
  String name;
  String description;
  String category;
  DateTime createdAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'] ?? 'Umum',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ==================== CONSTANTS ====================
const List<String> kCategories = ['Semua', 'Elektronik', 'Pakaian', 'Makanan', 'Perabot', 'Umum'];

const Map<String, IconData> kCategoryIcons = {
  'Semua'     : Icons.apps_rounded,
  'Elektronik': Icons.devices_outlined,
  'Pakaian'   : Icons.checkroom_outlined,
  'Makanan'   : Icons.restaurant_outlined,
  'Perabot'   : Icons.chair_outlined,
  'Umum'      : Icons.inventory_2_outlined,
};

// ==================== MAIN PAGE ====================
class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  String _selectedCategory = 'Semua';
  String _sortBy = 'Terbaru';
  bool _isLoading = true;
  bool _isGridView = false;

  final TextEditingController _searchController = TextEditingController();

  final List<ItemModel> _dummyItems = [
    ItemModel(id: 1, name: 'Laptop Gaming', description: 'Laptop dengan GPU RTX 4070, RAM 32GB', category: 'Elektronik', createdAt: DateTime.now().subtract(const Duration(days: 3))),
    ItemModel(id: 2, name: 'Mouse Wireless', description: 'Mouse ergonomis dengan baterai tahan lama', category: 'Elektronik', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ItemModel(id: 3, name: 'Keyboard Mechanical', description: 'Keyboard dengan switch Cherry MX Red', category: 'Elektronik', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ItemModel(id: 4, name: 'Kaos Polos', description: 'Kaos bahan cotton combed 30s', category: 'Pakaian', createdAt: DateTime.now()),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---- DATA ----
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('items_neu');
    if (data != null) {
      List decoded = jsonDecode(data);
      _items = decoded.map((e) => ItemModel.fromJson(e)).toList();
    } else {
      _items = List.from(_dummyItems);
    }
    _applyFilterAndSort();
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('items_neu', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void _applyFilterAndSort() {
    String keyword = _searchController.text.toLowerCase();
    List<ItemModel> result = _items.where((item) {
      bool matchSearch = item.name.toLowerCase().contains(keyword) ||
          item.description.toLowerCase().contains(keyword);
      bool matchCategory = _selectedCategory == 'Semua' || item.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();

    if (_sortBy == 'A-Z') result.sort((a, b) => a.name.compareTo(b.name));
    else if (_sortBy == 'Z-A') result.sort((a, b) => b.name.compareTo(a.name));
    else if (_sortBy == 'Terbaru') result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    else result.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    setState(() => _filteredItems = result);
  }

  Future<void> _addItem(String name, String desc, String category) async {
    int newId = _items.isNotEmpty ? _items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
    _items.add(ItemModel(id: newId, name: name, description: desc, category: category, createdAt: DateTime.now()));
    _applyFilterAndSort();
    await _saveData();
  }

  Future<void> _editItem(ItemModel item, String name, String desc, String category) async {
    setState(() { item.name = name; item.description = desc; item.category = category; });
    _applyFilterAndSort();
    await _saveData();
  }

  Future<void> _deleteItem(ItemModel item) async {
    setState(() => _items.removeWhere((e) => e.id == item.id));
    _applyFilterAndSort();
    await _saveData();
  }

  // ---- HELPERS ----
  SnackBar _neuSnackbar(String msg) => SnackBar(
    content: Text(msg, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
    backgroundColor: AppColors.surface,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.accentSoft),
    ),
  );

  // TextField untuk dialog (di atas surface/ivory)
  Widget _neuTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.base,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.shadowDark.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accentSoft, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ---- DIALOGS ----
  void _showItemDialog({ItemModel? editItem}) {
    final nameCtrl = TextEditingController(text: editItem?.name ?? '');
    final descCtrl = TextEditingController(text: editItem?.description ?? '');
    String selectedCat = editItem?.category ?? 'Umum';
    final isEdit = editItem != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEdit ? 'Edit Item' : 'Item Baru',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, letterSpacing: 0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  isEdit ? 'Ubah informasi item yang ada' : 'Isi detail item yang ingin ditambahkan',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _neuTextField(controller: nameCtrl, label: 'Nama Item', icon: Icons.label_outline),
                const SizedBox(height: 14),
                _neuTextField(controller: descCtrl, label: 'Deskripsi', icon: Icons.notes_rounded, maxLines: 2),
                const SizedBox(height: 20),
                const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: kCategories.where((c) => c != 'Semua').map((cat) {
                    final isSelected = selectedCat == cat;
                    final catColor = AppColors.category[cat] ?? AppColors.accent;
                    return GestureDetector(
                      onTap: () => setModal(() => selectedCat = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? catColor : AppColors.base,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [BoxShadow(color: catColor.withOpacity(0.35), offset: const Offset(0, 4), blurRadius: 8)]
                              : [BoxShadow(color: AppColors.shadowDark.withOpacity(0.45), offset: const Offset(3, 3), blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(kCategoryIcons[cat] ?? Icons.circle, size: 14,
                                color: isSelected ? Colors.white : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(cat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    if (nameCtrl.text.isEmpty || descCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(_neuSnackbar('Nama dan deskripsi wajib diisi!'));
                      return;
                    }
                    Navigator.pop(context);
                    if (isEdit) {
                      _editItem(editItem!, nameCtrl.text, descCtrl.text, selectedCat);
                    } else {
                      _addItem(nameCtrl.text, descCtrl.text, selectedCat);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.accent.withOpacity(0.4), offset: const Offset(0, 6), blurRadius: 14),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Item',
                        style: const TextStyle(color: AppColors.textOnHeader, fontSize: 15,
                            fontWeight: FontWeight.bold, letterSpacing: 0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeuBox(
                isCircle: true, padding: const EdgeInsets.all(18),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFA35555), size: 26),
              ),
              const SizedBox(height: 16),
              const Text('Hapus Item?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('"${item.name}" akan dihapus secara permanen.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: NeuBox(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: const Center(child: Text('Batal', style: TextStyle(
                            color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _deleteItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(_neuSnackbar('${item.name} dihapus'));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA35555),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFFA35555).withOpacity(0.35),
                              offset: const Offset(0, 4), blurRadius: 10)],
                        ),
                        child: const Center(child: Text('Hapus', style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- STAT CARD ----
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          // Ivory semi-transparan di atas Lion
          color: AppColors.base.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.base.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textOnHeader, size: 18),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: AppColors.textOnHeader)),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textOnHeader.withOpacity(0.7),
                fontWeight: FontWeight.w500, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  // ---- LIST ITEM (di atas Ivory) ----
  Widget _buildListItem(ItemModel item) {
    final catColor = AppColors.category[item.category] ?? AppColors.accent;
    final catIcon = kCategoryIcons[item.category] ?? Icons.inventory_2_outlined;

    return Dismissible(
      key: Key('${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFA35555).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA35555).withOpacity(0.25)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFA35555), size: 22),
            SizedBox(height: 4),
            Text('Hapus', style: TextStyle(color: Color(0xFFA35555), fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async { _showDeleteDialog(item); return false; },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: NeuBox(
          borderRadius: 18,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              NeuBox(isCircle: true, padding: const EdgeInsets.all(10),
                  child: Icon(catIcon, color: catColor, size: 20)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(item.description, style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary, height: 1.4),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: catColor.withOpacity(0.25)),
                      ),
                      child: Text(item.category, style: TextStyle(fontSize: 10, color: catColor,
                          fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
                onSelected: (val) {
                  if (val == 'edit') _showItemDialog(editItem: item);
                  if (val == 'delete') _showDeleteDialog(item);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [
                    Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  ])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [
                    Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFA35555)),
                    SizedBox(width: 10),
                    Text('Hapus', style: TextStyle(color: Color(0xFFA35555), fontSize: 13)),
                  ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- GRID ITEM (di atas Ivory) ----
  Widget _buildGridItem(ItemModel item) {
    final catColor = AppColors.category[item.category] ?? AppColors.accent;
    final catIcon = kCategoryIcons[item.category] ?? Icons.inventory_2_outlined;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: NeuBox(
        borderRadius: 18,
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeuBox(isCircle: true, padding: const EdgeInsets.all(10),
                    child: Icon(catIcon, color: catColor, size: 20)),
                const SizedBox(height: 10),
                Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: catColor.withOpacity(0.25)),
                  ),
                  child: Text(item.category, style: TextStyle(fontSize: 10, color: catColor,
                      fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Positioned(
              top: -8, right: -8,
              child: PopupMenuButton<String>(
                color: AppColors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 18),
                onSelected: (val) {
                  if (val == 'edit') _showItemDialog(editItem: item);
                  if (val == 'delete') _showDeleteDialog(item);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [
                    Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  ])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [
                    Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFA35555)),
                    SizedBox(width: 10),
                    Text('Hapus', style: TextStyle(color: Color(0xFFA35555), fontSize: 13)),
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final totalKategori = _items.map((e) => e.category).toSet().length;
    final totalElektronik = _items.where((e) => e.category == 'Elektronik').length;

    return Scaffold(
      backgroundColor: AppColors.header,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ======= HEADER AREA — Lion #C7A07A =======
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Item Manager', style: TextStyle(fontSize: 22,
                              fontWeight: FontWeight.bold, color: AppColors.textOnHeader,
                              letterSpacing: 0.3)),
                          const SizedBox(height: 2),
                          Text('${_items.length} item tersimpan', style: TextStyle(
                              fontSize: 12, color: AppColors.textOnHeader.withOpacity(0.75))),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = !_isGridView),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.base.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.base.withOpacity(0.3)),
                          ),
                          child: Icon(
                            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                            color: AppColors.textOnHeader, size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Stat cards (semi-transparan di atas Lion)
                  Row(
                    children: [
                      _buildStatCard('Total', '${_items.length}', Icons.inventory_2_outlined, AppColors.accent),
                      const SizedBox(width: 10),
                      _buildStatCard('Kategori', '$totalKategori', Icons.category_outlined, AppColors.accent),
                      const SizedBox(width: 10),
                      _buildStatCard('Elektronik', '$totalElektronik', Icons.devices_outlined, AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Search bar — Ivory di atas Lion
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.base,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.shadowDark.withOpacity(0.35),
                          offset: const Offset(0, 4), blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilterAndSort(),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari item...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                                onPressed: () { _searchController.clear(); _applyFilterAndSort(); })
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.accentSoft, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category filter chips — chipBg di atas Lion
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = kCategories[index];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () { setState(() => _selectedCategory = cat); _applyFilterAndSort(); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              // aktif: ivory solid, non-aktif: ivory transparan
                              color: isSelected ? AppColors.base : AppColors.base.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.base : AppColors.base.withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(kCategoryIcons[cat] ?? Icons.apps, size: 12,
                                    color: isSelected ? AppColors.textPrimary : AppColors.textOnHeader),
                                const SizedBox(width: 5),
                                Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.textPrimary : AppColors.textOnHeader)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // ======= CONTENT AREA — Ivory #FDFCE8 =======
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.base,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Sort + result count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_filteredItems.length} hasil', style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w500)),
                          PopupMenuButton<String>(
                            initialValue: _sortBy,
                            color: AppColors.surface,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) { setState(() => _sortBy = val); _applyFilterAndSort(); },
                            child: Row(
                              children: [
                                const Icon(Icons.sort_rounded, size: 15, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(_sortBy, style: const TextStyle(fontSize: 12,
                                    color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textHint),
                              ],
                            ),
                            itemBuilder: (context) => ['Terbaru', 'Terlama', 'A-Z', 'Z-A']
                                .map((s) => PopupMenuItem(value: s, child: Text(s,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    // List / Grid
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(
                              color: AppColors.accent, strokeWidth: 2))
                          : _filteredItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      NeuBox(isCircle: true, padding: const EdgeInsets.all(24),
                                          child: const Icon(Icons.inbox_outlined, size: 40,
                                              color: AppColors.textHint)),
                                      const SizedBox(height: 16),
                                      const Text('Tidak ada item', style: TextStyle(fontSize: 16,
                                          color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      const Text('Coba ubah filter atau tambah item baru',
                                          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                                    ],
                                  ),
                                )
                              : _isGridView
                                  ? GridView.builder(
                                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, crossAxisSpacing: 4,
                                        mainAxisSpacing: 4, childAspectRatio: 0.82,
                                      ),
                                      itemCount: _filteredItems.length,
                                      itemBuilder: (_, i) => _buildGridItem(_filteredItems[i]),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(top: 4, bottom: 100),
                                      itemCount: _filteredItems.length,
                                      itemBuilder: (_, i) => _buildListItem(_filteredItems[i]),
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ---- FAB — Lion dengan ivory text ----
      floatingActionButton: GestureDetector(
        onTap: () => _showItemDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.textPrimary, // Cokelat tua — kontras di atas ivory
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.shadowDark.withOpacity(0.5), offset: const Offset(0, 6), blurRadius: 14),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: AppColors.textOnHeader, size: 20),
              SizedBox(width: 8),
              Text('Tambah Item', style: TextStyle(color: AppColors.textOnHeader,
                  fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}