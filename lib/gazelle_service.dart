import 'dart:convert';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_todo_app/todo.dart';

class GazelleService {
  static final app = GazelleApp(port: 8080);
  static final List<String> allRoutes = [
    '/',
    '/todos',
    '/todos/:id',
    '/create',
    '/update/:id',
    '/delete/:id',
  ];
  static final List<Todo> todos = [
    Todo(
      id: '1',
      title: 'Learn Dart',
      description: 'Learn Dart programming language',
      completed: false,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ),
    Todo(
      id: '2',
      title: 'Learn Flutter',
      description: 'Learn Flutter framework',
      completed: false,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ),
    Todo(
      id: '3',
      title: 'Raman Maharshi',
      description: 'Read about Ramana Maharshi',
      completed: true,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ),
  ];

  static Future<void> start() async {
    setRoutes();
    await app.start();
  }

  static void setRoutes() {
    GazelleService.app.get(
      '/',
      (request) async {
        return GazelleResponse(
          statusCode: 200,
          body:
              'This is a todo app. Use /todos to get all todos. All available routes are: ${GazelleService.allRoutes}',
        );
      },
    );
    GazelleService.app.get(
      '/todos',
      (request) async {
        return GazelleResponse(
          statusCode: 200,
          body: jsonEncode(GazelleService.todos),
        );
      },
      preRequestHooks: [authenticationHook],
      postRequestHooks: [loggerHook],
    );
    GazelleService.app.get('/todos/:id', (request) async {
      print("request.pathParameters= ${request.pathParameters}");
      final id = request.pathParameters['id'];
      try {
        final todo = GazelleService.todos.firstWhere((todo) => todo.id == id);
        return GazelleResponse(
          statusCode: 200,
          body: jsonEncode(todo),
        );
      } catch (e) {
        return GazelleResponse(
          statusCode: 404,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });
    GazelleService.app.post('/create', (request) async {
      final body = jsonDecode(await request.body ?? "{}");
      try {
        body['createdAt'] = DateTime.now().toIso8601String();
        final todo = Todo.fromJson(body);
        GazelleService.todos.add(todo);
        return GazelleResponse(
          statusCode: 201,
          body: jsonEncode(todo),
        );
      } catch (e) {
        return GazelleResponse(
          statusCode: 400,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });
    GazelleService.app.put('/update/:id', (request) async {
      final id = request.pathParameters['id'];
      final body = jsonDecode(await request.body ?? "{}");
      try {
        final todo = GazelleService.todos.firstWhere((todo) => todo.id == id);
        final updatedTodo = todo.copyWith(
          title: body['title'],
          description: body['description'],
          completed: body['completed'],
          completedAt: body['completed'] ? DateTime.now() : null,
        );
        int index = GazelleService.todos.indexWhere((todo) => todo.id == id);
        GazelleService.todos.removeAt(index);
        GazelleService.todos.insert(index, updatedTodo);
        return GazelleResponse(
          statusCode: 200,
          body: jsonEncode(updatedTodo),
        );
      } catch (e) {
        return GazelleResponse(
          statusCode: 404,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });
    GazelleService.app.delete('/delete/:id', (request) async {
      final id = request.pathParameters['id'];
      try {
        final todo = GazelleService.todos.firstWhere((todo) => todo.id == id);
        GazelleService.todos.remove(todo);
        return GazelleResponse(
          statusCode: 200,
          body: jsonEncode(todo),
        );
      } catch (e) {
        return GazelleResponse(
          statusCode: 404,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });
  }

  static final authenticationHook = GazellePreRequestHook(
    (request) async {
      if (!authenticated(request)) {
        return GazelleResponse(
          statusCode: 401,
          body: 'Unauthorized',
        );
      }
      return request;
    },
    shareWithChildRoutes: true,
  );

  static final loggerHook = GazellePostResponseHook(
    (request) async {
      print(request.body);
      return request;
    },
    shareWithChildRoutes: true,
  );

  static bool authenticated(GazelleRequest request) {
    // Perform authentication logic here
    return true;
  }
}
