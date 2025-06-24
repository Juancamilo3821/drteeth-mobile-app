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

  // Inicializa fecha en español
  await initializeDateFormatting('es', null);

  // Inicializa zonas horarias
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Bogota'));

  // Configuración de inicialización
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // En caso futuro de necesitar respuesta a la notificación:
    // onDidReceiveNotificationResponse: (NotificationResponse response) {
    //   // Manejo de la acción al tocar la notificación
    // },
  );

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
