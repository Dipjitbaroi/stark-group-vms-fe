import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_exception.dart';
import '../services/auth_api_service.dart';
import '../services/session_service.dart';
import '../services/vehicle_api_service.dart';

/// Central state manager for Stark Group VMS.
/// Communicates through the API service layer to persist and fetch real MySQL data.
class VmsState extends ChangeNotifier {
  final AuthApiService _authApiService;
  final VehicleApiService _vehicleApiService;
  final SessionService _sessionService;

  bool _isAuthenticated;
  bool _isSessionRestored;
  String _currentUser = '';
  String? _authToken;

  bool _isLoadingVehicles = false;
  String? _vehiclesError;

  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  String _companyFilter = 'All';

  final List<Vehicle> _vehicles = [];

  VmsState({
    AuthApiService? authApiService,
    VehicleApiService? vehicleApiService,
    SessionService? sessionService,
    bool initialAuthenticated = false,
  })  : _authApiService = authApiService ?? AuthApiService(),
        _vehicleApiService = vehicleApiService ?? VehicleApiService(),
        _sessionService = sessionService ?? SessionService(),
        _isAuthenticated = initialAuthenticated,
        _isSessionRestored = initialAuthenticated {
    if (_isAuthenticated) {
      fetchVehicles();
    } else {
      restoreSession();
    }
  }

  // --- Getters ---

  bool get isAuthenticated => _isAuthenticated;
  bool get isSessionRestored => _isSessionRestored;
  String get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoadingVehicles => _isLoadingVehicles;
  String? get vehiclesError => _vehiclesError;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get companyFilter => _companyFilter;

  List<Vehicle> get allVehicles => List.unmodifiable(_vehicles);

  /// Filtered vehicles based on search query, status, and company.
  List<Vehicle> get filteredVehicles {
    return _vehicles.where((v) {
      // Status filter
      if (_statusFilter != 'All' && v.status.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }
      // Company filter
      if (_companyFilter != 'All' && v.company != _companyFilter) {
        return false;
      }
      // Search query (vehicle number, brand, model, company, type)
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchesNumber = v.vehicleNumber.toLowerCase().contains(q);
        final matchesBrand = v.brand.toLowerCase().contains(q);
        final matchesModel = v.model.toLowerCase().contains(q);
        final matchesCompany = v.company.toLowerCase().contains(q);
        final matchesType = v.type.toLowerCase().contains(q);
        if (!matchesNumber && !matchesBrand && !matchesModel && !matchesCompany && !matchesType) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get totalCount => _vehicles.length;
  int get activeCount => _vehicles.where((v) => v.isActive).length;
  int get inactiveCount => _vehicles.where((v) => !v.isActive).length;

  // --- Actions ---

  /// Restore persisted session from SharedPreferences / localStorage on page reload
  Future<void> restoreSession() async {
    try {
      final session = await _sessionService.getSession();
      if (session != null && session['token'] != null && session['token']!.isNotEmpty) {
        _authToken = session['token'];
        _currentUser = session['user'] ?? '';
        _isAuthenticated = true;
        await fetchVehicles();
      }
    } catch (_) {
      // Ignored if storage unavailable
    } finally {
      _isSessionRestored = true;
      notifyListeners();
    }
  }

  /// Real backend login validation via POST /api/auth/login
  Future<void> login(String emailOrUsername, String password) async {
    final response = await _authApiService.login(emailOrUsername, password);
    _authToken = response['token']?.toString();
    _currentUser = (response['emailOrUsername'] ?? emailOrUsername).toString();
    _isAuthenticated = true;

    // Persist session into browser local storage
    if (_authToken != null) {
      await _sessionService.saveSession(
        token: _authToken!,
        emailOrUsername: _currentUser,
      );
    }

    notifyListeners();

    // Fetch initial fleet records upon successful sign-in
    await fetchVehicles();
  }

  /// Logout and clear user credentials and cached vehicles
  void logout() async {
    _isAuthenticated = false;
    _authToken = null;
    _currentUser = '';
    _vehicles.clear();
    _vehiclesError = null;
    _searchQuery = '';
    _statusFilter = 'All';
    _companyFilter = 'All';
    await _sessionService.clearSession();
    notifyListeners();
  }

  /// Fetch vehicles from real REST API: GET /api/vehicles
  Future<void> fetchVehicles() async {
    _isLoadingVehicles = true;
    _vehiclesError = null;
    notifyListeners();

    try {
      final list = await _vehicleApiService.getAllVehicles(token: _authToken);
      _vehicles.clear();
      _vehicles.addAll(list);
    } on ApiException catch (e) {
      _vehiclesError = e.message;
    } catch (e) {
      _vehiclesError = 'Unable to connect to VMS backend server. Please check your connection.';
    } finally {
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  /// Find a vehicle by its unique id from in-memory cache
  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Register a new vehicle: POST /api/vehicles
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final created = await _vehicleApiService.createVehicle(vehicle, token: _authToken);
    _vehicles.insert(0, created);
    notifyListeners();
    return created;
  }

  /// Update an existing vehicle: PUT /api/vehicles/{id}
  Future<Vehicle> updateVehicle(Vehicle updatedVehicle) async {
    final updated = await _vehicleApiService.updateVehicle(
      updatedVehicle.id,
      updatedVehicle,
      token: _authToken,
    );
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
    } else {
      _vehicles.insert(0, updated);
    }
    notifyListeners();
    return updated;
  }

  /// Delete a vehicle: DELETE /api/vehicles/{id}
  Future<bool> deleteVehicle(String id) async {
    await _vehicleApiService.deleteVehicle(id, token: _authToken);
    final before = _vehicles.length;
    _vehicles.removeWhere((v) => v.id == id);
    final removed = _vehicles.length < before;
    if (removed) {
      notifyListeners();
    }
    return removed;
  }

  /// Set search query.
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// Set status filter ('All', 'Active', 'Inactive').
  void setStatusFilter(String status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      notifyListeners();
    }
  }

  /// Set company filter ('All' or company name).
  void setCompanyFilter(String company) {
    if (_companyFilter != company) {
      _companyFilter = company;
      notifyListeners();
    }
  }
}

/// Inherited widget for providing [VmsState] down the widget tree.
class VmsScope extends InheritedNotifier<VmsState> {
  const VmsScope({
    super.key,
    required VmsState state,
    required super.child,
  }) : super(notifier: state);

  static VmsState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VmsScope>();
    assert(scope != null, 'No VmsScope found in context');
    return scope!.notifier!;
  }
}
