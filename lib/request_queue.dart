import 'dart:async';

import 'package:demo_app_bottom_bar/main.dart';
import 'package:flutter/material.dart';

class _QueuedFuture<T> {
  final Completer completer;
  final Future<T> Function() closure;
  final Duration? timeout;
  Function? onComplete;

  _QueuedFuture(this.closure, this.completer, this.timeout, {this.onComplete});

  bool _timedOut = false;

  Future<void> execute() async {
    try {
      T result;
      Timer? timoutTimer;

      if (timeout != null) {
        timoutTimer = Timer(timeout!, () {
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

      //Make sure not to execute the next command until this future has completed
      timoutTimer?.cancel();
      await Future.microtask(() {});
    } catch (e, stack) {
      completer.completeError(e, stack);
    } finally {
      if (onComplete != null && !_timedOut) onComplete!();
    }
  }
}

/// Queue to execute Futures in order.
/// It awaits each future before executing the next one.
class Queue {
  final List<_QueuedFuture> _nextCycle = [];

  /// A delay to await between each future.
  final Duration? delay;

  /// A timeout before processing the next item in the queue
  final Duration? timeout;

  /// The number of items to process at one time
  ///
  /// Can be edited mid processing
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
      hideLoader();
      // Hide loader dialog
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
    // Lazily create the remaining items controller so if people aren't listening to the stream, it won't create any potential memory leaks.
    // Probably not necessary, but hey, why not?
    _remainingItemsController ??= StreamController<int>();
    return _remainingItemsController!.stream.asBroadcastStream();
  }

  final List<Completer<void>> _completeListeners = [];

  /// Resolve when all items are complete
  ///
  /// Returns a future that will resolve when all items in the queue have
  /// finished processing
  Future get onComplete {
    final completer = Completer();
    _completeListeners.add(completer);
    return completer.future;
  }

  @Deprecated(
      "v4 - listen to the [remainingItems] stream to listen to queue status")
  Set<int> activeItems = {};

  /// Cancels the queue. Also cancels any unprocessed items throwing a [QueueCancelledException]
  ///
  /// Subsquent calls to [add] will throw.
  void cancel() {
    for (final item in _nextCycle) {
      item.completer.completeError(QueueCancelledException());
    }
    _nextCycle.removeWhere((item) => item.completer.isCompleted);
    _isCancelled = true;
  }

  /// Dispose of the queue
  ///
  /// This will run the [cancel] function and close the remaining items stream
  /// To gracefully exit the queue, waiting for items to complete first,
  /// call `await [Queue.onComplete];` before disposing
  void dispose() {
    _remainingItemsController?.close();
    cancel();
  }

  Queue({this.delay, this.parallel = 1, this.timeout});

  /// Adds the future-returning closure to the queue.
  ///
  /// It will be executed after futures returned
  /// by preceding closures have been awaited.
  ///
  /// Will throw an exception if the queue has been cancelled.
  Future<T> add<T>(Future<T> Function() closure) {
    if (isCancelled) throw QueueCancelledException();
    final completer = Completer<T>();
    if (_nextCycle.isEmpty && activeItems.isEmpty) {
      _showLoader = true; // Show loader when the first item is added
      _toggleLoader();
    }
    // Toggle the loader state
    _nextCycle.add(_QueuedFuture<T>(closure, completer, timeout));
    _updateRemainingItems();
    unawaited(_process());
    return completer.future;
  }

  /// Handles the number of parallel tasks firing at any one time
  ///
  /// It does this by checking how many streams are running by querying active
  /// items, and then if it has less than the number of parallel operations fire off another stream.
  ///
  /// When each item completes it will only fire up one othe process
  ///
  Future<void> _process() async {
    if (activeItems.length < parallel) {
      _queueUpNext();
    }
  }

  void _updateRemainingItems() {
    final remainingItemsController = _remainingItemsController;
    if (remainingItemsController != null &&
        remainingItemsController.isClosed == false) {
      remainingItemsController.sink.add(_nextCycle.length + activeItems.length);
    }
  }

  void _queueUpNext() {
    if (_nextCycle.isNotEmpty && !isCancelled && activeItems.length <= parallel) {
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
      //Complete
      _showLoader = false; // Hide loader when all items are completed
      _toggleLoader(); // Toggle the loader state
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

// Don't throw analysis error on unawaited future.
void unawaited(Future<void> future) {}