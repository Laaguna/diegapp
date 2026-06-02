import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/form_list_provider.dart';
import 'providers/form_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/form/form_screen.dart';
import 'views/list/form_list_screen.dart';
import 'views/pdf/pdf_preview_screen.dart';
import 'widgets/page_transitions.dart';

class DiegApp extends StatelessWidget {
  const DiegApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FormListProvider()..loadDistinctValues()),
        ChangeNotifierProvider(create: (_) => FormProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()..loadDistinctValues()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (innerContext, themeProvider, _) {
          final router = GoRouter(
            initialLocation: '/',
            routes: [
              ShellRoute(
                builder: (context, state, child) =>
                    _RootShell(state: state, child: child),
                routes: [
                  GoRoute(
                    path: '/',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: FormListScreen(),
                    ),
                  ),
                  GoRoute(
                    path: '/dashboard',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: DashboardScreen(),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/form',
                pageBuilder: (context, state) {
                  final provider = context.read<FormProvider>();
                  provider.createNew();
                  return const FadeSlidePage(child: FormScreen());
                },
              ),
              GoRoute(
                path: '/form/:id',
                pageBuilder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return FadeSlidePage(child: FormScreen(formId: id));
                },
              ),
              GoRoute(
                path: '/pdf-preview/:id',
                pageBuilder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return FadeSlidePage(child: PdfPreviewScreen(formId: id));
                },
              ),
            ],
          );

          return MaterialApp.router(
            title: 'DiegApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

class _RootShell extends StatelessWidget {
  const _RootShell({required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  int get _currentIndex {
    final loc = state.uri.toString();
    if (loc.startsWith('/dashboard')) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/dashboard');
        break;
      case 2:
        context.go('/form');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Text('📋', style: TextStyle(fontSize: 22)),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Text('📊', style: TextStyle(fontSize: 22)),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Text('➕', style: TextStyle(fontSize: 22)),
            label: 'Nuevo',
          ),
        ],
      ),
    );
  }
}
