import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'upload_models.dart';
import 'upload_picker.dart';
import 'upload_service.dart';

class UploadController extends ChangeNotifier {
  UploadController({
    required this.service,
    UploadPicker? picker,
    this.statusCheckInterval = const Duration(seconds: 3),
  }) : picker = picker ?? const UploadPicker();

  final UploadService service;
  final UploadPicker picker;
  final Duration statusCheckInterval;

  final List<UploadEntryState> _entries = [];
  final Map<String, CancelableOperation> _cancelTokens = {};
  bool _isPicking = false;
  bool _isUploading = false;

  bool get isPicking => _isPicking;
  bool get isUploading => _isUploading;
  UnmodifiableListView<UploadEntryState> get entries =>
      UnmodifiableListView(_entries);

  Future<void> pickAndAdd() async {
    if (_isPicking) return;
    _isPicking = true;
    notifyListeners();
    try {
      final items = await picker.pick();
      if (items.isEmpty) {
        return;
      }
      _entries.addAll(
        items.map(
          (item) => UploadEntryState(item: item, stage: UploadStage.queued),
        ),
      );
      notifyListeners();
    } finally {
      _isPicking = false;
      notifyListeners();
    }
  }

  void addItems(Iterable<UploadItem> items) {
    _entries.addAll(
      items.map(
        (item) => UploadEntryState(item: item, stage: UploadStage.queued),
      ),
    );
    notifyListeners();
  }

  void remove(String id) {
    _cancelTokens.remove(id)?.cancel();
    _entries.removeWhere((entry) => entry.item.id == id);
    notifyListeners();
  }

  void retry(String id) {
    final index = _entries.indexWhere((entry) => entry.item.id == id);
    if (index == -1) return;
    _entries[index] = _entries[index].copyWith(
      stage: UploadStage.queued,
      progress: 0,
      result: null,
    );
    notifyListeners();
  }

  Future<void> uploadAll() async {
    if (_isUploading) return;
    _isUploading = true;
    notifyListeners();
    try {
      for (final entry in List<UploadEntryState>.from(_entries)) {
        if (entry.stage == UploadStage.success ||
            entry.stage == UploadStage.uploading) {
          continue;
        }
        await _uploadEntry(entry.item.id);
      }
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadEntry(String id) async {
    if (_isUploading) {
      return;
    }
    _isUploading = true;
    notifyListeners();
    try {
      await _uploadEntry(id);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> _uploadEntry(String id) async {
    final index = _entries.indexWhere((entry) => entry.item.id == id);
    if (index == -1) return;
    var current = _entries[index];
    final cancelable = CancelableOperation();
    _cancelTokens[id] = cancelable;
    _entries[index] = current.copyWith(
      stage: UploadStage.uploading,
      progress: 0,
      result: null,
    );
    notifyListeners();
    try {
      final result = await service.upload(
        item: current.item,
        onProgress: (value) {
          _entries[index] = _entries[index].copyWith(progress: value);
          notifyListeners();
        },
        cancelToken: cancelable,
      );
      current = _entries[index];
      if (result.isSuccess) {
        final successStage = result.remoteId != null
            ? UploadStage.verifying
            : UploadStage.success;
        _entries[index] = current.copyWith(
          stage: successStage,
          progress: 1,
          result: result,
        );
        notifyListeners();
        if (result.remoteId != null) {
          _scheduleStatusCheck(id, initialDelay: statusCheckInterval);
        }
      } else {
        _entries[index] = current.copyWith(
          stage: UploadStage.failure,
          result: result,
        );
        notifyListeners();
      }
    } on UploadCanceledException {
      current = _entries[index];
      _entries[index] = current.copyWith(stage: UploadStage.canceled);
      notifyListeners();
    } catch (error) {
      current = _entries[index];
      _entries[index] = current.copyWith(
        stage: UploadStage.failure,
        result: UploadResult(stage: UploadStage.failure, error: error),
      );
      notifyListeners();
    } finally {
      _cancelTokens.remove(id);
    }
  }

  Future<void> refreshStatus(String id) async {
    final index = _entries.indexWhere((entry) => entry.item.id == id);
    if (index == -1) return;
    final current = _entries[index];
    final result = current.result;
    if (result == null) return;
    _entries[index] = current.copyWith(
      isCheckingStatus: true,
      stage: UploadStage.verifying,
    );
    notifyListeners();
    try {
      final status = await service.checkStatus(result: result);
      if (status == null) {
        return;
      }
      final newStage = status.stage;
      _entries[index] = _entries[index].copyWith(
        stage: newStage,
        result: UploadResult(
          stage: newStage,
          remoteId: result.remoteId,
          remoteUrl: status.remoteUrl ?? result.remoteUrl,
          error: result.error,
        ),
        isCheckingStatus: false,
      );
      notifyListeners();
    } finally {
      if (index < _entries.length) {
        _entries[index] = _entries[index].copyWith(isCheckingStatus: false);
        notifyListeners();
      }
    }
  }

  Future<void> _scheduleStatusCheck(String id, {Duration? initialDelay}) async {
    final delay = initialDelay ?? statusCheckInterval;
    await Future<void>.delayed(delay);
    if (!_entries.any((entry) => entry.item.id == id)) {
      return;
    }
    await refreshStatus(id);
  }

  @override
  void dispose() {
    for (final entry in _cancelTokens.values) {
      entry.cancel();
    }
    _cancelTokens.clear();
    super.dispose();
  }
}
