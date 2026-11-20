
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'आफ्नो विचार व्यक्त गर्नुहोस्',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'What is on your mind?',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const VoiceItPage(),
    ),
  );
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up_outlined),
                        label: const Text('Agree'),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Opinion'),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
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

