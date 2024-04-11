import 'package:gazelle_todo_app/gazelle_service.dart';

void runServer() async {
  await GazelleService.start();
  print(
      'Server is running at http://${GazelleService.app.address}:${GazelleService.app.port}');
}
