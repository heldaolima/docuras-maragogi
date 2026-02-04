import 'package:docuras_maragogi/app/pages/add_clients_page.dart';
import 'package:docuras_maragogi/app/pages/clients_page.dart';
import 'package:docuras_maragogi/app/pages/company_page.dart';
import 'package:docuras_maragogi/app/pages/edit_clients_page.dart';
import 'package:docuras_maragogi/app/widgets/layout.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          name: 'empresa',
          path: '/',
          builder: (context, state) => CompanyPage(),
        ),
        GoRoute(
          path: '/clientes',
          name: 'clientes',
          builder: (context, state) => ClientsPage(),
          routes: [
            GoRoute(
              path: 'adicionar',
              name: 'clientes-adicionar',
              builder: (context, state) => AddClientsPage(),
            ),

            GoRoute(
              path: ':id',
              name: 'clientes-editar',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EditClientsPage(clientId: int.parse(id));
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
