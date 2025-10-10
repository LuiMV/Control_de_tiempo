import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api.dart';

// Provider global del servicio API
final apiProvider = Provider<ApiService>((ref) => ApiService());

// Provider Invitado
//final apiProvider = Provider<Apiservice((ref) => false);