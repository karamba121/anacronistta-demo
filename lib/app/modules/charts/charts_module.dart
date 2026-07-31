import 'package:flutter_modular/flutter_modular.dart';

import 'charts_page.dart';

class ChartsModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ChartsPage());
  }
}
