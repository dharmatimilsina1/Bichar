
import 'package:flutter/material.dart';

void main() {
  runApp(const BicharApp());
}

class BicharApp extends StatelessWidget {
  const BicharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bichar',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: const Color(0xFFE50914),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _agreed = false;
  int _agreeCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo (1).jpg',
              height: 45,
              width: 45,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              'Bichar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 18),
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 15),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'आफ्नो विचार व्यक्त गर्नुहोस्',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'What is on your mind?',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () async {
                      final voice = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VoiceItPage(),
                        ),
                      );

                      if (!mounted) return;

                      if (voice != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text('Your voice: $voice'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'VOICE IT  +',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Voices',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 15),

          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bichar Community',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'विचार परिवर्तनको सुरुवात हो। '
                    'आफ्नो विचार राख्नुहोस् र अरूका विचार पनि सुन्नुहोस्।',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _agreed = !_agreed;

                            if (_agreed) {
                              _agreeCount++;
                            } else {
                              _agreeCount--;
                            }
                          });
                        },
                        icon: Icon(
                          _agreed
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          color: _agreed
                              ? Colors.red
                              : Colors.black54,
                        ),
                        label: Text(
                          'Agree $_agreeCount',
                          style: TextStyle(
                            color: _agreed
                                ? Colors.red
                                : Colors.black87,
                          ),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const OpinionPage(),
    ),
  );
},
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                        ),
                        label: const Text('Opinion'),
                      ),

                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                        ),
                        label: const Text('Spread'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ghar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Top Debate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Identity',
          ),
        ],
      ),
    );
  }
}

class VoiceItPage extends StatefulWidget {
  const VoiceItPage({super.key});

  @override
  State<VoiceItPage> createState() => _VoiceItPageState();
}

class _VoiceItPageState extends State<VoiceItPage> {
  final TextEditingController _voiceController =
      TextEditingController();

  @override
  void dispose() {
    _voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice It'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is on your mind?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _voiceController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Write your voice here...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final voice =
                      _voiceController.text.trim();

                  if (voice.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please write something first!',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, voice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('VOICE IT +'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OpinionPage extends StatefulWidget {
  const OpinionPage({super.key});

  @override
  State<OpinionPage> createState() => _OpinionPageState();
}

class _OpinionPageState extends State<OpinionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opinion'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Write your opinion here'),
      ),
    );
  }
}
