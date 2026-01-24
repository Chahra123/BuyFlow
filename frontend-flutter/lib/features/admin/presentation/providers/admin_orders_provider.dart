import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_provider.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../commerce/data/models/order_models.dart';
import '../../../auth/domain/entities/user.dart';

// State model
class AdminOrdersState {
  final bool isLoading;
  final List<CustomerOrderDto> orders;
  final String? error;
  final bool isAssigning;

  const AdminOrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.error,
    this.isAssigning = false,
  });

  AdminOrdersState copyWith({
    bool? isLoading,
    List<CustomerOrderDto>? orders,
    String? error,
    bool? isAssigning,
  }) {
    return AdminOrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error,
      isAssigning: isAssigning ?? this.isAssigning,
    );
  }
}

// Notifier
class AdminOrdersNotifier extends StateNotifier<AdminOrdersState> {
  final AdminRepository _repository;

  AdminOrdersNotifier(this._repository) : super(const AdminOrdersState());

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _repository.getOrders();
      // Sort by date descending (newest first)
      orders.sort((a, b) {
        final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });
      state = state.copyWith(isLoading: false, orders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> assignCourier(int orderId, int courierId) async {
    state = state.copyWith(isAssigning: true, error: null);
    try {
      await _repository.assignCourier(orderId, courierId);
      // Reload orders to get updated status
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isAssigning: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isAssigning: false);
    }
  }
}

// Provider
final adminOrdersProvider = StateNotifierProvider<AdminOrdersNotifier, AdminOrdersState>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return AdminOrdersNotifier(repository);
});
