import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/check_in_list_admin/check_in_list_admin.dart';
import 'screens/home_admin/admin_home_screen.dart';
import 'screens/login_admin/admin_login.dart';
import 'screens/menu_admin/menu_admin_screen.dart';
import 'screens/menu_admin/widgets/add_food.dart';
import 'screens/orders_admin/orders_list_screen.dart';
import 'screens/users_admin/manage_user_admin.dart';
import 'screens/vouchers_admin/manage_voucher_admin.dart';
import 'service/auth_services.dart';






class AppPages {
  static final pages = [
    GetPage(
      name: Routes.adminLogin,
      page: () => const AdminLogin(),
    ),
    GetPage(
      name: Routes.adminHome,
      page: () => const AdminHomeScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminMenu,
      page: () => const MenuAdminScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminAddMenu,
      page: () => const AddFoodItem(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminOrderList,
      page: () => const OrdersListScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminCheckInList,
      page: () => const CheckInListAdmin(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminManageUsers,
      page: () => const ManageUserAdmin(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminManageVoucher,
      page: () => const ManageVoucherAdmin(),
      middlewares: [AuthGuard()],
    ),
  ];
}

class Routes {
  static const String adminLogin = '/admin/login';
  static const String adminHome = '/admin';
  static const String adminMenu = '/admin/menu';
  static const String adminAddMenu = '/admin/add-menu';
  static const String adminOrderList = '/admin/order-list';
  static const String adminCheckInList = '/admin/check-in-list';
  static const String adminManageUsers = '/admin/manage-user';
  static const String adminManageVoucher = '/admin/manage-voucher';

  static const String notFound = '/not-found';
}


class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthService authService = AuthService.to;
    if (!authService.isLoggedIn.value) {
      return RouteSettings(
        name: '${Routes.adminLogin}?redirect=${Uri.encodeComponent(route!)}',
      );
    }
    return null;
  }
}



