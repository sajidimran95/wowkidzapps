import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/saved_address.dart';
import 'package:my_first_app/features/dashboard/widgets/dashboard_form_field.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key, this.address});

  final SavedAddress? address;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _labelController.text = address.label;
      _nameController.text = address.fullName;
      _phoneController.text = address.phone;
      _addressController.text = address.addressLine;
      _cityController.text = address.city;
      _districtController.text = address.district;
      _isDefault = address.isDefault;
    } else {
      _districtController.text = 'Dhaka';
      _cityController.text = 'Dhaka';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final controller = AppController.instance;
    final address = SavedAddress(
      id: widget.address?.id ?? controller.nextAddressId(),
      label: _labelController.text.trim(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine: _addressController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      isDefault: _isDefault,
    );

    final error = _isEditing
        ? await controller.updateAddress(address)
        : await controller.addAddress(address);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? (_isEditing ? 'Address updated' : 'Address saved')
              : error,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Address' : 'New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardFormField(
                controller: _labelController,
                label: 'Label',
                hint: 'Home, Office, etc.',
                icon: Icons.label_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Label is required' : null,
              ),
              const SizedBox(height: 16),
              DashboardFormField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Recipient name',
                icon: Icons.person_outline,
                required: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Full name is required' : null,
              ),
              const SizedBox(height: 16),
              DashboardFormField(
                controller: _phoneController,
                label: 'Phone',
                hint: '01XXXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                required: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  if (!RegExp(r'^01\d{9}$').hasMatch(v.trim())) {
                    return 'Enter valid 11-digit mobile';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DashboardFormField(
                controller: _addressController,
                label: 'Address',
                hint: 'House, road, area',
                icon: Icons.home_outlined,
                required: true,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),
              DashboardFormField(
                controller: _cityController,
                label: 'City',
                hint: 'City',
                icon: Icons.location_city_outlined,
                required: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 16),
              DashboardFormField(
                controller: _districtController,
                label: 'District',
                hint: 'District',
                icon: Icons.map_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'District is required' : null,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: const Text('Set as default address'),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Update Address' : 'Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
