import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepsTodayView extends StatefulWidget {
  const StepsTodayView({super.key});

  @override
  State<StepsTodayView> createState() => _StepsTodayViewState();
}

class _StepsTodayViewState extends State<StepsTodayView> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  int? _initialSteps;
  Future<void> _checkPermissions() async {
    final status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions().then((_) => _startStepCounting());
  }

  void _startStepCounting() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: true,
    );
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _initialSteps ??= event.steps;
      _steps = event.steps - (_initialSteps ?? 0);
    });
  }

  void _onStepCountError(error) {
    setState(() => _steps = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Step Counter"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_walk, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text('Steps Today:', style: TextStyle(fontSize: 24)),
            Text(
              '$_steps',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Walking reduces anxiety, boosts mood, and clears your thoughts. Keep moving! 💪',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
