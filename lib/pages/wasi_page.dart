import 'package:flutter/material.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/data/mock_classes.dart';
import 'package:commongrounds/data/user_data.dart';

class WasiPage extends StatefulWidget {
  const WasiPage({super.key});

  @override
  State<WasiPage> createState() => _WasiPageState();
}

class _WasiPageState extends State<WasiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'role': 'assistant',
        'content':
            '${_getGreeting()}, ${UserData.name}! I am Wasi, your AI study assistant. I can help you check your tasks, deadlines, and class schedule. What would you like to know?',
      },
    ];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
    });

    // Simulate AI thinking time
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _generateResponse(text);
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateResponse(String input) {
    final lowerInput = input.toLowerCase();

    // Greetings
    if (lowerInput.contains('hello') ||
        lowerInput.contains('hi') ||
        lowerInput.contains('hey') ||
        lowerInput.contains('good morning')) {
      return "Hello there! I'm ready to help you organize your studies. You can ask me about your pending tasks or today's classes.";
    }

    // Who am I / User Name
    if (lowerInput.contains('who am i') ||
        lowerInput.contains('my name') ||
        lowerInput.contains('call me')) {
      return "You are ${UserData.name}. If you'd like me to call you something else, you can update your profile on the dashboard.";
    }

    // Who are you / Bot Identity
    if (lowerInput.contains('who are you') ||
        lowerInput.contains('your name') ||
        lowerInput.contains('what are you')) {
      return "I am Wasi, your personal AI study assistant. I'm here to help you manage your tasks, classes, and deadlines.";
    }

    // Progress / Status
    if (lowerInput.contains('progress') ||
        lowerInput.contains('how am i doing') ||
        lowerInput.contains('status')) {
      final total = mockDetailedTasks.length;
      final completed = mockDetailedTasks
          .where((t) => t.status == 'Completed')
          .length;
      final percent = total > 0 ? ((completed / total) * 100).toInt() : 0;
      return "You've completed $completed out of $total tasks ($percent%). You're doing great, ${UserData.name}! Keep it up!";
    }

    // Thanks
    if (lowerInput.contains('thank') || lowerInput.contains('thanks')) {
      return "You're welcome, ${UserData.name}! Let me know if you need anything else.";
    }

    // General Knowledge / Basic Chat
    if (lowerInput.contains('tips') ||
        lowerInput.contains('advice') ||
        lowerInput.contains('study')) {
      return "Here are some study tips:\n1. Break tasks into small chunks (like with Focus Mode!).\n2. Stay hydrated and take breaks.\n3. Teach what you've learned to someone else.";
    }

    if (lowerInput.contains('motivation') ||
        lowerInput.contains('tired') ||
        lowerInput.contains('give up')) {
      return "Don't give up, ${UserData.name}! 'The expert in anything was once a beginner.' Take a deep breath and tackle one small thing at a time.";
    }

    if (lowerInput.contains('joke') || lowerInput.contains('funny')) {
      return "Why did the developer go broke? Because he used up all his cache! 😄";
    }

    if (lowerInput.contains('meaning of life')) {
      return "42. But also, learning, growing, and building cool apps like this one!";
    }

    // Help
    if (lowerInput.contains('help') || lowerInput.contains('can you do')) {
      return "I can help you manage your academic life. Try asking:\n- 'What are my tasks?'\n- 'Do I have any deadlines?'\n- 'What classes do I have today?'\n- 'Show me my completed tasks'";
    }

    // Tasks / To-do
    if (lowerInput.contains('task') ||
        lowerInput.contains('todo') ||
        lowerInput.contains('assignment') ||
        lowerInput.contains('work')) {
      final pendingTasks = mockDetailedTasks
          .where((t) => t.status != 'Completed')
          .toList();
      if (pendingTasks.isEmpty) {
        return "You have no pending tasks. Great job staying on top of things!";
      }
      final taskList = pendingTasks
          .take(3)
          .map((t) => "• ${t.title} (${t.subject})")
          .join('\n');
      return "You have ${pendingTasks.length} pending tasks. Here are the top ones:\n$taskList";
    }

    // Deadlines / Due
    if (lowerInput.contains('deadline') || lowerInput.contains('due')) {
      final now = DateTime.now();
      final upcomingTasks =
          mockDetailedTasks
              .where((t) => t.status != 'Completed' && t.deadline.isAfter(now))
              .toList()
            ..sort((a, b) => a.deadline.compareTo(b.deadline));

      if (upcomingTasks.isEmpty) {
        return "You don't have any immediate deadlines coming up.";
      }

      final taskList = upcomingTasks
          .take(3)
          .map((t) {
            final dateStr = DateFormat('MMM d').format(t.deadline);
            return "• ${t.title} (Due: $dateStr)";
          })
          .join('\n');
      return "Here are your upcoming deadlines:\n$taskList";
    }

    // Completed Tasks
    if (lowerInput.contains('completed') ||
        lowerInput.contains('done') ||
        lowerInput.contains('finished')) {
      final completedTasks = mockDetailedTasks
          .where((t) => t.status == 'Completed')
          .toList();
      if (completedTasks.isEmpty) {
        return "You haven't completed any tasks yet. Keep going!";
      }
      return "You have completed ${completedTasks.length} tasks so far. Keep up the good work!";
    }

    // Classes / Schedule
    if (lowerInput.contains('class') || lowerInput.contains('schedule')) {
      final now = DateTime.now();
      String dayName = DateFormat('EEEE').format(now);

      if (lowerInput.contains('tomorrow')) {
        dayName = DateFormat('EEEE').format(now.add(const Duration(days: 1)));
      } else if (lowerInput.contains('monday')) {
        dayName = 'Monday';
      } else if (lowerInput.contains('tuesday')) {
        dayName = 'Tuesday';
      } else if (lowerInput.contains('wednesday')) {
        dayName = 'Wednesday';
      } else if (lowerInput.contains('thursday')) {
        dayName = 'Thursday';
      } else if (lowerInput.contains('friday')) {
        dayName = 'Friday';
      } else if (lowerInput.contains('saturday')) {
        dayName = 'Saturday';
      } else if (lowerInput.contains('sunday')) {
        dayName = 'Sunday';
      }

      final classesForDay = mockClasses.where((c) => c.day == dayName).toList();

      if (classesForDay.isEmpty) {
        return "You don't have any classes scheduled for $dayName.";
      }

      final classList = classesForDay
          .map((c) => "• ${c.subject} (${c.time})")
          .join('\n');
      return "Here is your schedule for $dayName:\n$classList";
    }

    // Default fallback
    return "I'm not sure I understand. Try asking about your 'tasks', 'deadlines', or 'classes'.";
  }

  @override
  Widget build(BuildContext context) {
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
          "Wasi AI",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask Wasi...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
