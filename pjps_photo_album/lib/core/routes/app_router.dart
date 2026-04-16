//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/albums/albums_screen.dart';
import '../../screens/albums/year_album_screen.dart';
import '../../screens/albums/student_detail_screen.dart';
import '../../screens/staff/staff_list_screen.dart';
import '../../screens/staff/staff_detail_screen.dart';
import '../../screens/remarks/remark_book_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
//========================================================
import '../../screens/admin/manage_users_screen.dart';
import '../../screens/admin/add_edit_student_screen.dart';
import '../../screens/admin/add_edit_staff_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/albums',
      name: 'albums',
      builder: (context, state) => const AlbumsScreen(),
    ),
    GoRoute(
      path: '/albums/year/:yearId',
      name: 'yearAlbum',
      builder: (context, state) {
        final yearId = state.pathParameters['yearId']!;
        final yearName = state.extra as String? ?? 'Year';
        return YearAlbumScreen(
          yearId: yearId,
          yearName: yearName,
        );
      },
    ),
    GoRoute(
      path: '/students/:studentId',
      name: 'studentDetail',
      builder: (context, state) => StudentDetailScreen(
        studentId: state.pathParameters['studentId']!,
      ),
    ),
    GoRoute(
      path: '/staff',
      name: 'staff',
      builder: (context, state) => const StaffListScreen(),
    ),
    GoRoute(
      path: '/staff/:staffId',
      name: 'staffDetail',
      builder: (context, state) => StaffDetailScreen(
        staffId: state.pathParameters['staffId']!,
      ),
    ),
    GoRoute(
      path: '/remarks/:contentType/:objectId',
      name: 'remarkBook',
      builder: (context, state) => RemarkBookScreen(
        contentType: state.pathParameters['contentType']!,
        objectId: state.pathParameters['objectId']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    //=====================
    GoRoute(
      path: '/admin/users',
      name: 'manageUsers',
      builder: (context, state) => const ManageUsersScreen(),
    ),

    GoRoute(
      path: '/admin/students/add',
      name: 'addStudent',
      builder: (context, state) => const AddEditStudentScreen(),
    ),
    GoRoute(
      path: '/admin/students/edit/:studentId',
      name: 'editStudent',
      builder: (context, state) => AddEditStudentScreen(
        studentId: state.pathParameters['studentId'],
      ),
    ),
    GoRoute(
      path: '/admin/staff/add',
      name: 'addStaff',
      builder: (context, state) => const AddEditStaffScreen(),
    ),
    GoRoute(
      path: '/admin/staff/edit/:staffId',
      name: 'editStaff',
      builder: (context, state) => AddEditStaffScreen(
        staffId: state.pathParameters['staffId'],
      ),
    ),
  ],
);
