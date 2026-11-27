import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../breeds/presentation/breeds_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../products/presentation/products_screen.dart';
import '../../profile/presentation/user_avatar.dart';
import '../providers/home_tab_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabProvider);
    final cartCount = ref.watch(cartCountProvider);
    final select = ref.read(homeTabProvider.notifier).select;
    final isDesktop = context.isDesktop;

    final body = IndexedStack(
      index: index,
      children: const [BreedsScreen(), ProductsScreen()],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('GanaderiApp'),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: const UserAvatar(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Carrito',
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            tooltip: 'Cambiar tema',
            icon: const Icon(Icons.brightness_6),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: select,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: Text('Razas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.medical_services_outlined),
                      selectedIcon: Icon(Icons.medical_services),
                      label: Text('Insumos'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: select,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Razas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services),
                  label: 'Insumos',
                ),
              ],
            ),
    );
  }
}