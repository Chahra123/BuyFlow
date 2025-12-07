// main.dart
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
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Écran de bienvenue
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // corrigé ici
            children: [
              const Icon(Icons.inventory_2_outlined, size: 100, color: Colors.white),
              const SizedBox(height: 30),
              const Text(
                "Welcome to BuyFlow app",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu),
                label: const Text("Ouvrir le menu", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeWithDrawer()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Écran principal avec sidebar
class HomeWithDrawer extends StatefulWidget {
  const HomeWithDrawer({super.key});

  @override
  State<HomeWithDrawer> createState() => _HomeWithDrawerState();
}

class _HomeWithDrawerState extends State<HomeWithDrawer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BuyFlow"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // corrigé aussi ici
                children: [
                  Icon(Icons.shopping_cart, size: 60, color: Colors.white),
                  SizedBox(height: 12),
                  Text("BuyFlow", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text("Gestion de stocks", style: TextStyle(fontSize: 17)),
              selected: _selectedIndex == 0,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: const StocksPage(), // toujours la page des stocks au démarrage
    );
  }
}