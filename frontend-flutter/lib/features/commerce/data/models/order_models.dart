import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';

class OrderItemDto {
  final int produitId;
  final String? produitLabel;
  final int quantity;
  final double? unitPrice;

  const OrderItemDto({
    required this.produitId,
    this.produitLabel,
    required this.quantity,
    this.unitPrice,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      produitId: (json['produitId'] ?? json['productId'] ?? json['idProduit'] ?? 0) as int,
      produitLabel: json['produitLabel']?.toString() ?? json['productLabel']?.toString() ?? json['libelleProduit']?.toString(),
      quantity: (json['quantity'] ?? json['quantite'] ?? 0) as int,
      unitPrice: (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : (json['prixUnitaire'] is num ? (json['prixUnitaire'] as num).toDouble() : null),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'produitId': produitId,
      'quantity': quantity,
    };
  }
}

class OrderAddressDto {
  final String addressLine;
  final double? lat;
  final double? lng;
  final String? instructions;

  const OrderAddressDto({
    required this.addressLine,
    this.lat,
    this.lng,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressLine': addressLine,
      'lat': lat,
      'lng': lng,
      'instructions': instructions,
    };
  }
}

class CustomerOrderDto {
  final int id;
  final String status;
  final String? createdAt;
  final double? totalAmount;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? deliveryInstructions;
  final String? qrData;
  final List<OrderItemDto> items;
  final User? assignedCourier;
  final User? user; // Customer

  const CustomerOrderDto({
    required this.id,
    required this.status,
    this.createdAt,
    this.totalAmount,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryInstructions,
    this.qrData,
    this.items = const [],
    this.assignedCourier,
    this.user,
  });

  factory CustomerOrderDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? (json['orderItems'] as List?) ?? const [];
    return CustomerOrderDto(
      id: (json['id'] ?? json['orderId'] ?? 0) as int,
      status: json['status']?.toString() ?? 'UNKNOWN',
      createdAt: json['createdAt']?.toString() ?? json['dateCreation']?.toString(),
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : (json['total'] is num ? (json['total'] as num).toDouble() : null),
      deliveryAddress: json['deliveryAddress']?.toString() ?? json['adresseLivraison']?.toString(),
      deliveryLat: (json['deliveryLat'] is num) ? (json['deliveryLat'] as num).toDouble() : null,
      deliveryLng: (json['deliveryLng'] is num) ? (json['deliveryLng'] as num).toDouble() : null,
      deliveryInstructions: json['deliveryInstructions']?.toString() ?? json['instructions']?.toString(),
      qrData: json['qrData']?.toString(),
      items: itemsJson.map((e) => OrderItemDto.fromJson(Map<String, dynamic>.from(e))).toList(),
      assignedCourier: json['assignedCourier'] != null ? UserModel.fromJson(json['assignedCourier']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}

class CreateOrderRequest {
  final List<OrderItemDto> items;
  final OrderAddressDto address;

  const CreateOrderRequest({
    required this.items,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toCreateJson()).toList(),
      'deliveryAddress': address.addressLine,
      'deliveryLat': address.lat,
      'deliveryLng': address.lng,
      'deliveryInstructions': address.instructions,
    };
  }
}
