import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, _) {
            final stats = provider.userStats;
            final profile = provider.userProfile;
            final currentWeight = stats?.bodyWeight ?? 0.0;
            final targetWeight = profile.targetWeight;
            final goalProgress = targetWeight > 0
                ? (currentWeight / targetWeight).clamp(0.0, 1.0)
                : 0.0;
            final pctLabel = '${(goalProgress * 100).toInt()}% towards goal';

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                                color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                            child: const Icon(Icons.settings_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar + name
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF1A1A1A), width: 3),
                              ),
                              child: const Center(
                                child: Text('💪',
                                    style: TextStyle(fontSize: 40)),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const EditProfileScreen()),
                                ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 14, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Dynamic name from provider
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dynamic bio from provider
                        Text(
                          profile.bio,
                          style: const TextStyle(
                              color: Color(0xFF808080), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Age + Height pills
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPill('🎂 ${profile.age} yrs'),
                            const SizedBox(width: 8),
                            _buildPill('📏 ${profile.height.toInt()} cm'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withValues(alpha: 0.2),
                                Colors.deepOrange.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.orangeAccent, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${provider.currentStreak} day streak — Keep it up!',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Stats grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatTile(
                                '${stats?.bodyWeight.toStringAsFixed(1) ?? '—'} lbs',
                                'Body Weight',
                                Icons.monitor_weight_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatTile(
                                '${provider.completedWorkouts.length}',
                                'Sessions Done',
                                Icons.fitness_center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatTile(
                                '${(stats?.volumeLifted ?? 0).toInt()} lbs',
                                'Volume Lifted',
                                Icons.bar_chart,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatTile(
                                '${provider.personalRecords.length}',
                                'Personal Records',
                                Icons.emoji_events_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Goal section — fully dynamic
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Goal',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen()),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                    color: Color(0xFF4ADE80), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(profile.goalEmoji,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      profile.goal,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current: ${currentWeight.toStringAsFixed(1)} lbs',
                                    style: const TextStyle(
                                        color: Color(0xFF808080), fontSize: 13),
                                  ),
                                  Text(
                                    'Target: ${targetWeight.toStringAsFixed(0)} lbs',
                                    style: const TextStyle(
                                        color: Color(0xFF4ADE80), fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: goalProgress,
                                  backgroundColor: const Color(0xFF2A2A2A),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4ADE80)),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pctLabel,
                                style: const TextStyle(
                                    color: Color(0xFF808080), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Settings / menu items
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildMenuTile(
                          context,
                          Icons.person_outline,
                          'Edit Profile',
                          'Name, age, height, goal',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          ),
                        ),
                        _buildMenuTile(
                          context,
                          Icons.notifications_none,
                          'Notifications',
                          'Workout reminders',
                        ),
                        _buildMenuTile(
                          context,
                          Icons.monitor_weight_outlined,
                          'Units',
                          'lbs / kg',
                        ),
                        _buildMenuTile(
                          context,
                          Icons.color_lens_outlined,
                          'Appearance',
                          'Dark mode',
                        ),
                        _buildMenuTile(
                          context,
                          Icons.share_outlined,
                          'Share Progress',
                          'Export stats',
                        ),
                        _buildMenuTile(
                          context,
                          Icons.help_outline,
                          'Help & Support',
                          'FAQ, contact',
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12)),
    );
  }

  Widget _buildStatTile(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ADE80), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: const TextStyle(
                      color: Color(0xFF808080), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF808080), fontSize: 12)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: onTap != null
                  ? const Color(0xFF606060)
                  : const Color(0xFF303030),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
