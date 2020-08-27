import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// The SPI mode.
enum SpiMode {
  mode0,
  mode1,
  mode2,
  mode3
}

/// Singleton for accessing the platform-side SPI
/// methods.
class FlutterSpidevPlatformInterface {
  static const _channel = MethodChannel("plugins.flutter.io/flutter_spidev", StandardMethodCodec());

  static Future<int> _open(String path) async {
    return await _channel.invokeMethod("open", path);
  }

  static Future<void> _setMode(int fd, SpiMode mode) async {
    int intMode;
    switch (mode) {
      case SpiMode.mode0: intMode = 0; break;
      case SpiMode.mode1: intMode = 1; break;
      case SpiMode.mode2: intMode = 2; break;
      case SpiMode.mode3: intMode = 3; break;
      default: throw ArgumentError.notNull("mode");
    }
    
    await _channel.invokeMethod("setMode", <int>[fd, intMode]);
  }

  static Future<SpiMode> _getMode(int fd) async {
    int result = (await _channel.invokeMethod("getMode", fd)) as int;
    switch (result) {
      case 0: return SpiMode.mode0;
      case 1: return SpiMode.mode1;
      case 2: return SpiMode.mode2;
      case 3: return SpiMode.mode3;
      default: return null;
    }
  }

  static Future<void> _setMaxSpeed(int fd, int speedHz) async {
    await _channel.invokeMethod("setMaxSpeed", <int>[fd, speedHz]);
  }

  static Future<int> _getMaxSpeed(int fd) async
    => await _channel.invokeMethod("getMaxSpeed", fd) as int;

  static Future<void> _setWordSize(int fd, int bitsPerWord) async {
    await _channel.invokeMethod("setWordSize", <int>[fd, bitsPerWord]);
  }

  static Future<int> _getWordSize(int fd) async
    => await _channel.invokeMethod("getWordSize", fd) as int;
  
  static Future<Uint8List> _transmit({@required int fd, @required int speedHz, @required int delayUsecs,
                                     @required int bitsPerWord, @required bool csChange,
                                     @required Uint8List data}) async {
    return await _channel.invokeMethod(
        "transmit",
        <String, dynamic>{
          "fd": fd, "speed": speedHz, "delay": delayUsecs, "wordSize": bitsPerWord,
          "csChange": csChange, "buffer": data
        }
      );
  }

  static Future<void> _close(int fd) async {
    await _channel.invokeMethod("close", fd);
  }
}

/// A wrapper around a linux spidev.
/// 
/// Communicates with one single SPI slave.
class Spidev {
  final int _fd;

  bool _isOpen = true;
  bool get isOpen => _isOpen;

  SpiMode _mode;
  SpiMode get mode => _mode;

  int     _maxSpeed;
  int get maxSpeed => _maxSpeed;

  int     _bitsPerWord;
  int get bitsPerWord => _bitsPerWord;

  Future<dynamic> _task;

  /// Synchronously returns (null) when no task is running right now,
  /// If there is a task running right now, returns a Future that completes
  /// when the task is completed.
  /// 
  /// 
  FutureOr<void> get done {
    if (_task != null) {
      return _task.then((_) {});
    }
  }


  Spidev._(this._fd, this._mode, this._maxSpeed, this._bitsPerWord);

  
  static Future<Spidev> _fromFd(int fd) async {
    final mode = await FlutterSpidevPlatformInterface._getMode(fd);
    final speed = await FlutterSpidevPlatformInterface._getMaxSpeed(fd);
    final wordSize = await FlutterSpidevPlatformInterface._getWordSize(fd);

    return Spidev._(fd, mode, speed, wordSize);
  }

  /// Opens a spidev from it's device path.
  /// 
  /// Example:
  /// ```dart
  /// final spidev = await Spidev.fromPath("/dev/spidev0.0");
  /// ```
  static Future<Spidev> fromPath(String path) async
    => _fromFd(await FlutterSpidevPlatformInterface._open(path));

  /// Opens a spidev from it's bus nr and device nr.
  /// 
  /// Basically a wrapper around `fromPath`. Device
  /// paths of spidevs typically have the form
  /// `/dev/spidevBUSNUMBER.DEVICENUMBER`.
  /// The busnumber selects the SCLK, MOSI and MISO pins.
  /// The device number selects the CS pin that will
  /// be set active at transimission.
  /// 
  /// Example:
  /// ```dart
  /// final spidev = await Spidev.fromBusDevNumbers(0, 0);
  /// ```
  static Future<Spidev> fromBusDevNumbers(int busNr, int devNr)
    => fromPath("/dev/spidev$busNr.$devNr");

  Future<T> _setTask<T>(Future<T> task) {
    final newTask = task.whenComplete(() => _task = null);
    _task = newTask;
    return newTask;
  }


  Future<void> _setBitsPerWord(int bitsPerWord) async {
    await FlutterSpidevPlatformInterface._setWordSize(_fd, bitsPerWord);
    _bitsPerWord = bitsPerWord;
  }

  /// Sets the default number bits per word for this Spidev.
  /// 
  /// Can only be called when `isOpen` is true and no other task
  /// is running. You can make sure no other task is running
  /// by awaiting the `done` Future before calling this function.
  /// (so, `await spidev.done`)
  /// 
  /// The Future
  Future<void> setBitsPerWord(int bitsPerWord) {
    ArgumentError.checkNotNull(bitsPerWord, "bitsPerWord");
    assert(isOpen);
    assert(_task == null);

    return _setTask(
      _setBitsPerWord(bitsPerWord)
    );
  }


  Future<void> _setMode(SpiMode mode) async {
    await FlutterSpidevPlatformInterface._setMode(_fd, mode);
    _mode = mode;
  }

  Future<void> setMode(SpiMode mode) {
    ArgumentError.checkNotNull(mode, "mode");
    assert(isOpen);
    assert(_task == null);

    return _setTask(
      _setMode(mode)
    );
  }


  Future<void> _setMaxSpeed(int speedHz) async {
    await FlutterSpidevPlatformInterface._setMaxSpeed(_fd, speedHz);
    _maxSpeed = speedHz;
  }

  Future<void> setMaxSpeed(int speedHz) {
    ArgumentError.checkNotNull(speedHz, "speedHz");
    assert(isOpen);
    assert(_task == null);

    return _setTask(
      _setMaxSpeed(speedHz)
    );
  }


  Future<Uint8List> _transmit(Uint8List data, {int speedHz, int delayUsecs, int bitsPerWord, bool csChange}) async {
    return await FlutterSpidevPlatformInterface._transmit(
      fd: _fd,
      speedHz: speedHz,
      delayUsecs: delayUsecs,
      bitsPerWord: bitsPerWord,
      csChange: csChange,
      data: data
    );
  }

  Future<Uint8List> transmit(Uint8List data, {int speedHz, int delayUsecs, int bitsPerWord, bool csChange = false}) {
    ArgumentError.checkNotNull(csChange, "csChange");
    assert(isOpen);
    assert(done == null);

    return _setTask(
      _transmit(data,
        speedHz: speedHz ?? this.maxSpeed,
        delayUsecs: delayUsecs ?? 0,
        bitsPerWord: bitsPerWord ?? this.bitsPerWord,
        csChange: csChange
      )
    );
  }


  Future<void> _close() async {
    await FlutterSpidevPlatformInterface._close(_fd);
    _isOpen = false;
  }

  Future<void> close() {
    assert(isOpen);
    assert(_task == null);

    return _setTask(_close());
  }
}