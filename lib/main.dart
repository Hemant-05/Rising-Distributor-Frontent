import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/Image_cubit/image_cubit.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/product_bloc/product_bloc.dart';
import 'package:raising_india/features/admin/banner/bloc/banner_bloc.dart';
import 'package:raising_india/features/admin/product/bloc/products_cubit.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/features/admin/home/bloc/order_cubit/order_stats_cubit.dart';
import 'package:raising_india/features/admin/order/bloc/admin_order_details_cubit.dart';
import 'package:raising_india/features/admin/review/bloc/admin_review_bloc.dart';
import 'package:raising_india/features/admin/sales_analytics/bloc/sales_analytics_bloc.dart';
import 'package:raising_india/features/admin/services/category_repository.dart';
import 'package:raising_india/features/admin/services/order_repository.dart';
import 'package:raising_india/features/admin/services/sales_analytics_repository.dart';
import 'package:raising_india/features/user/coupon/bloc/coupon_bloc.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/category_product_bloc.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/features/user/profile/bloc/profile_bloc.dart';
import 'package:raising_india/features/user/review/bloc/review_bloc.dart';
import 'package:raising_india/features/user/search/bloc/product_search_bloc/product_search_bloc.dart';
import 'package:raising_india/features/user/services/coupon_repository.dart';
import 'package:raising_india/features/services/review_repository.dart';
import 'package:raising_india/features/user/services/user_product_services.dart';
import 'package:raising_india/screens/splash_screen.dart';
import 'package:raising_india/services/notification_service.dart';
import 'package:raising_india/services/service_locator.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/services/auth_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');

  setupServiceLocator();

  await NotificationService.initialize();
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key,required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CategoryRepository>(create: (_) => CategoryRepositoryImpl(),),
        RepositoryProvider<OrderRepository>(create: (_) => OrderRepository(firestore: null)),
        RepositoryProvider<CouponRepository>(create: (_) => CouponRepositoryImpl(),),
        RepositoryProvider<ReviewRepository>(create: (_) => ReviewRepositoryImpl(),),
        RepositoryProvider<SalesAnalyticsRepository>(create: (_) => SalesAnalyticsRepositoryImpl(),),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (_) => UserBloc(AuthService())..add(AppStarted()),),
          BlocProvider<ProductBloc>(create: (_) => ProductBloc()),
          BlocProvider<ImageSelectionCubit>(create: (_) => ImageSelectionCubit()),
          BlocProvider<ProductSearchBloc>(create: (context) => ProductSearchBloc(firestore: FirebaseFirestore.instance),),
          BlocProvider<CategoryProductBloc>(create: (context) =>CategoryProductBloc(services: UserProductServices())..add(FetchBestSellingProducts())),
          BlocProvider<CategoryBloc>(create: (context) => CategoryBloc(repository: CategoryRepositoryImpl(),)..add(LoadCategories()),),
          BlocProvider<ProductFunBloc>(create: (context) => ProductFunBloc()),
          BlocProvider<OrderBloc>(create: (context) => OrderBloc()),
          BlocProvider<ProfileBloc>(create: (context) => ProfileBloc(),),
          BlocProvider<OrderStatsCubit>(create: (context)=>OrderStatsCubit(FirebaseFirestore.instance),),
          BlocProvider<ProductsCubit>(create: (context) => ProductsCubit(null)..fetchProducts()),
          BlocProvider<AdminOrderDetailsCubit>(create: (context) => AdminOrderDetailsCubit(),),
          BlocProvider<CouponBloc>(create: (context) => CouponBloc(couponRepository: context.read<CouponRepository>(),),),
          BlocProvider<ReviewBloc>(create: (context) => ReviewBloc(reviewRepository: context.read<ReviewRepository>(), orderRepository: context.read<OrderRepository>(),),),
          BlocProvider<AdminReviewBloc>(create: (context) => AdminReviewBloc(reviewRepository: context.read<ReviewRepository>(),),),
          BlocProvider<SalesAnalyticsBloc>(create: (context) => SalesAnalyticsBloc(repository: context.read<SalesAnalyticsRepository>(),),),
          BlocProvider<BannerBloc>(create: (context) => BannerBloc(),),
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
      ),
    );
  }
}
