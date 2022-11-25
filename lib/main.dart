import 'package:flutter/material.dart';
import 'package:notemaker/HomeScreen.dart';
import 'package:notemaker/notification.dart';
import 'package:notemaker/provider/provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // to initialize the notificationservice.
  NotificationServices().initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PageProvider>(create: (_) => PageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 18))),
        home: HomeScreen(),
      ),
    );
  }
}
