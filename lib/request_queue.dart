import 'package:http/http.dart' as http;
import 'dart:async';

class UserRepository {
  final APIClient _apiClient = APIClient();

  /// data type here
  Future<dynamic> getUser(String userId) async {
    final url = 'https://example.com/users/$userId';
    _apiClient.get(url);
    // Process the response and return the User object
  }

  /// data type here
  Future<void> updateUser(dynamic user) async {
    final url = 'https://example.com/users/${user.id}';
    final body = /* serialize user object */;
    _apiClient.put(url, body);
    // Handle the response as needed
  }
}


class APIClient {
  List<http.Request> _queue = [];
  bool _processing = false;
  bool _showLoader = false; // Variable to track the loader state

  Future<http.Response> get(String url) {
    final request = http.Request('GET', Uri.parse(url));
    return _enqueueRequest(request);
  }

  Future<http.Response> post(String url, dynamic body) {
    final request = http.Request('POST', Uri.parse(url));
    request.body = body;
    return _enqueueRequest(request);
  }

  Future<http.Response> put(String url, dynamic body) {
    final request = http.Request('PUT', Uri.parse(url));
    request.body = body;
    return _enqueueRequest(request);
  }

  Future<http.Response> delete(String url) {
    final request = http.Request('DELETE', Uri.parse(url));
    return _enqueueRequest(request);
  }

  Future<http.Response> _enqueueRequest(http.Request request) async {
    _queue.add(request);
    if (!_processing) {
      /// show loader here
      _showLoader = true; // Show loader when first request is enqueued
      _processQueue();
    }

    return await _processNextRequest();
  }

  Future<void> _processQueue() async {
    _processing = true;
    while (_queue.isNotEmpty) {
      await _processNextRequest();
    }
    _processing = false;
    _showLoader = false;
    /// Hide loader when last request is completed
  }

  Future<http.Response> _processNextRequest() async {
    if (_queue.isNotEmpty) {
      final request = _queue.first;
      final response = await _sendRequest(request);
      _queue.removeAt(0);
      return response;
    } else {
      return Future.error('No more requests in the queue.');
    }
  }

  Future<http.Response> _sendRequest(http.Request request) async {
    final response = await http.Client().send(request);
    // Handle the response as needed
    final body = await response.stream.bytesToString();
    print(body);

    // Create a new response object with the processed body
    final processedResponse = http.Response(body, response.statusCode,
        headers: response.headers, request: response.request);

    return processedResponse;
  }

  bool get showLoader => _showLoader; // Getter for loader state
}






