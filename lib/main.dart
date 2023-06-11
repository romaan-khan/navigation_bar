import 'package:demo_app_bottom_bar/request_queue.dart';
import 'package:demo_app_bottom_bar/super_bottom_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final queue = Queue();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  void initState() {
    super.initState();
    fetchAPIs();
  }

  Future<void> fetchAPIs()async{
    final result = await queue.add(()=>Future.delayed(const Duration(seconds: 2)));
    final result2 = await queue.add(()=>Future.delayed(const Duration(seconds: 3)));
    final result3 = await queue.add(()=>Future.delayed(const Duration(seconds: 4)));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar:  BrandBottomNavigationBar(
          currentIndex: 2,
          onSelected: (index){
            if (kDebugMode) {
              print('selected index is $index');
            }
          },
        ),


    );



  }




}



class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}
