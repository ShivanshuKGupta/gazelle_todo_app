import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  var directory = Directory('.');
  var watcher = directory.watch(recursive: true);
  var process =
      await Process.start('dart', ['run', 'lib/gazelle_todo_app.dart']);
  process.stdout.transform(utf8.decoder).listen(print);
  watcher.listen((event) async {
    if (event is FileSystemModifyEvent) {
      print('File modified: ${event.path}');
      process.kill();
      process =
          await Process.start('dart', ['run', 'lib/gazelle_todo_app.dart']);
      process.stdout.transform(utf8.decoder).listen(print);
    }
  });
}
