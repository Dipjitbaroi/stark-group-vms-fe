/// Model representing a vehicle record in Stark Group VMS.
/// Contains all 6 required fields:
/// - vehicleNumber
/// - company
/// - type
/// - brand
/// - model
/// - status
class Vehicle {
  final String id;
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final String status; // 'Active' or 'Inactive'
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] != null ? json['id'].toString() : '',
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      company: json['company'] as String? ?? '',
      type: json['type'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleNumber': vehicleNumber,
      'company': company,
      'type': type,
      'brand': brand,
      'model': model,
      'status': status,
    };
  }

  Vehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    String? status,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Initial realistic enterprise mock data for Stark Group VMS.
  static List<Vehicle> get initialMockVehicles => [
        Vehicle(
          id: 'vms-001',
          vehicleNumber: 'STK-8421',
          company: 'Stark Logistics',
          type: 'Heavy Truck',
          brand: 'Volvo',
          model: 'FH16 750',
          status: 'Active',
          createdAt: DateTime(2026, 1, 15),
        ),
        Vehicle(
          id: 'vms-002',
          vehicleNumber: 'STK-2104',
          company: 'Stark Industries',
          type: 'Cargo Van',
          brand: 'Mercedes-Benz',
          model: 'Sprinter 314',
          status: 'Active',
          createdAt: DateTime(2026, 2, 3),
        ),
        Vehicle(
          id: 'vms-003',
          vehicleNumber: 'STK-9055',
          company: 'Apex Fleet Corp',
          type: 'SUV',
          brand: 'Toyota',
          model: 'Land Cruiser 300',
          status: 'Active',
          createdAt: DateTime(2026, 2, 20),
        ),
        Vehicle(
          id: 'vms-004',
          vehicleNumber: 'STK-3312',
          company: 'Stark Logistics',
          type: 'Pickup',
          brand: 'Ford',
          model: 'F-150 Lightning',
          status: 'Active',
          createdAt: DateTime(2026, 3, 1),
        ),
        Vehicle(
          id: 'vms-005',
          vehicleNumber: 'STK-5520',
          company: 'Apex Fleet Corp',
          type: 'Sedan',
          brand: 'Tesla',
          model: 'Model 3 Performance',
          status: 'Inactive',
          createdAt: DateTime(2026, 3, 12),
        ),
        Vehicle(
          id: 'vms-006',
          vehicleNumber: 'STK-7744',
          company: 'Stark Industries',
          type: 'Delivery Truck',
          brand: 'Isuzu',
          model: 'N-Series NPR',
          status: 'Active',
          createdAt: DateTime(2026, 3, 28),
        ),
        Vehicle(
          id: 'vms-007',
          vehicleNumber: 'STK-1198',
          company: 'Stark Logistics',
          type: 'Heavy Hauler',
          brand: 'Scania',
          model: 'R 500 V8',
          status: 'Inactive',
          createdAt: DateTime(2026, 4, 2),
        ),
      ];

  /// Standard vehicle type options for dropdowns.
  static const List<String> standardTypes = [
    'Heavy Truck',
    'Cargo Van',
    'SUV',
    'Pickup',
    'Sedan',
    'Delivery Truck',
    'Heavy Hauler',
    'Electric Fleet',
  ];

  /// Standard company options for dropdowns / autocomplete.
  static const List<String> standardCompanies = [
    'Stark Logistics',
    'Stark Industries',
    'Apex Fleet Corp',
    'Global Transit Ltd',
  ];

  /// Standard status options.
  static const List<String> standardStatuses = [
    'Active',
    'Inactive',
  ];
}
