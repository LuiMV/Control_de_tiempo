import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../services/api.dart';
import 'package:intl/intl.dart';

final usageSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.usageSummary('daily');
  return response.data;
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageSummary = ref.watch(usageSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Control de Uso del Móvil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
      ),
      body: usageSummary.when(
        data: (data) {
          final totalSeconds = data['total_seconds'] ?? 0;
          final apps = List<Map<String, dynamic>>.from(data['apps'] ?? []);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(usageSummaryProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(totalSeconds),
                  const SizedBox(height: 20),
                  const Text(
                    " Uso por aplicación",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...apps.map((app) => _buildAppCard(context, app)).toList(),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error al cargar datos: $err")),
      ),
    );
  }

  // Tarjeta principal con tiempo total
  Widget _buildSummaryCard(int totalSeconds) {
    final formatted = _formatDuration(totalSeconds);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tiempo total de hoy",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                formatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // Tarjeta individual de cada app
  Widget _buildAppCard(BuildContext context, Map<String, dynamic> app) {
    final appName = app['app_name'] ?? 'Desconocida';
    final duration = app['duration_seconds'] ?? 0;
    final limit = app['limit_minutes'] ?? 0;
    final progress = limit > 0
        ? (duration / (limit * 60)).clamp(0.0, 1.0)
        : 0.0; // Progreso respecto al límite

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.timer, color: Colors.blueAccent),
                  tooltip: 'Establecer límite',
                  onPressed: () => _setLimitDialog(context, appName),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Tiempo usado: ${_formatDuration(duration)}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            if (limit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(
                    progress < 0.7
                        ? Colors.green
                        : (progress < 1.0 ? Colors.orange : Colors.red),
                  ),
                ),
              ),
            if (limit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Límite: $limit min (${(progress * 100).toStringAsFixed(0)}%)",
                  style: TextStyle(
                    fontSize: 13,
                    color: progress >= 1.0 ? Colors.red : Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  void _setLimitDialog(BuildContext context, String appName) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Límite para $appName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Minutos de uso máximo",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text("Guardar"),
            onPressed: () async {
              final limit = int.tryParse(controller.text);
              if (limit != null && limit > 0) {
                final api = ApiService();
                await api.setAppLimit(appName, limit);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Límite de $appName actualizado a $limit minutos"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

