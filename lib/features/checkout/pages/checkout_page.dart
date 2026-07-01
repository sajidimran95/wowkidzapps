import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/saved_address.dart';
import 'package:my_first_app/data/models/shipping_settings.dart';
import 'package:my_first_app/features/checkout/pages/order_success_page.dart';
import 'package:my_first_app/features/dashboard/pages/address_form_page.dart';
import 'package:my_first_app/shared/utils/cart_auth.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';
import 'package:my_first_app/shared/widgets/order_summary_card.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Dhaka');
  String _paymentMethod = 'cod';
  bool _isPlacingOrder = false;
  bool _loadingAddresses = false;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    AppController.instance.ensureDefaultShippingOption();
    _bootstrapCheckout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppController.instance.items.isEmpty) {
        Navigator.pop(context);
        showCartMessage(context, 'Your cart is empty. Add items first.');
      }
    });
  }

  Future<void> _bootstrapCheckout() async {
    final controller = AppController.instance;
    final catalog = CatalogStore.instance;

    if (!catalog.guestCheckoutEnabled && !controller.isLoggedIn) {
      if (!mounted) return;
      final allowed = await ensureCheckoutAccess(context);
      if (!allowed && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (controller.isLoggedIn) {
      setState(() => _loadingAddresses = true);
      await controller.loadCustomerData();
      if (!mounted) return;
      setState(() => _loadingAddresses = false);
      _selectDefaultAddress(controller);
    } else {
      _prefillShipping();
    }
  }

  void _selectDefaultAddress(AppController controller) {
    if (controller.addresses.isEmpty) {
      _prefillShipping();
      return;
    }

    SavedAddress? selected;
    if (_selectedAddressId != null) {
      selected = controller.addresses
          .where((a) => a.id == _selectedAddressId)
          .firstOrNull;
    }
    selected ??= controller.addresses.where((a) => a.isDefault).firstOrNull;
    selected ??= controller.addresses.first;

    _selectedAddressId = selected.id;
    _applyAddress(selected);
  }

  void _applyAddress(SavedAddress address) {
    _nameController.text = address.fullName;
    _phoneController.text = address.phone;
    _addressController.text = address.addressLine;
    _cityController.text = address.city;
  }

  Future<void> _addAnotherAddress() async {
    final newId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddressFormPage()),
    );
    if (!mounted || newId == null) return;

    await AppController.instance.loadCustomerData();
    if (!mounted) return;

    setState(() => _selectedAddressId = newId);
    _selectDefaultAddress(AppController.instance);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _prefillShipping() {
    final controller = AppController.instance;
    final address = controller.addresses
            .where((a) => a.isDefault)
            .firstOrNull ??
        controller.addresses.firstOrNull;

    if (address != null) {
      _nameController.text = address.fullName;
      _phoneController.text = address.phone;
      _addressController.text = address.addressLine;
      _cityController.text = address.city;
      return;
    }

    if (controller.isLoggedIn) {
      _nameController.text = controller.userName ?? '';
      _phoneController.text = controller.userPhone ?? '';
    }
  }

  Future<void> _placeOrder(AppController controller) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    final order = await controller.placeOrder(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      paymentMethod: _paymentLabel(_paymentMethod),
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (order == null) {
      showCartMessage(context, 'Could not place order. Please try again.');
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderSuccessPage(
          orderId: order.id,
          total: order.total,
          paymentMethod: order.paymentMethod,
          paymentStatus: order.paymentStatus,
        ),
      ),
    );

    controller.clearCart();
  }

  String _paymentLabel(String method) => switch (method) {
        'cod' => 'Cash on Delivery',
        'bkash' => 'bKash',
        'card' => 'Card / Online',
        _ => 'Cash on Delivery',
      };

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    final shippingOptions = controller.shippingSettings.options;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Checkout')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: 'Shipping Address',
                  icon: Icons.location_on_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_loadingAddresses)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else if (controller.isLoggedIn &&
                          controller.addresses.isNotEmpty) ...[
                        ...controller.addresses.map((address) {
                          final selected = _selectedAddressId == address.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() => _selectedAddressId = address.id);
                                _applyAddress(address);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                  color: selected
                                      ? AppColors.primary.withValues(alpha: 0.05)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Radio<String>(
                                      value: address.id,
                                      groupValue: _selectedAddressId,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _selectedAddressId = value);
                                        _applyAddress(address);
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                address.label,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                              if (address.isDefault) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success
                                                        .withValues(alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                  child: const Text(
                                                    'Default',
                                                    style: TextStyle(
                                                      color: AppColors.success,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            address.fullName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            address.phone,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            address.fullAddress,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        OutlinedButton.icon(
                          onPressed: _addAnotherAddress,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('Add Another Address'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Delivery details',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                      ] else if (controller.isLoggedIn) ...[
                        Text(
                          'No saved address yet. Add one to continue faster.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _addAnotherAddress,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('Add Address'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _InputField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.length < 11
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        controller: _addressController,
                        label: 'Full Address',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter your address' : null,
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        controller: _cityController,
                        label: 'City / District',
                        icon: Icons.location_city_outlined,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter your city' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Delivery Area',
                  icon: Icons.local_shipping_outlined,
                  child: shippingOptions.isEmpty
                      ? Text(
                          'Shipping options will load from the store settings.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : _ShippingOptionsSelector(
                          options: shippingOptions,
                          selectedId: controller.selectedShippingId,
                          formatPrice: controller.formatPrice,
                          freeShipping: controller.qualifiesForFreeShipping,
                          onChanged: controller.setShippingOption,
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Payment Method',
                  icon: Icons.payment_outlined,
                  child: Column(
                    children: [
                      _PaymentTile(
                        title: 'Cash on Delivery',
                        subtitle: 'Pay when you receive',
                        icon: Icons.money_outlined,
                        value: 'cod',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      const SizedBox(height: 8),
                      _PaymentTile(
                        title: 'bKash',
                        subtitle: 'Mobile payment',
                        icon: Icons.account_balance_wallet_outlined,
                        value: 'bkash',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      const SizedBox(height: 8),
                      _PaymentTile(
                        title: 'Card / Online',
                        subtitle: 'Visa, Mastercard, Nagad',
                        icon: Icons.credit_card_outlined,
                        value: 'card',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OrderSummaryCard(
                  subtotal: controller.subtotal,
                  shipping: controller.shipping,
                  discount: controller.discount,
                  total: controller.total,
                  formatPrice: controller.formatPrice,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isPlacingOrder
                    ? null
                    : () => _placeOrder(controller),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Place Order • ${controller.formatPrice(controller.total)}',
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _ShippingOptionsSelector extends StatelessWidget {
  const _ShippingOptionsSelector({
    required this.options,
    required this.selectedId,
    required this.formatPrice,
    required this.freeShipping,
    required this.onChanged,
  });

  final List<ShippingOption> options;
  final String? selectedId;
  final String Function(double) formatPrice;
  final bool freeShipping;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (freeShipping)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Free shipping applied to this order',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ...options.map((option) {
          final selected = selectedId == option.id;
          final priceLabel =
              freeShipping ? 'FREE' : formatPrice(option.price);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onChanged(option.id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      priceLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: freeShipping
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Radio<String>(
                      value: option.id,
                      groupValue: selectedId,
                      onChanged: (value) => onChanged(value),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
