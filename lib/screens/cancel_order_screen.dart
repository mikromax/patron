import 'package:flutter/material.dart';
import '../models/base_card_view_model.dart';
import '../models/cancel_with_quantity_command.dart';
import '../models/order_line_cancel_dto.dart';
import '../models/orders_by_customer_vm.dart';
import '../services/api_service.dart';

class CancelOrderScreen extends StatefulWidget {
  final OrdersByCustomerVM order;
  const CancelOrderScreen({super.key, required this.order});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form elemanları ve state'leri
  late TextEditingController _quantityController;
  final _commentController = TextEditingController();
  
  List<BaseCardViewModel>? _cancelReasons;
  BaseCardViewModel? _selectedReason;
  bool _isLoadingReasons = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.order.quantity.toStringAsFixed(2));
    _loadCancelReasons();
  }

  Future<void> _loadCancelReasons() async {
    try {
      final reasons = await _apiService.getOrderCancelReasons();
      setState(() {
        _cancelReasons = reasons;
        if (reasons.isNotEmpty) {
          _selectedReason = reasons.first;
        }
        _isLoadingReasons = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İptal nedenleri yüklenemedi: $e')));
      setState(() { _isLoadingReasons = false; });
    }
  }

  Future<void> _submitCancellation() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() { _isSubmitting = true; });

      try {
        final command = CancelWithQuantityCommand(
          reasonCode: _selectedReason!.code,
          comment: _commentController.text,
          orderLines: [
            OrderLineCancelDto(
              lineId: widget.order.orderId,
              quantity: double.parse(_quantityController.text),
            ),
          ],
        );

        final success = await _apiService.cancelOrderWithQuantity(command);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş başarıyla kapatıldı!'), backgroundColor: Colors.green));
          // Bir önceki sayfaya başarılı bilgisini göndererek kapat
          Navigator.pop(context, true); 
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) {
          setState(() { _isSubmitting = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sipariş Kapat: ${widget.order.code}')),
      body: _isLoadingReasons
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İptal Nedeni Lookup
                    DropdownButtonFormField<BaseCardViewModel>(
                      initialValue: _selectedReason,
                      decoration: const InputDecoration(labelText: 'Kapatma Nedeni', border: OutlineInputBorder()),
                      items: _cancelReasons?.map((reason) {
                        return DropdownMenuItem<BaseCardViewModel>(
                          value: reason,
                          child: Text(reason.description),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedReason = value),
                      validator: (value) => value == null ? 'Lütfen bir neden seçin.' : null,
                    ),
                    const SizedBox(height: 16),
                    // Miktar Alanı
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: 'Miktar (${widget.order.unit})', border: const OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Miktar boş olamaz.';
                        final quantity = double.tryParse(value);
                        if (quantity == null) return 'Geçersiz sayı formatı.';
                        if (quantity <= 0) return 'Miktar 0\'dan büyük olmalı.';
                        if (quantity > widget.order.quantity) return 'Miktar, orijinal miktardan (${widget.order.quantity}) büyük olamaz.';
                        return null;
                      },
                      
                    ),
                    const SizedBox(height: 16),
                    // Yorum Alanı
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(labelText: 'Açıklama (Opsiyonel)', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // İptal Et Butonu
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitCancellation,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('SİPARİŞİ KAPAT'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}