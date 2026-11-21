
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const AuthGate(),
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
  List<String> _opinions = [];
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
                  if (_opinions.isNotEmpty) ...[
  const Divider(),
  const Text(
    'Opinions',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  const SizedBox(height: 8),
  ..._opinions.map(
    (opinion) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('• $opinion'),
    ),
  ),
],

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
                        onPressed: () async {
  final opinion = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => const OpinionPage(),
    ),
  );

  if (!mounted) return;
    
 if (opinion != null) {
  setState(() {
    _opinions.add(opinion);
  });
 } 
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
  final TextEditingController _opinionController =
      TextEditingController();

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opinion'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      TextField(
        controller: _opinionController,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: 'Write your opinion here...',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
  final opinion = _opinionController.text.trim();

  if (opinion.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please write your opinion first!'),
      ),
    );
    return;
  }

  Navigator.pop(context, opinion);
},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('SUBMIT OPINION'),
        ),
      ),
    ],
  ),
),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Something went wrong')),
        );
      }
    }
  }
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Bichar Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            TextButton(
  onPressed: _resetPassword,
  child: const Text(
    'Forgot Password?',
    style: TextStyle(color: Colors.red),
  ),
),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(_loading ? 'Please wait...' : 'LOGIN'),
              ),
              TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
    );
  },
  child: const Text(
    'Create New Account',
    style: TextStyle(color: Colors.red),
  ),
),
            ),
          ],
        ),
      ),
    );
  }
}
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _signup() async {
    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await credential.user?.updateDisplayName(
        _nameController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Signup failed'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _loading ? 'Please wait...' : 'CREATE ACCOUNT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
