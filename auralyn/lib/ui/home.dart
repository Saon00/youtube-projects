import 'dart:ui';

import 'package:auralyn/core/app_colors.dart';
import 'package:auralyn/core/app_fonts.dart';
import 'package:auralyn/core/icons.dart';
import 'package:auralyn/core/images.dart';
import 'package:auralyn/ui/song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showContent = false; // when true we start fading the real UI in
  bool _loading = true; // controls whether shimmer overlay is visible
  late final AnimationController _shimmerController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    // shimmer animation (repeats while loading)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    // fade controller (used to fade the real UI in)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 0.0,
    );

    // when fade completes, hide shimmer overlay and stop shimmer
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _loading = false; // remove shimmer overlay
        });
        _shimmerController.stop();
      }
    });

    // after 2 seconds start fading the real content in (keep shimmer until fade done)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showContent = true);
      _fadeController.forward();
    });

    // precache images to avoid jank when the real UI builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final images = [
        AppImages.fr1,
        AppImages.fr2,
        AppImages.fr3,
        AppImages.fr4,
        AppImages.fr5,
        AppImages.fr6,
        AppImages.fr7,
        AppImages.fr8,
        AppImages.fr9,
        AppImages.fr10,
      ];

      for (final path in images) {
        precacheImage(AssetImage(path), context);
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _innerContent() {
    // ...the original UI content (unchanged)
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 600,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.greenColor,
                    AppColors.greenColor,
                    // keep these as-is; deprecation warnings are separate
                    AppColors.greenColor.withOpacity(0.7),
                    AppColors.greenColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.7, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: 80,
            left: 15,
            right: 15,
            bottom: 0,
            child: Column(
              children: [
                const Header(),
                const SizedBox(height: 30),
                const CustomSearchBar(),
                const SizedBox(height: 20),
                const CategoryChips(),
                // make everything below the chips scrollable while keeping the header/search/chips fixed
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: const [
                        RecentlyPlayedSection(),
                        SizedBox(height: 10),
                        MostPopularSection(),
                        SizedBox(height: 30),
                        MostPopularSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // only build the heavy UI once we're ready to show it; fade transition animates it in
          if (_showContent)
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeInOut,
              ),
              child: _innerContent(),
            ),

          // shimmer overlay (visible while _loading is true). Keep it on top while fading,
          // then hide after fade completes to avoid black/empty screen.
          if (_loading) _HomeShimmer(controller: _shimmerController),
        ],
      ),
    );
  }
}

