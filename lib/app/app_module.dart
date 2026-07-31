import 'package:flutter_modular/flutter_modular.dart';

import '../data/local/app_database.dart';
import '../data/repositories/schedule_repository.dart';
import '../data/repositories/time_entry_repository.dart';
import '../data/services/monthly_points_report_service.dart';
import 'modules/charts/charts_module.dart';
import 'modules/home/home_module.dart';
import 'modules/settings/settings_module.dart';
import 'modules/start/start_page.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addLazySingleton<AppDatabase>(AppDatabase.new);
    i.addLazySingleton<TimeEntryRepository>(TimeEntryRepository.new);
    i.addLazySingleton<ScheduleRepository>(ScheduleRepository.new);
    i.addLazySingleton<MonthlyPointsReportService>(
      MonthlyPointsReportService.new,
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => const StartPage(),
      children: [
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/charts', module: ChartsModule()),
        ModuleRoute('/settings', module: SettingsModule()),
      ],
    );
  }
}
