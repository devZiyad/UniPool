import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/vehicle_type.dart';

class VehicleTypeIcon extends StatelessWidget {
  final VehicleType? vehicleType;
  final double? width;
  final double? height;
  final Color? color;

  const VehicleTypeIcon({
    super.key,
    required this.vehicleType,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicleType == null) {
      return Icon(
        Icons.directions_car,
        size: width ?? height ?? 24,
        color: color ?? Colors.grey,
      );
    }

    // For SVGs, only apply color filter if color is explicitly provided
    // Otherwise, display the SVG in its original colors
    return SvgPicture.asset(
      vehicleType!.assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (BuildContext context) => Icon(
        Icons.directions_car,
        size: width ?? height ?? 24,
        color: color ?? Colors.grey,
      ),
    );
  }
}
