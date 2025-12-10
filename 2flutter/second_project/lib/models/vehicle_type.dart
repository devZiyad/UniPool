enum VehicleType {
  sedan,
  sportsCar,
  stationWagon,
  pickupTruck,
  logisticVan;

  String get displayName {
    switch (this) {
      case VehicleType.sedan:
        return 'Sedan';
      case VehicleType.sportsCar:
        return 'Sports Car';
      case VehicleType.stationWagon:
        return 'Station Wagon';
      case VehicleType.pickupTruck:
        return 'Pickup Truck';
      case VehicleType.logisticVan:
        return 'Logistic Van';
    }
  }

  String get assetPath {
    switch (this) {
      case VehicleType.sedan:
        return 'assets/images/vehicles/sedan-car-icon.svg';
      case VehicleType.sportsCar:
        return 'assets/images/vehicles/sports-car-icon.svg';
      case VehicleType.stationWagon:
        return 'assets/images/vehicles/station-wagon-car-icon.svg';
      case VehicleType.pickupTruck:
        return 'assets/images/vehicles/pickup-truck-icon.svg';
      case VehicleType.logisticVan:
        return 'assets/images/vehicles/logistic-van-icon.svg';
    }
  }

  String get apiValue {
    switch (this) {
      case VehicleType.sedan:
        return 'SEDAN';
      case VehicleType.sportsCar:
        return 'SPORTS';
      case VehicleType.stationWagon:
        return 'SUV';
      case VehicleType.pickupTruck:
        return 'PICKUP';
      case VehicleType.logisticVan:
        return 'VAN';
    }
  }

  static VehicleType? fromString(String? value) {
    if (value == null) return null;

    final upperValue = value.toUpperCase();

    // Try to match by API value first (SPORTS, PICKUP, SEDAN, SUV, VAN)
    try {
      return VehicleType.values.firstWhere((e) => e.apiValue == upperValue);
    } catch (e) {
      // Try to match by name (camelCase) for backward compatibility
      try {
        return VehicleType.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
        );
      } catch (e) {
        return null;
      }
    }
  }
}
