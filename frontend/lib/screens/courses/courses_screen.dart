import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/course_model.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';
import '../../widgets/cards/course_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // Mock data for testing
  late List<Course> _courses;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMockCourses();
  }

  void _loadMockCourses() {
    _courses = [
      Course(
        id: 1,
        title: 'Flutter Development',
        description: 'Learn Flutter from scratch',
        instructor: 'Aryan Nagori',
        thumbnail: 'https://via.placeholder.com/300x200?text=Flutter',
        videosCount: 15,
        enrolledCount: 324,
        rating: 4.8,
        level: 'beginner',
        tags: ['Flutter', 'Mobile'],
        isEnrolled: true,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 2,
        title: 'Advanced React',
        description: 'Master React with hooks and context',
        instructor: 'Jane Doe',
        thumbnail: 'https://via.placeholder.com/300x200?text=React',
        videosCount: 22,
        enrolledCount: 512,
        rating: 4.9,
        level: 'advanced',
        tags: ['React', 'JavaScript'],
        isEnrolled: false,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 3,
        title: 'Python Basics',
        description: 'Start your Python journey',
        instructor: 'John Smith',
        thumbnail: 'https://via.placeholder.com/300x200?text=Python',
        videosCount: 18,
        enrolledCount: 678,
        rating: 4.7,
        level: 'beginner',
        tags: ['Python', 'Programming'],
        isEnrolled: true,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 4,
        title: 'Web Design Masterclass',
        description: 'Create beautiful websites',
        instructor: 'Sarah Johnson',
        thumbnail: 'https://via.placeholder.com/300x200?text=WebDesign',
        videosCount: 25,
        enrolledCount: 445,
        rating: 4.6,
        level: 'intermediate',
        tags: ['Design', 'CSS', 'HTML'],
        isEnrolled: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Course> get _filteredCourses {
    if (_selectedFilter == 'enrolled') {
      return _courses.where((course) => course.isEnrolled).toList();
    }
    return _courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        title: const Text(
          'Courses',
          style: AppTextStyles.headingMedium,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            child: Icon(
              Icons.search,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          FadeAnimation(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              child: Row(
                children: [
                  _buildFilterChip('All Courses', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('My Courses', 'enrolled'),
                ],
              ),
            ),
          ),
          // Courses List
          Expanded(
            child: _filteredCourses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      return SlideAnimation(
                        direction: index.isEven
                            ? SlideDirection.fromLeft
                            : SlideDirection.fromRight,
                        child: CourseCard(
                          course: _filteredCourses[index],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opened ${_filteredCourses[index].title}',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.surfaceColor,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.borderColor,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected
                ? AppColors.surfaceColor
                : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No Courses Found',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start learning by exploring courses',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}