/// ------------------------------ /// SHIMMER SKELETON (perfect app shimmer) /// ------------------------------
class _HomeShimmer extends StatelessWidget {
  final AnimationController controller;
  const _HomeShimmer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return _Shimmer(
              progress: controller.value,
              child: Container(
                color: AppColors
                    .bgColor, // ensure shimmer paints the app background to avoid black screen
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Header skeleton
                        Row(
                          children: [
                            _Skel.rect(width: 170, height: 26, radius: 10),
                            const Spacer(),
                            _Skel.circle(size: 28),
                            const SizedBox(width: 12),
                            _Skel.circle(size: 36),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Search skeleton
                        _Skel.rect(
                          width: double.infinity,
                          height: 52,
                          radius: 18,
                        ),
                        const SizedBox(height: 14),

                        // Chips skeleton
                        SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final w = [74.0, 78.0, 90.0, 92.0, 100.0][i];
                              return _Skel.pill(width: w, height: 32);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Recently Played header
                                Row(
                                  children: [
                                    _Skel.rect(
                                      width: 140,
                                      height: 14,
                                      radius: 6,
                                    ),
                                    const Spacer(),
                                    _Skel.rect(
                                      width: 60,
                                      height: 14,
                                      radius: 6,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Recently Played cards skeleton
                                SizedBox(
                                  height: 140,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 4,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (_, __) {
                                      return SizedBox(
                                        width: 92,
                                        child: Column(
                                          children: [
                                            _Skel.rect(
                                              width: 92,
                                              height: 92,
                                              radius: 16,
                                            ),
                                            const SizedBox(height: 8),
                                            _Skel.rect(
                                              width: 60,
                                              height: 12,
                                              radius: 6,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Most Popular header
                                Row(
                                  children: [
                                    _Skel.rect(
                                      width: 120,
                                      height: 14,
                                      radius: 6,
                                    ),
                                    const Spacer(),
                                    _Skel.rect(
                                      width: 60,
                                      height: 14,
                                      radius: 6,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Most Popular list skeleton
                                Column(
                                  children: List.generate(3, (i) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: i == 2 ? 0 : 14,
                                      ),
                                      child: _Skel.rect(
                                        width: double.infinity,
                                        height: 78,
                                        radius: 16,
                                        child: Row(
                                          children: [
                                            _Skel.rect(
                                              width: 56,
                                              height: 56,
                                              radius: 12,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _Skel.rect(
                                                    width: 170,
                                                    height: 14,
                                                    radius: 6,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  _Skel.rect(
                                                    width: 120,
                                                    height: 12,
                                                    radius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            _Skel.rect(
                                              width: 40,
                                              height: 14,
                                              radius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shimmer painter that animates a highlight across all skeletons.
class _Shimmer extends StatelessWidget {
  final double progress; // 0..1
  final Widget child;

  const _Shimmer({required this.progress, required this.child});

  @override
  Widget build(BuildContext context) {
    // Base + highlight colors (glass friendly)
    final base = Colors.white.withOpacity(0.08);
    final highlight = Colors.white.withOpacity(0.18);

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final x = (bounds.width * 2 * progress) - bounds.width;
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [base, highlight, base],
          stops: const [0.2, 0.5, 0.8],
          transform: _SlideGradientTransform(Offset(x, 0)),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final Offset offset;
  const _SlideGradientTransform(this.offset);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(offset.dx, offset.dy, 0.0);
  }
}

/// Skeleton primitives
class _Skel {
  static Widget rect({
    required double width,
    required double height,
    required double radius,
    Widget? child,
  }) {
    return Container(
      width: width == double.infinity ? double.infinity : width,
      height: height,
      padding: child == null ? EdgeInsets.zero : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: child,
    );
  }

  static Widget pill({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
    );
  }

  static Widget circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Welcome Back!',
          style: AppFonts.interTight.copyWith(
            color: AppColors.whiteColor,
            fontSize: 30,
          ),
        ),

        Row(
          children: [
            SvgPicture.asset(AppIcons.notification, height: 30),
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/54'),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.whiteColor.withOpacity(0.18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.whiteColor.withOpacity(0.16),
                AppColors.whiteColor.withOpacity(0.06),
              ],
            ),
          ),

          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.whiteColor.withOpacity(0.85)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  cursorColor: AppColors.whiteColor,
                  style: AppFonts.interTight.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists...',
                    hintStyle: AppFonts.interTight.copyWith(
                      color: AppColors.whiteColor.withOpacity(0.55),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final List<String> items = const [
    "For You",
    "Popular",
    "Workout",
    "Energize",
    "Feel Good",
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final bool selected = selectedIndex == i;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.14)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(selected ? 1 : 0.92),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecentlyPlayedSection extends StatelessWidget {
  const RecentlyPlayedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _RecentItem(title: 'Lost', imageUrl: AppImages.fr1),
      _RecentItem(title: 'Summer Vibes', imageUrl: AppImages.fr2),
      _RecentItem(title: 'Illusions', imageUrl: AppImages.fr3),
      _RecentItem(title: 'Stares of you', imageUrl: AppImages.fr4),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Text(
                'RECENTLY PLAYED',
                style: AppFonts.interTight.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                'View All',
                style: AppFonts.interTight.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140, // card + label space
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return _RecentCard(
                title: item.title,
                imageUrl: item.imageUrl,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailsScreen(
                        title: item.title,
                        subtitle: 'Artist Name',
                        imageUrl: item.imageUrl,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _RecentCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.asset(
                    imageUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),

                  // subtle dark overlay for readability (like screenshot)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.10)),
                  ),

                  // play button bottom-left
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.interTight.copyWith(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _PopularItem(
        title: "Someone Like You",
        subtitle: "Ed Sheeran  •  2M Plays",
        duration: "3:30",
        imageUrl: AppImages.fr8,
      ),
      _PopularItem(
        title: "Dark Side of the Moon",
        subtitle: "Liberty  •  580K Plays",
        duration: "4:10",
        imageUrl: AppImages.fr9,
      ),
      _PopularItem(
        title: "Flowering Sorrow",
        subtitle: "RabittHole  •  12M Plays",
        duration: "2:10",
        imageUrl: AppImages.fr10,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Text(
                "MOST POPULAR",
                style: AppFonts.interTight.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                "View All",
                style: AppFonts.interTight.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = items[index];
            return _PopularTile(item: item);
          },
        ),
      ],
    );
  }
}

class _PopularTile extends StatelessWidget {
  final _PopularItem item;
  const _PopularTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongDetailsScreen(
              title: item.title,
              subtitle: item.subtitle,
              imageUrl: item.imageUrl,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.interTight.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.interTight.copyWith(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item.duration,
                  style: AppFonts.interTight.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularItem {
  final String title;
  final String subtitle;
  final String duration;
  final String imageUrl;
  const _PopularItem({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imageUrl,
  });
}

class _RecentItem {
  final String title;
  final String imageUrl;
  const _RecentItem({required this.title, required this.imageUrl});
}
