import 'package:docuras_maragogi/app/pages/box_form_page.dart';
import 'package:docuras_maragogi/app/pages/boxes_page.dart';
import 'package:docuras_maragogi/app/pages/client_form_page.dart';
import 'package:docuras_maragogi/app/pages/clients_page.dart';
import 'package:docuras_maragogi/app/pages/company_page.dart';
import 'package:docuras_maragogi/app/pages/product_form_page.dart';
import 'package:docuras_maragogi/app/pages/products_page.dart';
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
              builder: (context, state) => ClientFormPage(),
            ),
            GoRoute(
              path: ':id',
              name: 'clientes-editar',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ClientFormPage(clientId: int.parse(id));
              },
            ),
          ],
        ),
        GoRoute(
          path: '/produtos',
          name: 'produtos',
          builder: (context, state) => ProductsPage(),
          routes: [
            GoRoute(
              path: 'adicionar',
              name: 'produtos-adicionar',
              builder: (context, state) => ProductFormPage(),
            ),

            GoRoute(
              path: ':id',
              name: 'produtos-editar',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ProductFormPage(productId: int.parse(id));
              },
            ),
          ],
        ),
        GoRoute(
          path: '/caixas',
          name: 'caixas',
          builder: (context, state) => BoxesPage(),
          routes: [
            GoRoute(
              path: 'adicionar',
              name: 'caixas-adicionar',
              builder: (context, state) => BoxFormPage(),
            ),

            GoRoute(
              path: ':id',
              name: 'caixas-editar',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BoxFormPage(boxId: int.parse(id));
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
