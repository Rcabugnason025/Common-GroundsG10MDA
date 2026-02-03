import 'dart:async';
import 'package:flutter/material.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:intl/intl.dart';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  Duration focusDuration = const Duration(minutes: 25);
  Duration shortBreakDuration = const Duration(minutes: 5);
  Duration longBreakDuration = const Duration(minutes: 15);

  bool isRunning = false;
  Timer? _timer;
  late Duration currentTime;
  late String currentMode; // "Focus", "Short Break", "Long Break"

  @override
  void initState() {
    super.initState();
    currentMode = "Focus Mode";
    currentTime = focusDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() async {
    // Show the "Pop-up" Alarm Clock View
    // The dialog itself manages the running timer state
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FocusTimerDialog(
        duration: currentTime,
        mode: currentMode,
        totalDuration: currentMode == "Focus Mode"
            ? focusDuration
            : currentMode == "Short Break"
            ? shortBreakDuration
            : longBreakDuration,
      ),
    );

    // When dialog closes, ensure state is reset or handled if needed
    setState(() {
      isRunning = false;
      // Reset current time to full duration for next run
      if (currentMode == "Focus Mode") {
        currentTime = focusDuration;
      } else if (currentMode == "Short Break")
        currentTime = shortBreakDuration;
      else
        currentTime = longBreakDuration;
    });
  }

  // Removed _showTimerDialog as it is replaced by FocusTimerDialog class

  void stopTimer() {
    // No-op for now as logic moved to dialog, but kept for button compatibility
    // if button is pressed while not running
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      if (currentMode == "Focus Mode") {
        currentTime = focusDuration;
      } else if (currentMode == "Short Break") {
        currentTime = shortBreakDuration;
      } else {
        currentTime = longBreakDuration;
      }
    });
  }

  void setMode(String mode) {
    stopTimer();
    setState(() {
      currentMode = mode;
      if (mode == "Focus Mode") {
        currentTime = focusDuration;
      } else if (mode == "Short Break") {
        currentTime = shortBreakDuration;
      } else {
        currentTime = longBreakDuration;
      }
    });
  }

  void adjustTime(String mode, int minutes) {
    setState(() {
      if (mode == "Focus Mode") {
        focusDuration = Duration(minutes: minutes);
        if (currentMode == "Focus Mode") currentTime = focusDuration;
      } else if (mode == "Short Break") {
        shortBreakDuration = Duration(minutes: minutes);
        if (currentMode == "Short Break") currentTime = shortBreakDuration;
      } else {
        longBreakDuration = Duration(minutes: minutes);
        if (currentMode == "Long Break") currentTime = longBreakDuration;
      }
    });
  }

  String formatTime(Duration duration) {
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d, y').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading:
            (ModalRoute.of(context)?.settings.arguments is Map &&
                (ModalRoute.of(context)?.settings.arguments
                        as Map)['showBackButton'] ==
                    true)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "Focus",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // FOCUS
              GestureDetector(
                onTap: () => setMode("Focus Mode"),
                child: Opacity(
                  opacity: currentMode == "Focus Mode" ? 1.0 : 0.5,
                  child: _buildTimerSection("Focus Mode", focusDuration),
                ),
              ),
              const SizedBox(height: 20),

              // SHORT BREAK
              GestureDetector(
                onTap: () => setMode("Short Break"),
                child: Opacity(
                  opacity: currentMode == "Short Break" ? 1.0 : 0.5,
                  child: _buildTimerSection("Short Break", shortBreakDuration),
                ),
              ),
              const SizedBox(height: 20),

              // LONG BREAK
              GestureDetector(
                onTap: () => setMode("Long Break"),
                child: Opacity(
                  opacity: currentMode == "Long Break" ? 1.0 : 0.5,
                  child: _buildTimerSection("Long Break", longBreakDuration),
                ),
              ),
              const SizedBox(height: 30),

              // MAIN TIMER DISPLAY
              Text(
                formatTime(currentTime),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 30),

              // HISTORY + START BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Show history modal
                      },
                      child: const Text("History"),
                    ),
                  ),
                  const SizedBox(width: 20), // 👈 closer spacing
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: isRunning ? stopTimer : startTimer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(isRunning ? "Stop" : "Start"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(String label, Duration duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            // show a dialog to adjust minutes
            int? newMinutes = await _showAdjustDialog(
              label,
              duration.inMinutes,
            );
            if (newMinutes != null) {
              adjustTime(label, newMinutes);
            }
          },
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${duration.inMinutes.toString().padLeft(2, '0')}:00",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<int?> _showAdjustDialog(String mode, int currentMinutes) async {
    final controller = TextEditingController(text: currentMinutes.toString());
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set $mode Minutes"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Minutes"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

class FocusTimerDialog extends StatefulWidget {
  final Duration duration;
  final Duration totalDuration;
  final String mode;

  const FocusTimerDialog({
    super.key,
    required this.duration,
    required this.totalDuration,
    required this.mode,
  });

  @override
  State<FocusTimerDialog> createState() => _FocusTimerDialogState();
}

class _FocusTimerDialogState extends State<FocusTimerDialog> {
  late Duration currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    currentTime = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (currentTime.inSeconds > 0) {
          currentTime = currentTime - const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          // Timer finished
          // We can show a completion message or just pop
          // For now, let's pop and show a snackbar in parent?
          // Or show a "Done" state here.
          // Let's pop.
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("${widget.mode} completed!")));
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.mode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: widget.totalDuration.inSeconds > 0
                          ? currentTime.inSeconds /
                                widget.totalDuration.inSeconds
                          : 0,
                      strokeWidth: 20,
                      backgroundColor: Colors.grey.shade300,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    formatTime(currentTime),
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  // Stop/Cancel
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Stop",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
