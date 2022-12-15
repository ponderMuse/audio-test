import 'dart:async';

import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

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

  late AudioPool _stepPool;

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
                    'Push button to start audio',
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          const Text('BGM Music'),
                          ElevatedButton(
                            onPressed: _startBgm,
                            child: const Text('Start'),
                          ),
                          ElevatedButton(
                            onPressed: _stopBgm,
                            child: const Text('Stop'),
                          )
                        ]),
                        Column(children: [
                          const Text('Steps FX via FlameAudio.Play'),
                          ElevatedButton(
                            onPressed: _startSteps,
                            child: const Text('Start'),
                          ),
                          ElevatedButton(
                            onPressed: _stopSteps,
                            child: const Text('Stop'),
                          )
                        ]),
                        Column(children: [
                          const Text('Steps FX via AudioPool.Start'),
                          ElevatedButton(
                            onPressed: _startPoolSteps,
                            child: const Text('Start'),
                          ),
                          ElevatedButton(
                            onPressed: _stopPoolSteps,
                            child: const Text('Stop'),
                          )
                        ])
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
}
