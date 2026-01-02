import 'package:flutter/material.dart';
import 'package:buy_flow/pages/stock_page.dart';
import 'package:buy_flow/pages/produit_page.dart';
import 'package:buy_flow/pages/categorie_page.dart';
import 'package:buy_flow/pages/reglement_page.dart';
import 'package:buy_flow/pages/commandes_page.dart';
import 'package:buy_flow/pages/livraisons_page.dart';
import 'package:buy_flow/pages/reclamations_page.dart';
import 'package:buy_flow/session/user_session.dart';

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
              label: const Text(
                "Entrer dans l'app",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0074D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 12,
                shadowColor: const Color(0xFF0074D9).withOpacity(0.5),
              ),
              onPressed: () {
                // Forced session user id
                UserSession.currentOperateurId = 1;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeWithDrawer()),
                );
              },
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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/logo-buyflow-design.png',
          height: 42,
        ),
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
                child: Image.asset(
                  'lib/assets/logo-buyflow.png',
                  height: 90,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Color(0xFF0074D9)),
              title: const Text("Gestion de stocks", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 0,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Color(0xFF0074D9)),
              title: const Text("Produits", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 1,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Color(0xFF0074D9)),
              title: const Text("Catégories", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 2,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments, color: Color(0xFF0074D9)),
              title: const Text("Paiements", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 3,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFF0074D9)),
              title: const Text("Mes commandes", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 4,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Color(0xFF0074D9)),
              title: const Text("Livraisons", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 5,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Color(0xFF0074D9)),
              title: const Text("Réclamations", style: TextStyle(fontSize: 18)),
              selected: _selectedIndex == 6,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                setState(() => _selectedIndex = 6);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.switch_account, color: Color(0xFF0074D9)),
              title: const Text("Changer d'utilisateur", style: TextStyle(fontSize: 18)),
              onTap: () async {
                Navigator.pop(context);
                final ok = true;
                if (ok == true) {
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? const StocksPage()
          : _selectedIndex == 1
              ? const ProduitsPage()
              : _selectedIndex == 2
                  ? const CategoriesPage()
                  : _selectedIndex == 3
                      ? const ReglementsPage()
                      : _selectedIndex == 4
                          ? const CommandesPage()
                          : _selectedIndex == 5
                              ? const LivraisonsPage()
                              : const ReclamationsPage(),
    );
  }
}
