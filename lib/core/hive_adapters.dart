import 'package:hive/hive.dart';
import '../features/features.dart';

void registerHiveAdapters() => Hive.registerAdapter(TransactionAdapter());
