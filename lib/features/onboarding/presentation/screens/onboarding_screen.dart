import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.wb_sunny_outlined,
      title: 'Sala za kila siku za Kikatoliki',
      body: 'Pata amani na uimarishe imani yako kila siku.',
    ),
    _OnboardingSlide(
      icon: Icons.wifi_off_outlined,
      title: 'Sali popote, wakati wowote',
      body: 'Hufanya kazi bila intaneti.',
    ),
    _OnboardingSlide(
      icon: Icons.translate_outlined,
      title: 'Kiingereza & Kiswahili',
      body: 'Sala na masomo katika lugha unayoipenda.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'SW · ENGLISH',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Ruka'),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) => _OnboardingPage(
                    slide: _slides[index],
                  ),
                ),
              ),
              _PageDots(count: _slides.length, activeIndex: _page),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (isLastPage) {
                    context.go('/home');
                    return;
                  }

                  _controller.nextPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Text(isLastPage ? 'Endelea kama Mgeni' : 'Endelea'),
              ),
              if (isLastPage) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Fungua Akaunti'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Ingia'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.nightPanelAlt,
            shape: BoxShape.circle,
          ),
          child: Icon(slide.icon, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 34),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        Text(
          slide.body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: activeIndex == index ? 32 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: activeIndex == index ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
