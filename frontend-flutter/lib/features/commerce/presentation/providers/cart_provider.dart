import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/produit.dart';

class CartLine {
  final Produit produit;
  final int quantity;

  const CartLine({required this.produit, required this.quantity});

  CartLine copyWith({int? quantity}) => CartLine(produit: produit, quantity: quantity ?? this.quantity);
}

class CartState {
  final List<CartLine> lines;

  const CartState({this.lines = const []});

  double get total => lines.fold(0, (sum, l) => sum + l.produit.prix * l.quantity);

  int get totalItems => lines.fold(0, (sum, l) => sum + l.quantity);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(): super(const CartState());

  void add(Produit produit, {int qty = 1}) {
    final idx = state.lines.indexWhere((l) => l.produit.idProduit == produit.idProduit);
    if (idx >= 0) {
      final updated = [...state.lines];
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + qty);
      state = CartState(lines: updated);
    } else {
      state = CartState(lines: [...state.lines, CartLine(produit: produit, quantity: qty)]);
    }
  }

  void setQty(Produit produit, int qty) {
    if (qty <= 0) {
      remove(produit);
      return;
    }
    final updated = state.lines.map((l) {
      if (l.produit.idProduit == produit.idProduit) return l.copyWith(quantity: qty);
      return l;
    }).toList();
    state = CartState(lines: updated);
  }

  void remove(Produit produit) {
    state = CartState(lines: state.lines.where((l) => l.produit.idProduit != produit.idProduit).toList());
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());
