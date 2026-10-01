import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/attendance_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/attendance_record.dart';
import '../utils/helpers.dart';

class AttendanceHistoryView extends StatelessWidget {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userId = authController.currentUser?.uid ?? 'usuario-demo';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de pontos'),
      ),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: context.read<AttendanceController>().getHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum registro encontrado.'),
            );
          }

          final records = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final record = records[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: record.status == 'Dentro'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  child: Icon(
                    record.status == 'Dentro'
                        ? Icons.check_circle
                        : Icons.warning,
                    color: record.status == 'Dentro'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                title: Text(record.status),
                subtitle: Text(
                  '${formatDateTime(record.checkedAt)}\n'
                  'Lat: ${record.latitude.toStringAsFixed(5)} | Long: ${record.longitude.toStringAsFixed(5)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
