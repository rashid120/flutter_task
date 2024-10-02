import 'package:flutter/material.dart';
import 'package:flutter_task/providers/cart_provider.dart';
import 'package:flutter_task/utils/constants.dart';
import 'package:flutter_task/views/init_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp(),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Grocery App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
        ),
        home: const InitScreen(),
      ),
    );
  }
}