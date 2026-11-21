import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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

// LOGIN PAGE

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email र Password लेख्नुहोस्');
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Login असफल भयो');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('पहिले Email लेख्नुहोस्');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
      showMessage('Password reset email पठाइयो');
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'समस्या भयो');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bichar Login'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 70),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: loading ? null : resetPassword,
                child: const Text('Forgot Password?'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(loading ? 'Please wait...' : 'LOGIN'),
              ),
            ),
            TextButton(
              onPressed: loading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
              child: const Text('Create New Account'),
            ),
          ],
        ),
      ),
    );
  }
}

// SIGNUP PAGE

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('सबै विवरण भर्नुहोस्');
      return;
    }

    if (password.length < 6) {
      showMessage('Password कम्तीमा ६ अक्षरको हुनुपर्छ');
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Account बनाउन सकिएन');
      }

      await user.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showMessage('Account सफलतापूर्वक बन्यो');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Signup असफल भयो');
    } on FirebaseException catch (e) {
      showMessage(e.message ?? 'Profile सुरक्षित गर्न सकिएन');
    } catch (e) {
      showMessage('केही समस्या भयो');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
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
                onPressed: loading ? null : signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  loading ? 'Please wait...' : 'CREATE ACCOUNT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// भाग १ समाप्त

// HOME PAGE

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Ghar',
    'Explores',
    'Top Debates',
    'Activity',
    'Identity',
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> openVoiceIt() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const VoiceItPage(),
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'text': result.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'agreedBy': [],
      });

      if (mounted) showMessage('तपाईंको विचार प्रकाशित भयो');
    } catch (e) {
      if (mounted) showMessage('पोस्ट सुरक्षित गर्न सकिएन: $e');
    }
  }

  Future<void> openOpinion(String postId) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const OpinionPage(),
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('opinions')
          .add({
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'text': result.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) showMessage('Opinion प्रकाशित भयो');
    } catch (e) {
      if (mounted) showMessage('Opinion सुरक्षित गर्न सकिएन');
    }
  }

  Future<void> toggleAgree(
    DocumentReference<Map<String, dynamic>> postRef,
    List<String> agreedBy,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (agreedBy.contains(user.uid)) {
        await postRef.update({
          'agreedBy': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        await postRef.update({
          'agreedBy': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      if (mounted) showMessage('Agree गर्न सकिएन');
    }
  }

  void spreadPost(String text) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Spread this Voice'),
          content: SelectableText(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Widget buildGhar() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo (1).jpg',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      radius: 26,
                      child: Icon(Icons.forum),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bichar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 30,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Welcome, ${user?.displayName ?? 'User'}',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: openVoiceIt,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.red, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'What is on your mind? Voice it...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 16, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Voices',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'पोस्ट लोड गर्न समस्या भयो।',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final posts = snapshot.data?.docs ?? [];

              if (posts.isEmpty) {
                return const Center(
                  child: Text(
                    'अहिलेसम्म कुनै Voice छैन।\nपहिलो विचार तपाईं राख्नुहोस्!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];

                  return PostCard(
                    post: post,
                    onAgree: (agreedBy) {
                      toggleAgree(post.reference, agreedBy);
                    },
                    onOpinion: () {
                      openOpinion(post.id);
                    },
                    onSpread: (text) {
                      spreadPost(text);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return buildGhar();
      case 1:
        return const ExplorePage();
      case 2:
        return const TopDebatesPage();
      case 3:
        return const ActivityPage();
      case 4:
        return const IdentityPage();
      default:
        return buildGhar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedIndex == 0
          ? null
          : AppBar(
              title: Text(titles[selectedIndex]),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),

      body: buildSelectedPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
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

// POST CARD

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> post;
  final Function(List<String>) onAgree;
  final VoidCallback onOpinion;
  final Function(String) onSpread;

  const PostCard({
    super.key,
    required this.post,
    required this.onAgree,
    required this.onOpinion,
    required this.onSpread,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.data();
    final user = FirebaseAuth.instance.currentUser;
    final agreedBy = List<String>.from(data['agreedBy'] ?? []);
    final hasAgreed = user != null && agreedBy.contains(user.uid);
    final text = data['text']?.toString() ?? '';
    final name = data['name']?.toString() ?? 'User';

    return Card(
      color: const Color(0xFFFFF0EF),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFDAD6),
                  child: Icon(Icons.person, color: Colors.brown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onAgree(agreedBy),
                    icon: Icon(
                      hasAgreed
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Agree (${agreedBy.length})',
                      style: TextStyle(
                        color: hasAgreed ? Colors.red : Colors.brown,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onOpinion,
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.brown,
                    ),
                    label: const Text(
                      'Opinion',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onSpread(text),
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.brown,
                    ),
                    label: const Text(
                      'Spread',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                ),
              ],
            ),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: post.reference
                  .collection('opinions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final opinions = snapshot.data?.docs ?? [];

                if (opinions.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      'Opinions (${opinions.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...opinions.take(3).map((opinion) {
                      final opinionData = opinion.data();

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.person_outline,
                          color: Colors.red,
                        ),
                        title: Text(
                          opinionData['name']?.toString() ?? 'User',
                        ),
                        subtitle: Text(
                          opinionData['text']?.toString() ?? '',
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// भाग २ समाप्त
