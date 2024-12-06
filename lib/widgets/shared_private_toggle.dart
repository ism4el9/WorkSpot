import 'package:flutter/material.dart';

class SharedPrivateToggle extends StatelessWidget {
  final bool isSharedSelected;
  final bool isPrivateSelected;
  final Function(int) onToggle;

  const SharedPrivateToggle({
    super.key,
    required this.isSharedSelected,
    required this.onToggle,
    required this.isPrivateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-4, -4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              onToggle(1);
            },
            child: Column(
              children: [
                Icon(
                  Icons.group,
                  color: isSharedSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceDim,
                ),
                Text(
                  "Compartido",
                  style: TextStyle(
                    color: isSharedSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceDim,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
          GestureDetector(
            onTap: () {
              onToggle(2);
            },
            child: Column(
              children: [
                Icon(
                  Icons.person,
                  color: isPrivateSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceDim,
                ),
                Text(
                  "Privado",
                  style: TextStyle(
                    color: isPrivateSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceDim,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}