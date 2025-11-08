import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';

class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    String t(String en, String te) => state.languageCode == 'te' ? te : en;
    final theme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          t('Local Medicine', 'స్థానిక ఔషధం'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 56,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  iconSize: 20,
                  tooltip: t('Toggle Language', 'భాష మార్చండి'),
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    state.languageCode = state.languageCode == 'en'
                        ? 'te'
                        : 'en';
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 20,
                  vertical: isWide ? 32 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Welcome Section
                    Column(
                      children: [
                        Container(
                              padding: EdgeInsets.all(isWide ? 20 : 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.medical_services,
                                size: isWide ? 64 : 56,
                                color: const Color(0xFF6366F1),
                              ),
                            )
                            .animate()
                            .scale(duration: 500.ms)
                            .then()
                            .shimmer(duration: 1000.ms),
                        const SizedBox(height: 16),
                        Text(
                          t('Welcome!', 'స్వాగతం!'),
                          style: theme.headlineSmall?.copyWith(
                            color: Colors.grey.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                        const SizedBox(height: 8),
                        Text(
                          t(
                            'Find medicines in your area',
                            'మీ ప్రాంతంలో మందులను కనుగొనండి',
                          ),
                          style: theme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Role Selection
                    Column(
                      children: [
                        Text(
                          t(
                            'What do you want to do?',
                            'మీరు ఏమి చేయాలనుకుంటున్నారు?',
                          ),
                          style: theme.titleMedium?.copyWith(
                            color: Colors.grey.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _RoleCard(
                              icon: Icons.search,
                              title: t('Find Medicine', 'మందు కనుగొనండి'),
                              subtitle: t(
                                'Search nearby stores',
                                'సమీపంలోని దుకాణాలను చూడండి',
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF818CF8),
                                ],
                              ),
                              onTap: () {
                                state.role = UserRole.citizen;
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/search',
                                );
                              },
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 600.ms)
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(height: 12),
                        _RoleCard(
                              icon: Icons.store,
                              title: t('I am Shopkeeper', 'నేను దుకాణదారుని'),
                              subtitle: t(
                                'Manage medicines',
                                'ఔషధాలను నిర్వహించండి',
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF7C3AED),
                                  const Color(0xFFA78BFA),
                                ],
                              ),
                              onTap: () {
                                state.role = UserRole.shopkeeper;
                                Navigator.pushNamed(context, '/login');
                              },
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 800.ms)
                            .slideX(begin: 0.2, end: 0),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isWide ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: isWide ? 32 : 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: isWide ? 18 : 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
