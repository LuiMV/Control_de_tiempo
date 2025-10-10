import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api.dart';
import '../providers/api_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? summary;
  bool loading = false;

  void loadSummary() async {
    setState(() => loading = true);
    final api = ref.read(apiProvider);
    try {
      final res = await api.usageSummary('daily');
      setState(() => summary = res.data);
    } catch (e) {
      // manejar error
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadSummary());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resumen')),
      body: loading
        ? Center(child: CircularProgressIndicator())
        : summary == null
          ? Center(child: Text('No hay datos'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total segundos hoy: ${summary!['total_seconds'] ?? 0}'),
                ],
              ),
            ),
    );
  }
}
