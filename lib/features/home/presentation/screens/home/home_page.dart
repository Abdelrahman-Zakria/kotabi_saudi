import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/features/home/domain/repositories/educational_repository.dart';
import 'package:kotabi_saudi/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:kotabi_saudi/features/home/presentation/widgets/grade_card.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/content/content_page.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/timer/timer_page.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/favorites/favorites_page.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/library/library_page.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/notifications/notifications_page.dart';
import 'package:kotabi_saudi/features/tahderi/presentation/screens/tahderi/tahderi_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kotabi_saudi/core/services/ad_service.dart';
import 'package:kotabi_saudi/core/services/iap_service.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Home index
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // _loadBannerAd(); // Temporarily disabled
  }

  void _loadBannerAd() {
    if (sl.isRegistered<AdService>()) {
      _bannerAd = sl<AdService>().createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SizedBox(), // Share handled via method
      const TimerPage(),
      const _HomeContent(), // Index 2
      const LibraryPage(),
      const FavoritesPage(),
    ];

    return BlocProvider(
      create: (context) => HomeCubit(sl<EducationalRepository>())..loadGrades(),
      child: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              Expanded(child: pages[_currentIndex]),
            ],
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 0) {
                context.read<HomeCubit>().shareApp();
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(sl<EducationalRepository>())..loadGrades(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildTahderiButton(),
                _buildAdFreeButton(),
                _buildRestoreButton(),
                _buildFilters(context),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "المراحل الدراسية",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                _buildGradesGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset('assets/logo.png', height: 60),
            ),
            const SizedBox(height: 10),
            const Text(
              "تطبيق كتبي",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTahderiButton() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TahderiPage()),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00ACC1), Color(0xFF00838F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/tahderi.png',
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.description, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "قسم التحضيري",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "تصفح الكتب والتحاضير المدرسية",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdFreeButton() {
    return StreamBuilder<bool>(
      stream: sl<IapService>().adFreeStatusStream,
      initialData: sl<IapService>().isAdFree,
      builder: (context, snapshot) {
        if (snapshot.data == true) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Directionality(
                  textDirection: TextDirection.rtl,
                    child: Text("جاري إتمام الدفع...")), duration: Duration(seconds: 2)),
              );
              await sl<IapService>().buyAdRemoval();
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.shade700, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber.shade900),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "إزالة الإعلانات للأبد",
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "تصفح التطبيق بدون أي إزعاج مقابل 3\$ فقط",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.amber.shade900, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestoreButton() {
    return StreamBuilder<bool>(
      stream: sl<IapService>().adFreeStatusStream,
      initialData: sl<IapService>().isAdFree,
      builder: (context, snapshot) {
        if (snapshot.data == true) return const SizedBox.shrink();
        return Center(
          child: TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("جاري استعادة المشتريات..."), duration: Duration(seconds: 2)),
              );
              await sl<IapService>().restorePurchases();
            },
            child: const Text(
              "استعادة المشتريات",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context) {
    final stages = ['الكل', 'الابتدائية', 'المتوسط', 'الثانوية'];
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final activeFilter = (state is HomeLoaded) ? state.activeFilter : 'الكل';
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final label = stages[index];
              final isSelected = label == activeFilter;
              
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () => context.read<HomeCubit>().loadGrades(filter: label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF006064) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF006064).withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGradesGrid() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: CircularProgressIndicator(),
          ));
        }
        if (state is HomeLoaded) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: state.grades.length,
            itemBuilder: (context, index) => GradeCard(
              grade: state.grades[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContentPage(
                      node: state.grades[index],
                      parentId: state.grades[index].id,
                      title: state.grades[index].title,
                    ),
                  ),
                );
              },
            ),
          );
        }
        if (state is HomeError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
