import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for compute

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Threading Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const HeavyComputationPage(),
    );
  }
}

class HeavyComputationPage extends StatefulWidget {
  const HeavyComputationPage({super.key});

  @override
  _HeavyComputationPageState createState() => _HeavyComputationPageState();
}

class _HeavyComputationPageState extends State<HeavyComputationPage> with SingleTickerProviderStateMixin {
  String _result = "Press start to compute factorials";
  bool _isComputing = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Faster animation speed
    )..repeat(reverse: true); // Moves left to right, then reverses

    _animation = Tween<double>(begin: -150, end: 150).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth transition
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Threading Example'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50), // Add some top padding for better view
            _buildAnimatedBox(),
            const SizedBox(height: 32),
            _buildComputationButtons(),
            const SizedBox(height: 32),
            _buildResult(),
          ],
        ),
      ),
    );
  }

  // Custom animated box widget
  Widget _buildAnimatedBox() {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0), // Move horizontally
            child: child,
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(16), // Rounded box
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(4, 4), // Subtle shadow effect
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Buttons for main thread and background thread computation
  Widget _buildComputationButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isComputing ? null : _startComputation,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.blueAccent,
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text(
            'Start Heavy Computation (Main Thread)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isComputing ? null : _startComputationInBackground,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.greenAccent[400],
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text(
            'Start Heavy Computation (Background Thread)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Display the result of the computation
  Widget _buildResult() {
    return Center(
      child: Text(
        _result,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Compute factorials on the main thread (UI will freeze)
  Future<void> _startComputation() async {
    setState(() {
      _isComputing = true;
      _result = "Computing on main thread...";
    });

    // Perform a very heavy factorial computation
    final result = computeFactorials(10000); // Heavy task
    setState(() {
      _result = "Computed factorial sum: $result";
      _isComputing = false;
    });
  }

  // Compute factorials in the background using `compute` (UI stays responsive)
  Future<void> _startComputationInBackground() async {
    setState(() {
      _isComputing = true;
      _result = "Computing on background thread...";
    });

    // Using compute to run it in a background isolate
    final result = await compute(computeFactorials, 10000);
    setState(() {
      _result = "Computed factorial sum: $result";
      _isComputing = false;
    });
  }
}

// Function to calculate the sum of factorials for heavy computation
int computeFactorials(int limit) {
  int sum = 0;
  for (int i = 1; i <= limit; i++) {
    sum += factorial(i);
  }
  return sum;
}

// Recursive function to calculate factorial
int factorial(int n) {
  if (n == 0 || n == 1) return 1;
  return n * factorial(n - 1);
}
