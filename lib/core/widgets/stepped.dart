import 'package:flutter/material.dart';

class ReviewStepper extends StatefulWidget {
  const ReviewStepper({super.key, required this.steps});

  final List<Step> steps;

  @override
  State<ReviewStepper> createState() => _ReviewStepperState();
}

class _ReviewStepperState extends State<ReviewStepper> {
  int _currentStep = 0;

  int get _lastStep => widget.steps.length - 1;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < _lastStep) {
          setState(() => _currentStep += 1);
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep -= 1);
        }
      },
      onStepTapped: (step) => setState(() => _currentStep = step),
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              if (_currentStep < _lastStep)
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Suivant'),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Pr├⌐c├⌐dent'),
                ),
            ],
          ),
        );
      },
      steps: widget.steps,
    );
  }
}
