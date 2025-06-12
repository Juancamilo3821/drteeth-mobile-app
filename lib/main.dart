import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'Screens/Login.dart';
import 'Screens/Register.dart';
import 'Screens/SplashScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formato de fechas en español
  await initializeDateFormatting('es', null);

  // Inicializa zona horaria para notificaciones programadas
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Bogota')); // Ajusta según tu zona

  // Configuración de inicialización para Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const DrTeethApp());
}

class DrTeethApp extends StatelessWidget {
  const DrTeethApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrTeeth Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
