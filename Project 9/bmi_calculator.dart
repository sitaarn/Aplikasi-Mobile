// ============================================================
// bmi_calculator.dart
// Berisi semua logika perhitungan BMI dan data pendukung.
// Dipisah dari UI agar kode lebih rapi (separation of concerns).
// ============================================================

class BmiCalculator {
  final double beratKg;
  final double tinggiCm;
  final String gender;
  final String kategoriUsia;

  BmiCalculator({
    required this.beratKg,
    required this.tinggiCm,
    required this.gender,
    required this.kategoriUsia,
  });

  // --- Getter: hitung nilai BMI ---
  double get nilaiBmi {
    final tinggiMeter = tinggiCm / 100;
    return beratKg / (tinggiMeter * tinggiMeter);
  }

  // --- Getter: kategori BMI berdasarkan nilai ---
  String get kategoriBmi {
    if (nilaiBmi < 18.5) return 'Kekurangan Berat Badan';
    if (nilaiBmi < 25.0) return 'Berat Badan Normal';
    if (nilaiBmi < 30.0) return 'Kelebihan Berat Badan';
    return 'Obesitas';
  }

  // --- Getter: warna sesuai kategori ---
  // Mengembalikan kode hex agar bisa dipakai di Color(0xFF...)
  int get warnaKategori {
    if (nilaiBmi < 18.5) return 0xFF2196F3; // Biru
    if (nilaiBmi < 25.0) return 0xFF4CAF50; // Hijau
    if (nilaiBmi < 30.0) return 0xFFFF9800; // Oranye
    return 0xFFF44336;                       // Merah
  }

  // --- Getter: emoji sesuai kategori ---
  String get emojiKategori {
    if (nilaiBmi < 18.5) return '🥗';
    if (nilaiBmi < 25.0) return '✅';
    if (nilaiBmi < 30.0) return '⚠️';
    return '🚨';
  }

  // --- Hitung berat badan ideal (rumus Devine) ---
  // Laki-laki: 50 + 2.3 * (tinggi_inch - 60)
  // Perempuan: 45.5 + 2.3 * (tinggi_inch - 60)
  double get beratIdeal {
    final tinggiInch = tinggiCm / 2.54;
    if (gender == 'Laki-laki') {
      return 50 + 2.3 * (tinggiInch - 60);
    } else {
      return 45.5 + 2.3 * (tinggiInch - 60);
    }
  }

  // --- Rentang berat normal (BMI 18.5 - 24.9) ---
  double get beratMinNormal {
    final tinggiMeter = tinggiCm / 100;
    return 18.5 * (tinggiMeter * tinggiMeter);
  }

  double get beratMaksNormal {
    final tinggiMeter = tinggiCm / 100;
    return 24.9 * (tinggiMeter * tinggiMeter);
  }

  // --- Tips kesehatan berdasarkan kategori ---
  List<String> get tipsKesehatan {
    if (nilaiBmi < 18.5) {
      return [
        'Tingkatkan asupan kalori secara bertahap',
        'Konsumsi protein tinggi: telur, ayam, ikan',
        'Lakukan latihan kekuatan (resistance training)',
        'Makan 5–6 kali sehari dalam porsi kecil',
        'Konsultasikan dengan ahli gizi',
      ];
    } else if (nilaiBmi < 25.0) {
      return [
        'Pertahankan pola makan seimbang',
        'Olahraga minimal 30 menit per hari',
        'Cukup istirahat 7–8 jam per malam',
        'Minum air putih minimal 8 gelas sehari',
        'Lakukan check-up kesehatan rutin',
      ];
    } else if (nilaiBmi < 30.0) {
      return [
        'Kurangi konsumsi gula dan makanan olahan',
        'Olahraga kardio minimal 150 menit per minggu',
        'Perbanyak sayur dan buah-buahan',
        'Hindari makan larut malam',
        'Pantau berat badan setiap minggu',
      ];
    } else {
      return [
        'Segera konsultasi dengan dokter atau ahli gizi',
        'Mulai program diet terstruktur',
        'Hindari makanan berlemak dan tinggi gula',
        'Mulai olahraga ringan seperti jalan kaki',
        'Pantau tekanan darah dan gula darah secara rutin',
      ];
    }
  }

  // --- Posisi jarum gauge (0.0 = kiri, 1.0 = kanan) ---
  // BMI 10 → 0.0, BMI 40 → 1.0
  double get posisiGauge {
    final nilai = nilaiBmi.clamp(10.0, 40.0);
    return (nilai - 10) / 30;
  }
}


// Model untuk menyimpan riwayat perhitungan

class RiwayatBmi {
  final String nama;
  final double bmi;
  final String kategori;
  final DateTime tanggal;
  final String gender;

  RiwayatBmi({
    required this.nama,
    required this.bmi,
    required this.kategori,
    required this.tanggal,
    required this.gender,
  });
}