import 'package:buy_flow/pages/stock_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuyFlow',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0074D9),
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00509E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardColor: Colors.white,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0074D9),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0074D9),
          brightness: Brightness.light,
          primary: const Color(0xFF0074D9),
          secondary: const Color(0xFF4198FF),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/logo-buyflow.png',
              width: 320,
            ),
            const SizedBox(height: 20),
            Text(
              "Buy, Flow, Go.",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF00509E),
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 100),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 24),
              label: const Text("Entrer dans l'app", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0074D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 12,
                shadowColor: const Color(0xFF0074D9).withOpacity(0.5),
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeWithDrawer()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class HomeWithDrawer extends StatefulWidget {
  const HomeWithDrawer({super.key});

  @override
  State<HomeWithDrawer> createState() => _HomeWithDrawerState();
}

class _HomeWithDrawerState extends State<HomeWithDrawer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo-buyflow-design.png', height: 42),
        backgroundColor: const Color(0xFF00509E),
        centerTitle: true,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Image.asset('lib/assets/logo-buyflow.png', height: 90),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Color(0xFF0074D9)),
              title: const Text("Gestion de stocks", style: TextStyle(fontSize: 18)),
              selected: true,
              selectedTileColor: Colors.blue.shade50,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: const StocksPage(),
    );
  }
}