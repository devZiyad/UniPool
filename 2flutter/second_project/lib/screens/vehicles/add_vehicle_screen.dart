import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/app_drawer.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  late TextEditingController _plateNumberController;
  late TextEditingController _seatCountController;
  bool _isSubmitting = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.vehicle != null;
    _makeController = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _plateNumberController = TextEditingController(text: widget.vehicle?.plateNumber ?? '');
    _seatCountController = TextEditingController(text: widget.vehicle?.seatCount.toString() ?? '4');
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    _seatCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditMode && widget.vehicle != null) {
        await VehicleService.updateVehicle(
          id: widget.vehicle!.id,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          color: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          seatCount: int.parse(_seatCountController.text),
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully')),
          );
        }
      } else {
        await VehicleService.createVehicle(
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          color: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          seatCount: int.parse(_seatCountController.text),
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Vehicle' : 'Add Vehicle')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make *',
                  hintText: 'e.g., Toyota',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle make';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g., Camry',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g., Blue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number *',
                  hintText: 'e.g., ABC-1234',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seatCountController,
                decoration: const InputDecoration(
                  labelText: 'Seat Count *',
                  hintText: 'e.g., 4',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter seat count';
                  }
                  final count = int.tryParse(value);
                  if (count == null || count < 1) {
                    return 'Please enter a valid seat count';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Update Vehicle' : 'Add Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
