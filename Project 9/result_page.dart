// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// ============================================================
// result_page.dart
// Halaman hasil BMI — responsif di semua ukuran layar.
// Gauge menggunakan LayoutBuilder agar menyesuaikan lebar.
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/bmi_calculator.dart';

class ResultPage extends StatefulWidget {
  final String nama;
  final BmiCalculator kalkulator;
  final List<RiwayatBmi> riwayat;

  const ResultPage({
    super.key,
    required this.nama,
    required this.kalkulator,
    required this.riwayat,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _gaugeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    );
    _gaugeAnim = Tween<double>(
      begin: 0.0,
      end: widget.kalkulator.posisiGauge,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kalkulator;
    final warna = Color(k.warnaKategori);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ===== AppBar =====
          SliverAppBar(
            pinned: true,
            backgroundColor: warna,
            leading: BackButton(color: Colors.white),
            title: Text('Hasil BMI',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ===== Hero Section =====
                // LayoutBuilder membuat semua isi di dalam ini
                // tahu berapa lebar yang tersedia → responsif!
                LayoutBuilder(
                  builder: (context, constraints) {
                    final lebar = constraints.maxWidth;

                    // Ukuran font & elemen disesuaikan dengan lebar layar
                    final fontBmi = lebar < 400 ? 56.0 : 68.0;
                    final fontNama = lebar < 400 ? 15.0 : 17.0;
                    final fontEmoji = lebar < 400 ? 36.0 : 44.0;

                    // Tinggi gauge proporsional terhadap lebar
                    // Setengah lingkaran → tinggi idealnya ≈ lebar / 2
                    // Kita beri batas bawah & atas agar tidak terlalu kecil/besar
                    final tinggiGauge = (lebar * 0.38).clamp(120.0, 220.0);

                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [warna, warna.withOpacity(0.75)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        children: [
                          // --- Nama ---
                          Text(
                            'Halo, ${widget.nama}!',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: fontNama,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),

                          // --- Emoji ---
                          Text(k.emojiKategori,
                              style: TextStyle(fontSize: fontEmoji)),
                          SizedBox(height: 8),

                          // --- Nilai BMI ---
                          Text(
                            k.nilaiBmi.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontBmi,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'BMI Score',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                          SizedBox(height: 10),

                          // --- Badge Kategori ---
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white38),
                            ),
                            child: Text(
                              k.kategoriBmi,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          SizedBox(height: 24),

                          // --- Gauge (responsif pakai lebar & tinggi dari LayoutBuilder) ---
                          AnimatedBuilder(
                            animation: _gaugeAnim,
                            builder: (context, _) {
                              return CustomPaint(
                                // Ukuran gauge mengikuti lebar container
                                size: Size(lebar - 40, tinggiGauge),
                                painter: BmiGaugePainter(
                                  posisi: _gaugeAnim.value,
                                  warnaKategori: warna,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 4),

                          // --- Label gauge ---
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _labelGauge('Kurus'),
                              _labelGauge('Normal'),
                              _labelGauge('Lebih'),
                              _labelGauge('Obesitas'),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ===== Konten bawah =====
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 3 Stats ---
                      Row(
                        children: [
                          Expanded(
                              child: _statCard(Icons.straighten, 'Tinggi',
                                  '${k.tinggiCm.toStringAsFixed(0)} cm', warna)),
                          SizedBox(width: 10),
                          Expanded(
                              child: _statCard(
                                  Icons.monitor_weight_outlined,
                                  'Berat',
                                  '${k.beratKg.toStringAsFixed(1)} kg',
                                  warna)),
                          SizedBox(width: 10),
                          Expanded(
                              child: _statCard(
                                  k.gender == 'Laki-laki'
                                      ? Icons.male
                                      : Icons.female,
                                  'Gender',
                                  k.gender == 'Laki-laki'
                                      ? 'Pria'
                                      : 'Wanita',
                                  warna)),
                        ],
                      ),
                      SizedBox(height: 20),

                      // --- Berat Ideal ---
                      _sectionLabel('⚖️ Berat Badan Ideal'),
                      SizedBox(height: 10),
                      _card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flag_outlined,
                                    color: warna, size: 28),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Berat Ideal (Rumus Devine)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                      Text(
                                        '${k.beratIdeal.toStringAsFixed(1)} kg',
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: warna),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text('Rentang Normal',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500])),
                                    Text(
                                      '${k.beratMinNormal.toStringAsFixed(1)} – ${k.beratMaksNormal.toStringAsFixed(1)} kg',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(height: 1),
                            SizedBox(height: 10),
                            _selisihBerat(k, warna),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // --- Klasifikasi WHO ---
                      _sectionLabel('📊 Klasifikasi BMI (WHO)'),
                      SizedBox(height: 10),
                      _card(
                        child: Column(children: [
                          _bmiRow('< 18.5', 'Kekurangan Berat Badan',
                              Color(0xFF2196F3),
                              aktif: k.nilaiBmi < 18.5),
                          _bmiRow('18.5 – 24.9', 'Berat Badan Normal',
                              Color(0xFF4CAF50),
                              aktif: k.nilaiBmi >= 18.5 && k.nilaiBmi < 25),
                          _bmiRow('25.0 – 29.9',
                              'Kelebihan Berat Badan', Color(0xFFFF9800),
                              aktif: k.nilaiBmi >= 25 && k.nilaiBmi < 30),
                          _bmiRow('≥ 30.0', 'Obesitas', Color(0xFFF44336),
                              aktif: k.nilaiBmi >= 30, isLast: true),
                        ]),
                      ),
                      SizedBox(height: 20),

                      // --- Tips Kesehatan ---
                      _sectionLabel('💡 Tips Kesehatan'),
                      SizedBox(height: 10),
                      _card(
                        child: Column(
                          children: k.tipsKesehatan
                              .asMap()
                              .entries
                              .map((e) =>
                                  _tipsItem(e.key + 1, e.value, warna))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20),

                      // --- Riwayat ---
                      if (widget.riwayat.length > 1) ...[
                        _sectionLabel('🕐 Semua Riwayat'),
                        SizedBox(height: 10),
                        _card(
                          child: Column(
                            children: widget.riwayat
                                .take(5)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) => _riwayatItem(e.value, e.key))
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],

                      // --- Tombol Hitung Ulang ---
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warna,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                            shadowColor: warna.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 22),
                              SizedBox(width: 10),
                              Text('Hitung Ulang',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helpers

  Widget _labelGauge(String teks) {
    return Text(teks,
        style: TextStyle(color: Colors.white70, fontSize: 11));
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800]));
  }

  Widget _card({required Widget child}) {
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

  Widget _statCard(IconData icon, String label, String value, Color warna) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: warna, size: 22),
          SizedBox(height: 6),
          // FittedBox agar teks tidak overflow di layar sempit
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Text(label,
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _selisihBerat(BmiCalculator k, Color warna) {
    final selisih = k.beratKg - k.beratIdeal;
    final teks = selisih.abs() < 0.5
        ? 'Tepat di berat ideal!'
        : selisih > 0
            ? '${selisih.toStringAsFixed(1)} kg di atas berat ideal'
            : '${selisih.abs().toStringAsFixed(1)} kg di bawah berat ideal';
    final ikon = selisih.abs() < 0.5
        ? Icons.check_circle
        : selisih > 0
            ? Icons.arrow_upward
            : Icons.arrow_downward;
    final warnaStatus =
        selisih.abs() < 0.5 ? Colors.green : warna;

    return Row(
      children: [
        Icon(ikon, color: warnaStatus, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(teks,
              style: TextStyle(
                  fontSize: 13,
                  color: warnaStatus,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _bmiRow(String range, String label, Color warna,
      {bool aktif = false, bool isLast = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: aktif ? warna.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                  width: 13,
                  height: 13,
                  decoration:
                      BoxDecoration(color: warna, shape: BoxShape.circle)),
              SizedBox(width: 10),
              Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontWeight: aktif
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                              aktif ? warna : Colors.grey[700],
                          fontSize: 13))),
              Text(range,
                  style: TextStyle(
                      color: warna,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
              if (aktif) ...[
                SizedBox(width: 6),
                Icon(Icons.check_circle, color: warna, size: 16),
              ],
            ],
          ),
        ),
        if (!isLast) Divider(height: 1),
      ],
    );
  }

  Widget _tipsItem(int index, String tips, Color warna) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration:
                BoxDecoration(color: warna, shape: BoxShape.circle),
            child: Center(
              child: Text('$index',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
              child: Text(tips,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _riwayatItem(RiwayatBmi item, int index) {
    final w = Color(item.bmi < 18.5
        ? 0xFF2196F3
        : item.bmi < 25
            ? 0xFF4CAF50
            : item.bmi < 30
                ? 0xFFFF9800
                : 0xFFF44336);

    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final tgl =
        '${item.tanggal.day} ${bulan[item.tanggal.month]}, ${item.tanggal.hour}:${item.tanggal.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        if (index > 0) Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: w.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(
                    child: Text(item.bmi.toStringAsFixed(0),
                        style: TextStyle(
                            color: w,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nama,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(tgl,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: w.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(item.kategori.split(' ').last,
                    style: TextStyle(
                        color: w,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BmiGaugePainter — Custom painter untuk gauge setengah lingkaran.
//
// Kunci responsif:
// - Size gauge diberikan dari luar (LayoutBuilder di build())
// - Semua koordinat dihitung RELATIF terhadap size.width & size.height
// - Tidak ada nilai piksel yang hardcoded di sini
// ============================================================
class BmiGaugePainter extends CustomPainter {
  final double posisi;       // 0.0 (paling kiri) sampai 1.0 (paling kanan)
  final Color warnaKategori;

  BmiGaugePainter({required this.posisi, required this.warnaKategori});

  @override
  void paint(Canvas canvas, Size size) {
    // Titik pusat jarum = tengah bawah canvas
    final cx = size.width / 2;
    final cy = size.height; // jarum muncul dari titik bawah tengah

    // Radius proporsional terhadap lebar → responsif!
    final radius = size.width * 0.44;

    // Tebal busur proporsional (jangan terlalu tipis di layar besar)
    final strokeWidth = (size.width * 0.055).clamp(10.0, 22.0);

    // ---- Gambar 4 segmen busur warna ----
    final segmenWarna = [
      Color(0xFF2196F3), // Kurus   (kiri)
      Color(0xFF4CAF50), // Normal
      Color(0xFFFF9800), // Lebih
      Color(0xFFF44336), // Obesitas (kanan)
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Setengah lingkaran: dari sudut 180° (kiri) ke 0° (kanan)
    // Dibagi 4 segmen sama rata, masing-masing 45° = π/4 radian
    final gap = 0.03; // celah kecil antar segmen
    for (int i = 0; i < 4; i++) {
      paint.color = segmenWarna[i];
      final startAngle = math.pi + (i * math.pi / 4) + gap / 2;
      final sweepAngle = (math.pi / 4) - gap;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // ---- Gambar jarum ----
    final posisiClamp = posisi.clamp(0.0, 1.0);
    // Sudut dari π (kiri) ke 2π (kanan) mengikuti posisi gauge
    final sudut = math.pi + (posisiClamp * math.pi);

    // Ujung jarum sedikit lebih pendek dari radius busur
    final panjangJarum = radius * 0.88;
    final ujungX = cx + panjangJarum * math.cos(sudut);
    final ujungY = cy + panjangJarum * math.sin(sudut);

    // Garis jarum
    canvas.drawLine(
      Offset(cx, cy),
      Offset(ujungX, ujungY),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Lingkaran pusat jarum (lapisan luar putih)
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = Colors.white);
    // Lingkaran dalam berwarna kategori
    canvas.drawCircle(Offset(cx, cy), 5.5, Paint()..color = warnaKategori);
  }

  @override
  // Painter hanya menggambar ulang jika posisi jarum berubah
  bool shouldRepaint(BmiGaugePainter old) => old.posisi != posisi;
}