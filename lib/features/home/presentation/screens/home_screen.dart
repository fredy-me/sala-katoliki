import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Text(
          'Habari ya mchana, rafiki',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text('Sala Katoliki', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 26),
        const _VerseCard(),
        const SizedBox(height: 26),
        _SectionHeader(title: 'FIKIA HARAKA'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.32,
          children: [
            _QuickCard(
              icon: Icons.menu_book_outlined,
              title: 'Sala ya Siku',
              onTap: () => context.go('/prayers'),
            ),
            _QuickCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Rozari',
              onTap: () => context.go('/rosary'),
            ),
            _QuickCard(
              icon: Icons.favorite_border,
              title: 'Masomo ya Leo',
              onTap: () => context.go('/readings'),
            ),
            _QuickCard(
              icon: Icons.person_outline,
              title: 'Mtakatifu wa Leo',
              onTap: () => context.go('/readings'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const _SaintPreview(),
      ],
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AYA YA LEO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.nightPanel,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mtumaini Bwana kwa moyo wako wote. — Mithali 3:5',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.night,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nightPanel,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.nightPanelAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.mutedText,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SaintPreview extends StatelessWidget {
  const _SaintPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionHeader(title: 'MTAKATIFU WA LEO'),
            const Spacer(),
            Text(
              '→',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.nightPanel,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mt. Josephina Bakhita',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Sikukuu: 2/8',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alizaliwa Sudan, akauzwa utumwani, na baadaye akawa mfano wa msamaha na tumaini.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
