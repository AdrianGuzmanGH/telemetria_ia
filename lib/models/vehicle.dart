class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String plate;
  final String year;
  final String mileage;
  final String engineChangeDate;
  final String brakeChangeDate;
  final String tireChangeDate;
  final String oilChangeDate;      // NUEVO
  final String technicalReviewDate; // NUEVO
  final String tireCondition;       // NUEVO (Bueno, Regular, Malo)
  final String oilBrand;
  final String tireBrand;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.year,
    required this.mileage,
    required this.engineChangeDate,
    required this.brakeChangeDate,
    required this.tireChangeDate,
    required this.oilChangeDate,
    required this.technicalReviewDate,
    required this.tireCondition,
    required this.oilBrand,
    required this.tireBrand,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'model': model,
        'plate': plate,
        'year': year,
        'mileage': mileage,
        'engineChangeDate': engineChangeDate,
        'brakeChangeDate': brakeChangeDate,
        'tireChangeDate': tireChangeDate,
        'oilChangeDate': oilChangeDate,
        'technicalReviewDate': technicalReviewDate,
        'tireCondition': tireCondition,
        'oilBrand': oilBrand,
        'tireBrand': tireBrand,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'],
        brand: json['brand'],
        model: json['model'],
        plate: json['plate'],
        year: json['year'] ?? '',
        mileage: json['mileage'] ?? '0',
        engineChangeDate: json['engineChangeDate'] ?? '',
        brakeChangeDate: json['brakeChangeDate'] ?? '',
        tireChangeDate: json['tireChangeDate'] ?? '',
        oilChangeDate: json['oilChangeDate'] ?? '',
        technicalReviewDate: json['technicalReviewDate'] ?? '',
        tireCondition: json['tireCondition'] ?? 'Bueno',
        oilBrand: json['oilBrand'] ?? '',
        tireBrand: json['tireBrand'] ?? '',
      );
}