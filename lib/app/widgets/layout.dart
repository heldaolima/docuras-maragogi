import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doçuras de Maragogi'),
        leading: Builder(
          builder: (context) {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => router.pop(),
              );
            }

            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              child: Center(
                child: const Text(
                  'Doçuras de Maragogi - Gerenciamento',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Empresa'),
              onTap: () => context.push('/'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Clientes'),
              onTap: () => context.push('/clientes'),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}