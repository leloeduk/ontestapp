import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../bloc/onboarding_bloc.dart';

class _OnboardingContent {
  const _OnboardingContent(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingContent(
    Icons.apps_rounded,
    'Teste des applications',
    'Découvre de nouvelles applications et essaie-les gratuitement.',
  ),
  _OnboardingContent(
    Icons.star_rounded,
    'Donne ton avis',
    'Note les applications et partage ton expérience avec la communauté.',
  ),
  _OnboardingContent(
    Icons.emoji_events_rounded,
    'Gagne des points',
    'Chaque test complété te rapporte des points. Amuse-toi !',
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int currentPage) {
    if (currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<OnboardingBloc>().add(const OnboardingCompleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            final isLast = state.currentPage == _pages.length - 1;
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingCompleted()),
                    child: const Text('Passer'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) => context
                        .read<OnboardingBloc>()
                        .add(OnboardingPageChanged(index)),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(page.icon,
                                    size: 120,
                                    color:
                                        Theme.of(context).colorScheme.primary)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .scale(),
                            const SizedBox(height: 40),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: state.currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: state.currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppButton(
                    label: isLast ? 'Commencer' : 'Suivant',
                    onPressed: () => _next(state.currentPage),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
