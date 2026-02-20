import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/address_service.dart';
import 'package:raising_india/data/services/admin_service.dart';
import 'package:raising_india/data/services/analytics_service.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/data/services/user_service.dart';
import 'package:raising_india/data/services/wishlist_service.dart';
import 'package:raising_india/data/services/notification_service.dart';
import 'package:raising_india/features/admin/services/admin_image_service.dart';
import 'package:raising_india/screens/splash_screen.dart';
import 'package:raising_india/services/notification_service.dart';
import 'package:raising_india/services/service_locator.dart';
import 'data/services/auth_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');

  setupServiceLocator();

  await NotificationBackgroundService.initialize();
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key,required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core User Services
        ChangeNotifierProvider(create: (_) => getIt<AuthService>()),
        ChangeNotifierProvider(create: (_) => getIt<ProductService>()),
        ChangeNotifierProvider(create: (_) => getIt<CartService>()),
        ChangeNotifierProvider(create: (_) => getIt<OrderService>()),
        ChangeNotifierProvider(create: (_) => getIt<AddressService>()),
        ChangeNotifierProvider(create: (_) => getIt<CategoryService>()),
        ChangeNotifierProvider(create: (_) => getIt<BannerService>()),
        ChangeNotifierProvider(create: (_) => getIt<ReviewService>()),
        ChangeNotifierProvider(create: (_) => getIt<WishlistService>()),
        ChangeNotifierProvider(create: (_) => getIt<UserService>()),
        ChangeNotifierProvider(create: (_) => getIt<BrandService>()),
        ChangeNotifierProvider(create: (_) => getIt<CouponService>()),

        // Admin Services (Even if regular users don't use them, it's safe to keep them here)
        ChangeNotifierProvider(create: (_) => getIt<AdminService>()),
        ChangeNotifierProvider(create: (_) => getIt<ImageService>()),
        ChangeNotifierProvider(create: (_) => getIt<AdminImageService>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationService>()),
        ChangeNotifierProvider(create: (_) => getIt<AnalyticsService>()),
      ],
      child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Rising Distributor',
          debugShowCheckedModeBanner: false,
          theme : ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColour.primary, // Cursor color
              selectionColor: AppColour.primary.withOpacity(0.5), // Highlight background
              selectionHandleColor: AppColour.primary, // This changes the handle color
            ),
          ),
          home: const SplashScreen(),
        ),

    );
  }
}
