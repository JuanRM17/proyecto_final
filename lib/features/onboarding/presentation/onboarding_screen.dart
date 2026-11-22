import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';

class _OnboardingItem {
  const _OnboardingItem(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

const _items = [
  _OnboardingItem(
    Icons.agriculture_outlined,
    'Conoce las razas',
    'Explora fichas de razas bovinas con su origen, características y aptitud productiva.',
  ),
  _OnboardingItem(
    Icons.medical_services_outlined,
    'Insumos veterinarios',
    'Encuentra medicamentos, vacunas y suplementos para el cuidado de tu hato.',
  ),
  _OnboardingItem(
    Icons.notifications_active_outlined,
    'Pide y mantente al tanto',
    'Realiza tu pedido y recibe un aviso cuando quede confirmado.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).complete();
    if (!mounted) return;
    context.go('/');
  }

  void _next() {
    final page = ref.read(onboardingPageProvider);
    if (page == _items.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(onboardingPageProvider);
    final isLast = page == _items.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLast ? null : _finish,
                  child: const Text('Omitir'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (i) =>
                      ref.read(onboardingPageProvider.notifier).set(i),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundColor:
                                scheme.primary.withValues(alpha: 0.12),
                            child: Icon(item.icon, size: 80, color: scheme.primary),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (i) {
                  final active = i == page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Comenzar' : 'Siguiente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}