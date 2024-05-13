import 'dart:convert';
import 'dart:io';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_todo_app/todo.dart';

class GazelleService {
  /// This is the GazelleApp instance that will be used to start the server.
  static final app = GazelleApp(
    address: "0.0.0.0",
    port: int.tryParse(Platform.environment["PORT"] ?? "8080") ?? 8080,
  );
  static final List<Todo> todos = [
    Todo(
      id: '1',
      title: 'Learn Dart',
      description: 'Learn Dart programming language',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ),
    Todo(
      id: '2',
      title: 'Learn Flutter',
      description: 'Learn Flutter framework',
      createdAt: DateTime.now(),
    ),
    Todo(
      id: '3',
      title: 'Raman Maharshi',
      description: 'Read about Ramana Maharshi',
      createdAt: DateTime.now(),
    ),
    Todo(
      id: '4',
      title: 'Raman Tank',
      description: 'Read about Raman Tank',
      createdAt: DateTime(2002, 2, 4),
      completedAt: DateTime.now(),
    ),
  ];

  /// This method starts the server and sets the routes.
  static Future<void> start() async {
    setRoutes();
    await app.start();
  }

  /// This method sets the routes for the server.
  static void setRoutes() {
    /// This route returns a welcome message.
    /// It is a GET request to the root path.
    GazelleService.app.get(
      '/',
      (request, response) async {
        return response.copyWith(
          statusCode: 200,
          body:
              'This is the backend for a gazelle todo app. All available routes are:\n/todos (to get all todos), \n/todos/:id (to get a todo with this id), \n/create (to create a new todo), \n/update/:id, \n/delete/:id (to delete a todo with this id)',
        );
      },
    );

    /// This route returns all todos.
    GazelleService.app.get(
      '/todos',
      (request, response) async {
        return response.copyWith(
          // status code 200 means the request was successful.
          statusCode: 200,
          // Even if the body is a list, it should be encoded to a string.
          // We use jsonEncode to convert the list to a string.
          body: jsonEncode(GazelleService.todos),
        );
      },
      preRequestHooks: [authenticationHook],
      postResponseHooks: [loggerHook],
    );

    /// This route returns a todo with a specific id.
    app.get('/todos/:id', (request, response) async {
      // The pathParameters property of the request object contains the parameters in the path.
      print("request.pathParameters= ${request.pathParameters}");
      final id = request.pathParameters['id'];
      try {
        // finding the todo with the id.
        final todo = GazelleService.todos.firstWhere((todo) => todo.id == id);
        // if found then return the todo.
        return response.copyWith(
          statusCode: 200,
          body: jsonEncode(todo),
        );
      } catch (e) {
        // if not found then return an error message.
        return response.copyWith(
          statusCode: 404,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });

    /// This route creates a new todo.
    GazelleService.app.post('/create', (request, response) async {
      final body = jsonDecode(await request.body ?? "{}");
      try {
        // setting the createdAt property of the new todo.
        body['createdAt'] = DateTime.now().toIso8601String();
        // if the todo is not completed then completedAt should be null.
        body['completedAt'] = null;
        // setting the id of the new todo.
        body['id'] = (int.parse(GazelleService.todos.lastOrNull?.id ?? "0") + 1)
            .toString();
        final todo = Todo.fromJson(body);
        GazelleService.todos.add(todo);
        return response.copyWith(
          statusCode: 201,
          body: jsonEncode(todo),
        );
      } catch (e) {
        return response.copyWith(
          statusCode: 400,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });

    /// This route updates a todo with a specific id.
    GazelleService.app.put('/update/:id', (request, response) async {
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
        return response.copyWith(
          statusCode: 200,
          body: jsonEncode(updatedTodo),
        );
      } catch (e) {
        return response.copyWith(
          statusCode: 404,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });

    /// This route deletes a todo with a specific id.
    GazelleService.app.delete('/delete/:id', (request, response) async {
      final id = request.pathParameters['id'];
      try {
        final todo = GazelleService.todos.firstWhere((todo) => todo.id == id);
        GazelleService.todos.remove(todo);
        return response.copyWith(
          statusCode: 200,
          body: jsonEncode(todo),
        );
      } catch (e) {
        return response.copyWith(
          statusCode: 404,
          body: jsonEncode({"error": e.toString()}),
        );
      }
    });
  }

  static final authenticationHook = GazellePreRequestHook(
    (request, response) async {
      if (!authenticated(request)) {
        return (
          request,
          response.copyWith(
            statusCode: 401,
            body: 'Unauthorized',
          )
        );
      }
      return (request, response);
    },
    shareWithChildRoutes: true,
  );

  static final loggerHook = GazellePostResponseHook(
    (request, response) async {
      print('Request: ${request.method} ${request.uri}');
      return (request, response);
    },
    shareWithChildRoutes: true,
  );

  static bool authenticated(GazelleRequest request) {
    // Perform authentication logic here
    return true;
  }
}
