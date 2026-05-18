// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// ============================================================
// input_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bmi_calculator.dart';
import 'result_page.dart';

// ── Palet warna utama (ungu – teal, serasi dengan result_page) ──────────────
const _kPrimaryDark   = Color(0xFF3D3399); // ungu gelap (AppBar pinned)
const _kPrimary       = Color(0xFF5B4FCF); // ungu utama
const _kPrimaryLight  = Color(0xFF7B6EE0); // ungu terang (gradient ujung)
const _kPrimaryBg     = Color(0xFFEEF0FF); // ungu sangat pucat (info box)

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage>
    with SingleTickerProviderStateMixin {
  final _formKey         = GlobalKey<FormState>();
  final _namaController  = TextEditingController();
  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();

  String? _selectedKategoriUsia;
  String  _selectedGender = 'Laki-laki';

  final List<RiwayatBmi> _riwayat = [];

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;

  final List<String> _kategoriUsia = [
    'Anak-anak (6–12)',
    'Remaja (13–17)',
    'Dewasa (18+)',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _namaController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  void _hitungBmi() {
    if (_formKey.currentState!.validate()) {
      final berat  = double.parse(_beratController.text);
      final tinggi = double.parse(_tinggiController.text);

      final kalkulator = BmiCalculator(
        beratKg: berat,
        tinggiCm: tinggi,
        gender: _selectedGender,
        kategoriUsia: _selectedKategoriUsia!,
      );

      setState(() {
        _riwayat.insert(
          0,
          RiwayatBmi(
            nama: _namaController.text,
            bmi: kalkulator.nilaiBmi,
            kategori: kalkulator.kategoriBmi,
            tanggal: DateTime.now(),
            gender: _selectedGender,
          ),
        );
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            nama: _namaController.text,
            kalkulator: kalkulator,
            riwayat: _riwayat,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan gradient ungu ──
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: _kPrimaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kPrimary, _kPrimaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.monitor_weight_outlined,
                                    color: Colors.white, size: 28),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kalkulator BMI',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  Text('Body Mass Index Calculator',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              _buildInfoChip(Icons.people, 'WHO Standard'),
                              SizedBox(width: 8),
                              _buildInfoChip(Icons.science, 'Rumus Devine'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Konten Form ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('👤 Data Pribadi'),
                    SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _namaController,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama kamu',
                            icon: Icons.person_outline,
                            capitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Nama tidak boleh kosong'
                                : null,
                          ),
                          SizedBox(height: 16),
                          Text('Jenis Kelamin',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderButton(
                                  label: 'Laki-laki',
                                  icon: Icons.male,
                                  isSelected: _selectedGender == 'Laki-laki',
                                  // ungu untuk laki-laki agar serasi
                                  color: _kPrimary,
                                  onTap: () => setState(
                                      () => _selectedGender = 'Laki-laki'),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildGenderButton(
                                  label: 'Perempuan',
                                  icon: Icons.female,
                                  isSelected: _selectedGender == 'Perempuan',
                                  color: Color(0xFFD4537E), // pink coral
                                  onTap: () => setState(
                                      () => _selectedGender = 'Perempuan'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            validator: (v) =>
                                (v == null) ? 'Pilih kategori usia' : null,
                            value: _selectedKategoriUsia,
                            decoration: InputDecoration(
                              labelText: 'Kategori Usia',
                              prefixIcon: Icon(Icons.cake_outlined,
                                  color: _kPrimary),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: _kPrimary, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            hint: Text('Pilih kategori usia...'),
                            items: _kategoriUsia
                                .map((k) =>
                                    DropdownMenuItem(value: k, child: Text(k)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedKategoriUsia = v),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    _buildSectionLabel('📏 Data Tubuh'),
                    SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildNumberField(
                            controller: _beratController,
                            label: 'Berat Badan',
                            hint: 'Contoh: 65',
                            icon: Icons.monitor_weight_outlined,
                            suffix: 'kg',
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Masukkan berat badan';
                              final n = double.tryParse(v);
                              if (n == null || n < 10 || n > 300)
                                return 'Nilai valid: 10–300 kg';
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildNumberField(
                            controller: _tinggiController,
                            label: 'Tinggi Badan',
                            hint: 'Contoh: 170',
                            icon: Icons.height,
                            suffix: 'cm',
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Masukkan tinggi badan';
                              final n = double.tryParse(v);
                              if (n == null || n < 50 || n > 250)
                                return 'Nilai valid: 50–250 cm';
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          // Info box dengan warna ungu muda
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _kPrimaryBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: _kPrimary, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'BMI Normal: 18.5 – 24.9\nRumus: Berat (kg) ÷ Tinggi² (m)',
                                    style: TextStyle(
                                        fontSize: 12, color: _kPrimaryDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    if (_riwayat.isNotEmpty) ...[
                      _buildSectionLabel('🕐 Riwayat Terakhir'),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              _riwayat.length > 5 ? 5 : _riwayat.length,
                          itemBuilder: (context, index) =>
                              _buildRiwayatCard(_riwayat[index]),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _hitungBmi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                          shadowColor: _kPrimary.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Hitung BMI Sekarang',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800]));
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _kPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kPrimary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _kPrimary),
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kPrimary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 22),
            SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(RiwayatBmi item) {
    final warna = Color(item.bmi < 18.5
        ? 0xFF2196F3
        : item.bmi < 25
            ? 0xFF1D9E75 // teal serasi
            : item.bmi < 30
                ? 0xFFFF9800
                : 0xFFF44336);

    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warna.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.nama.split(' ').first,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis),
          Text(item.bmi.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: warna)),
          Text(item.kategori.split(' ').last,
              style: TextStyle(fontSize: 10, color: warna)),
        ],
      ),
    );
  }
}