import 'package:flutter/material.dart';
import '../models/approve_with_quantity_command.dart';
import '../models/order_line_cancel_dto.dart';
import '../models/orders_by_customer_vm.dart';
import '../services/api/orders_api.dart';

class ApproveOrderScreen extends StatefulWidget {
  final OrdersByCustomerVM order;
  const ApproveOrderScreen({super.key, required this.order});

  @override
  State<ApproveOrderScreen> createState() => _ApproveOrderScreenState();
}

class _ApproveOrderScreenState extends State<ApproveOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = OrdersApi();

  // Form elemanları ve state'leri
  late TextEditingController _quantityController;
  final _commentController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Miktar alanını orijinal sipariş miktarıyla başlat
    _quantityController = TextEditingController(text: widget.order.quantity.toStringAsFixed(2));
  }

  Future<void> _submitApproval() async {
    // Form geçerliyse ve zaten bir istek gönderilmiyorsa devam et
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() { _isSubmitting = true; });

      try {
        final command = ApproveWithQuantityCommand(
          comment: _commentController.text,
          orderLines: [
            OrderLineCancelDto(
              lineId: widget.order.orderId,
              quantity: double.parse(_quantityController.text),
            ),
          ],
        );

        final success = await _apiService.approveOrderWithQuantity(command);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş başarıyla onaylandı!'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: Text('Sipariş Onayla: ${widget.order.code}')),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Miktar Alanı
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: 'Onaylanacak Miktar (${widget.order.unit})', border: const OutlineInputBorder()),
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
                    // Onayla Butonu
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitApproval,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('ONAYLA'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}