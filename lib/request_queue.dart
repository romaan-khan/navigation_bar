import 'dart:async';

import 'package:demo_app_bottom_bar/main.dart';
import 'package:flutter/material.dart';

class _QueuedFuture<T> {
  final Completer<T> completer;
  final Future<T> Function() closure;
  final Duration? timeout;
  Function? onComplete;

  _QueuedFuture(this.closure, this.completer, this.timeout, {this.onComplete});

  bool _timedOut = false;

  Future<void> execute() async {
    try {
      T result;
      Timer? timeoutTimer;

      if (timeout != null) {
        timeoutTimer = Timer(timeout!, () {
          _timedOut = true;
          if (onComplete != null) {
            onComplete!();
          }
        });
      }
      result = await closure();
      if (result != null) {
        completer.complete(result);
      } else {
        completer.complete(null);
      }

      // Make sure not to execute the next command until this future has completed
      timeoutTimer?.cancel();
      await Future.microtask(() {});
    } catch (e, stack) {
      completer.completeError(e, stack);
    } finally {
      if (onComplete != null && !_timedOut) onComplete!();
    }
  }
}

class Queue {
  final List<_QueuedFuture> _nextCycle = [];
  final Duration? delay;
  final Duration? timeout;
  int parallel;
  int _lastProcessId = 0;
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;
  StreamController<int>? _remainingItemsController;

  bool _showLoader = false; // Variable to track the loader state

  void _toggleLoader() {
    // Implement your code to show or hide the loader here
    if (_showLoader) {
      print("Show Loader");
      WidgetsBinding.instance.addPostFrameCallback((_){

        showLoaderFunction();

      });
      // Show loader dialog
    } else {
      print("Hide Loader");
      // Hide loader dialog
      hideLoader();
    }
  }

  void showLoaderFunction(){
    showDialog(
      context: NavigationService.navigatorKey.currentState!.overlay!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent, // can change this to your prefered color
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  void hideLoader(){
    Navigator.of(NavigationService.navigatorKey.currentState!.overlay!.context).pop();
  }

  Stream<int> get remainingItems {
    _remainingItemsController ??= StreamController<int>();
    return _remainingItemsController!.stream.asBroadcastStream();
  }

  final List<Completer<void>> _completeListeners = [];

  Future get onComplete {
    final completer = Completer();
    _completeListeners.add(completer);
    return completer.future;
  }

  Set<int> activeItems = {}; // Track the active items

  void cancel() {
    for (final item in _nextCycle) {
      item.completer.completeError(QueueCancelledException());
    }
    _nextCycle.removeWhere((item) => item.completer.isCompleted);
    _isCancelled = true;
  }

  void dispose() {
    _remainingItemsController?.close();
    cancel();
  }

  Queue({this.delay, this.parallel = 3, this.timeout});

  Future<T> add<T>(Future<T> Function() closure) {
    if (isCancelled) throw QueueCancelledException();
    final completer = Completer<T>();
    if (_nextCycle.isEmpty && activeItems.isEmpty) {
      _showLoader = true; // Show loader when the first item is added
      _toggleLoader();
    }
    _nextCycle.add(_QueuedFuture<T>(closure, completer, timeout));
    _updateRemainingItems();
    unawaited(_process());
    return completer.future;
  }

  void _updateRemainingItems() {
    final remainingItemsController = _remainingItemsController;
    if (remainingItemsController != null &&
        remainingItemsController.isClosed == false) {
      remainingItemsController.sink.add(_nextCycle.length + activeItems.length);
    }
  }

  Future<void> _process() async {
    if (activeItems.length < parallel) {
      _queueUpNext();
    }
  }

  void _queueUpNext() {
    if (_nextCycle.isNotEmpty &&
        !isCancelled &&
        activeItems.length <= parallel) {
      print('Loading');
      final processId = _lastProcessId;
      activeItems.add(processId);
      final item = _nextCycle.first;
      _lastProcessId++;
      _nextCycle.remove(item);
      item.onComplete = () async {
        activeItems.remove(processId);
        if (delay != null) {
          await Future.delayed(delay!);
        }
        _updateRemainingItems();
        _queueUpNext();
      };
      unawaited(item.execute());
    } else if (activeItems.isEmpty && _nextCycle.isEmpty) {
      _showLoader = false; // Hide loader when all items are completed
      _toggleLoader();
      for (final completer in _completeListeners) {
        if (completer.isCompleted != true) {
          completer.complete();
        }
      }
      _completeListeners.clear();
    }
  }
}

class QueueCancelledException implements Exception {}

void unawaited(Future<void> future) {}
