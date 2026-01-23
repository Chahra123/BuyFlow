class ComplaintDto {
  final int id;
  final int orderId;
  final String status;
  final String category;
  final String description;
  final String? createdAt;

  const ComplaintDto({
    required this.id,
    required this.orderId,
    required this.status,
    required this.category,
    required this.description,
    this.createdAt,
  });

  factory ComplaintDto.fromJson(Map<String, dynamic> json) {
    return ComplaintDto(
      id: (json['id'] ?? json['complaintId'] ?? 0) as int,
      orderId: (json['orderId'] ?? json['commandeId'] ?? 0) as int,
      status: json['status']?.toString() ?? 'OPEN',
      category: json['category']?.toString() ?? 'OTHER',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class ComplaintMessageDto {
  final int id;
  final int complaintId;
  final String senderRole;
  final String message;
  final String? createdAt;

  const ComplaintMessageDto({
    required this.id,
    required this.complaintId,
    required this.senderRole,
    required this.message,
    this.createdAt,
  });

  factory ComplaintMessageDto.fromJson(Map<String, dynamic> json) {
  return ComplaintMessageDto(
    id: (json['id'] ?? 0) as int,
    complaintId: (json['complaintId'] ?? json['reclamationId'] ?? 0) as int,
    senderRole: json['sender'] != null
        ? (json['sender']['role']?.toString() ?? 'USER')
        : 'USER',
    message: json['content']?.toString() ?? '',
    createdAt: json['sentAt']?.toString(),
  );
}

  Map<String, dynamic> toSendJson() {
    return {
      'message': message,
    };
  }
}
