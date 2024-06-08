import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationButton extends StatelessWidget {
  final String text;
  final String route;
  final Icon icon;

  const NavigationButton({
    super.key,
    required this.text,
    required this.route,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>  context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 10),
              Text(
                text,
                style: const TextStyle(fontSize: 42, color: Colors.white), // Aumenta el tamaño del texto
              ),
            ],
          ),
        ),
      ),
    );
  }
}
