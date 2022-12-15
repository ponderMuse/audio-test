import 'dart:async';

import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Audio Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _stepsTimer;
  late Timer _poolStepsTimer;
  late Timer _soundPoolStepsTimer;

  late AudioPool _stepPool;

  late Soundpool _soundPool = Soundpool.fromOptions();
  late int _soundId;

  bool _loaded = false;

  @override
  void initState() {
    _load();
    super.initState();
  }

  _load() async {
    await FlameAudio.audioCache.loadAll(['test-sine.mp3', 'test-step.mp3']);

    _stepPool = await FlameAudio.createPool('test-step.mp3',
        minPlayers: 4, maxPlayers: 4);

    _soundPool = Soundpool.fromOptions();
    _soundId = await rootBundle.load('assets/audio/test-step.mp3').then((ByteData soundData) {
      return _soundPool.load(soundData);
    });

    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flame Audio Test'),
      ),
      body: Center(
        child: _loaded
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Start/stop FX and BGM by pressing Buttons below.',
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    const Text('Steps FX via FlameAudio.play()'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: _startSteps,
                      child: const Text('Start'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: _stopSteps,
                      child: const Text('Stop'),
                    )
                  ]),
                  Column(children: [
                    const Text('Steps FX via AudioPool.start()'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: _startPoolSteps,
                      child: const Text('Start'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: _stopPoolSteps,
                      child: const Text('Stop'),
                    )
                  ]),
                  Column(children: [
                    const Text('Steps FX via Soundpool.play()'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow),
                      onPressed: _startSoundPoolSteps,
                      child: const Text('Start'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow),
                      onPressed: _stopSoundPoolSteps,
                      child: const Text('Stop'),
                    )
                  ]),
                  Column(children: [
                    const Text('BGM Long Tone (~1m 10s)'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: _startBgm,
                      child: const Text('Start'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: _stopBgm,
                      child: const Text('Stop'),
                    )
                  ]),
                ]),
          ],
        )
            : Container(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _startBgm() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('test-sine.mp3', volume: 0.1);
  }

  _stopBgm() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
  }

  _startSteps() {
    _stepsTimer = Timer.periodic(const Duration(milliseconds: 250), (t) async {
      await FlameAudio.play('test-step.mp3', volume: 1.0);
    });
  }

  _stopSteps() {
    _stepsTimer.cancel();
  }

  _startPoolSteps() {
    _poolStepsTimer =
        Timer.periodic(const Duration(milliseconds: 250), (t) async {
          await _stepPool.start(volume: 1.0);
        });
  }

  _stopPoolSteps() {
    _poolStepsTimer.cancel();
  }

  _startSoundPoolSteps() {
    _soundPoolStepsTimer =
        Timer.periodic(const Duration(milliseconds: 250), (t) async {
          await _soundPool.play(_soundId);
        });
  }

  _stopSoundPoolSteps() {
    _soundPoolStepsTimer.cancel();
  }
}
