import 'package:flutter/material.dart';

class ReviewStepper extends StatefulWidget {
  const ReviewStepper({super.key, required this.steps});

  final List<ReviewStep> steps;

  @override
  State<ReviewStepper> createState() => _ReviewStepperState();
}

class _ReviewStepperState extends State<ReviewStepper> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final step = widget.steps[_currentStep];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.steps.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isActive = i == _currentStep;
          final isCompleted = i < _currentStep;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? colors.primary
                        : isActive
                            ? colors.primaryContainer
                            : colors.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? colors.onPrimaryContainer
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  s.title,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? colors.onSurface
                        : isCompleted
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        step.content,
        const SizedBox(height: 16),
        Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Précédent'),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            if (_currentStep < widget.steps.length - 1)
              FilledButton(
                onPressed: () => setState(() => _currentStep++),
                child: const Text('Suivant'),
              ),
          ],
        ),
      ],
    );
  }
}

class ReviewStep {
  const ReviewStep({
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;
}
