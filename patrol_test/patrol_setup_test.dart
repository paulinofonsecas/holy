import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('renders a self-contained widget', ($) async {
    await $.pumpWidgetAndSettle(
      const MaterialApp(
        home: Scaffold(
          body: Text('Patrol is ready'),
        ),
      ),
    );

    expect($('Patrol is ready'), findsOneWidget);
  });

  /// Full flow test: verifies the bottom navigation bar renders all three tabs
  /// and that tapping each tab keeps the bar visible.
  patrolTest(
    'bottom navigation: tap through all tabs',
    ($) async {
      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Eu Sou')),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 1,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.book),
                  label: 'Bíblia',
                ),
                NavigationDestination(
                  icon: Icon(Icons.wb_sunny),
                  label: 'Eu Sou',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
              ],
            ),
          ),
        ),
      );

      // Bottom navigation bar is visible with all three tabs
      expect($('Bíblia'), findsOneWidget);
      expect($('Eu Sou'), findsOneWidget);
      expect($('Buscar'), findsOneWidget);

      // Tap on Bíblia tab (index 0)
      await $('Bíblia').tap();
      await $.pumpAndSettle();
      expect($('Bíblia'), findsOneWidget);

      // Tap on Eu Sou tab (index 1)
      await $('Eu Sou').tap();
      await $.pumpAndSettle();
      expect($('Eu Sou'), findsOneWidget);

      // Tap on Buscar tab (index 2)
      await $('Buscar').tap();
      await $.pumpAndSettle();
      expect($('Buscar'), findsOneWidget);

      // Verify the navigation bar is still present after all taps
      expect($(NavigationBar), findsOneWidget);
    },
  );
}
