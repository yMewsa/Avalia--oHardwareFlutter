import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/punch_controller.dart';
import '../services/location_service.dart';
import '../utils/app_routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final LocationService _locationService = LocationService();
  Timer? _timer;

  double _distanceInMeters = 0;
  bool _isLoadingLocation = true;
  String _statusText = 'Verificando localização...';

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadLocation());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final distance = _locationService.calculateDistanceInMeters(
        position,
        LocationService.workplaceLatitude,
        LocationService.workplaceLongitude,
      );

      if (!mounted) return;
      setState(() {
        _distanceInMeters = distance;
        _isLoadingLocation = false;
        _statusText = distance <= LocationService.maxDistanceInMeters
            ? 'Você está dentro do raio permitido.'
            : 'Você está fora do raio permitido.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _statusText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final punchController = context.watch<PunchController>();
    final theme = Theme.of(context);
    final bool canPunch = !_isLoadingLocation &&
        !punchController.isRegistering &&
        _distanceInMeters <= LocationService.maxDistanceInMeters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de ponto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authController.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Localização da empresa',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Distância atual',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            _isLoadingLocation
                                ? 'Calculando...'
                                : '${_distanceInMeters.toStringAsFixed(0)} m',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _distanceInMeters <= LocationService.maxDistanceInMeters
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _distanceInMeters <= LocationService.maxDistanceInMeters
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      if (punchController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            punchController.errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: canPunch
                    ? () async {
                        final userId = authController.currentUser?.uid ?? 'demo-user';
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        await punchController.registerPunch(userId: userId);
                        if (!context.mounted) return;
                        await _loadLocation();
                        if (punchController.statusMessage != null && messenger != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(punchController.statusMessage!),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    : null,
                icon: punchController.isRegistering
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  punchController.isRegistering ? 'Bater ponto...' : 'Bater Ponto',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: canPunch
                      ? theme.colorScheme.primary
                      : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.history);
                },
                icon: const Icon(Icons.history_rounded),
                label: const Text('Histórico'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
