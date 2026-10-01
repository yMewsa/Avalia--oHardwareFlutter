import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/punch_model.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('attendance_registry')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de pontos'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum ponto registrado ainda.'),
            );
          }

          final records = snapshot.data!.docs
              .map(
                (doc) => PunchRecord.fromMap(doc.id, doc.data()),
              )
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];
              final dateText = DateFormat('dd/MM/yyyy - HH:mm').format(record.timestamp);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: record.isWithinRadius
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Icon(
                      record.isWithinRadius
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                      color: record.isWithinRadius ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    record.isWithinRadius ? 'Dentro do raio' : 'Fora do raio',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(dateText),
                      Text(
                        'Lat: ${record.latitude.toStringAsFixed(5)} | Long: ${record.longitude.toStringAsFixed(5)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
