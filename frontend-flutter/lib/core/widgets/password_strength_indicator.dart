import 'package:flutter/material.dart';
import '../utils/validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = Validators.getPasswordStrength(password);
    final strengthText = Validators.getPasswordStrengthText(strength);
    
    Color getColor() {
      switch (strength) {
        case 0:
        case 1:
          return Colors.red;
        case 2:
          return Colors.orange;
        case 3:
          return Colors.yellow;
        case 4:
        case 5:
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 5.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: TextStyle(
                color: getColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
