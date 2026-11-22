import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  final TextEditingController composerController =
      TextEditingController();

  final FocusNode composerFocusNode = FocusNode();

  final ImagePicker picker = ImagePicker();

  bool composerVisible = false;
  bool isSubmitting = false;
  bool isOpinion = false;

  String? activeOpinionPostId;
  XFile? selectedImage;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openComposer() {
    setState(() {
      composerVisible = true;
      isOpinion = false;
      activeOpinionPostId = null;
      selectedImage = null;
    });

    FocusScope.of(context).requestFocus(composerFocusNode);
  }

  void openOpinionComposer(String postId) {
    setState(() {
      composerVisible = true;
      isOpinion = true;
      activeOpinionPostId = postId;
      selectedImage = null;
    });

    FocusScope.of(context).requestFocus(composerFocusNode);
  }

  Future<void> pickImage() async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage('फोटो छान्न सकिएन');
      }
    }
  }

  Future<void> submitComposer() async {
    final text = composerController.text.trim();

    if (text.isEmpty) {
      showMessage('पहिले आफ्नो विचार लेख्नुहोस्');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('पहिले Login गर्नुहोस्');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      if (isOpinion && activeOpinionPostId != null) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(activeOpinionPostId)
            .collection('opinions')
            .add({
          'uid': user.uid,
          'name': user.displayName ?? 'User',
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          showMessage('Opinion प्रकाशित भयो');
        }
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .add({
          'uid': user.uid,
          'name': user.displayName ?? 'User',
          'text': text,
          'photoPath': selectedImage?.path,
          'createdAt': FieldValue.serverTimestamp(),
          'agreedBy': [],
        });

        if (mounted) {
          showMessage('तपाईंको विचार प्रकाशित भयो');
        }
      }

      if (mounted) {
        composerController.clear();

        setState(() {
          composerVisible = false;
          isSubmitting = false;
          isOpinion = false;
          activeOpinionPostId = null;
          selectedImage = null;
        });

        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });

        showMessage('प्रकाशित गर्न सकिएन: $e');
      }
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

  Future<void> spreadPost(String text) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          title: 'Bichar - Spread this Voice',
        ),
      );
    } catch (e) {
      if (mounted) {
        showMessage('पोस्ट Share गर्न सकिएन');
      }
    }
  }

  Widget buildComposer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isOpinion ? 'Write your Opinion' : 'Voice your thoughts',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        setState(() {
                          composerVisible = false;
                          isOpinion = false;
                          activeOpinionPostId = null;
                          selectedImage = null;
                        });

                        composerController.clear();
                        FocusScope.of(context).unfocus();
                      },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          TextField(
            controller: composerController,
            focusNode: composerFocusNode,
            autofocus: true,
            maxLines: 5,
            minLines: 2,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'What is on your mind?',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          if (!isOpinion) ...[
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : pickImage,
              icon: const Icon(
                Icons.photo_library_outlined,
                color: Colors.red,
              ),
              label: const Text('Add Photo'),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(selectedImage!.path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Photo'),
              ),
            ],
          ],

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: isSubmitting ? null : submitComposer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isSubmitting
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    isOpinion ? 'PUBLISH OPINION' : 'VOICE IT',
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildGhar() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 21, 16, 8),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo (1).jpg',
                  width: 45,
                  height: 45,
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
            onTap: openComposer,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
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

        if (composerVisible) buildComposer(),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
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
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
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
                      openOpinionComposer(post.id);
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
  void dispose() {
    composerController.dispose();
    composerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

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
          FocusScope.of(context).unfocus();

          setState(() {
            selectedIndex = index;
            composerVisible = false;
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
            
if (data['photoPath'] != null &&
    data['photoPath'].toString().isNotEmpty &&
    File(data['photoPath'].toString()).existsSync()) ...[
  const SizedBox(height: 12),
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.file(
      File(data['photoPath'].toString()),
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
    ),
  ),
],
            

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

// VOICE IT PAGE


class VoiceItPage extends StatefulWidget {
  const VoiceItPage({super.key});

  @override
  State<VoiceItPage> createState() => _VoiceItPageState();
}

class _VoiceItPageState extends State<VoiceItPage> {
  final controller = TextEditingController();
  final ImagePicker picker = ImagePicker();

  XFile? selectedImage;
  bool loading = false;

  Future<void> pickImage() async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('फोटो छान्न सकिएन'),
          ),
        );
      }
    }
  }

  
void submit() {
  final text = controller.text.trim();

  if (text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('पहिले आफ्नो विचार लेख्नुहोस्'),
      ),
    );
    return;
  }

  Navigator.pop(context, {
    'text': text,
    'photoPath': selectedImage?.path,
  });
}
  

  @override
  void dispose() {
    controller.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLines: 8,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: loading ? null : pickImage,
              icon: const Icon(
                Icons.photo_library_outlined,
                color: Colors.red,
              ),
              label: const Text('Add Photo from Gallery'),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(selectedImage!.path),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Photo'),
              ),
            ],

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('VOICE IT'),
            ),
          ],
        ),
      ),
    );
  }
}


// OPINION PAGE

class OpinionPage extends StatefulWidget {
  const OpinionPage({super.key});

  @override
  State<OpinionPage> createState() => _OpinionPageState();
}

class _OpinionPageState extends State<OpinionPage> {
  final controller = TextEditingController();

  void submit() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पहिले आफ्नो Opinion लेख्नुहोस्')),
      );
      return;
    }

    Navigator.pop(context, text);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Opinion'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 7,
              maxLength: 1500,
              decoration: const InputDecoration(
                hintText: 'Write your opinion...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
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

// IDENTITY PAGE

class IdentityPage extends StatelessWidget {
  const IdentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Login गर्नुहोस्'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() ?? {};
        final name = data['name']?.toString() ??
            user.displayName ??
            'User';
        final email = data['email']?.toString() ?? user.email ?? '';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 25),
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFFFDAD6),
                child: Icon(
                  Icons.person,
                  size: 55,
                  color: Colors.brown,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                email,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Identity'),
              subtitle: Text('Your Bichar account'),
            ),
            const Divider(),
            const Text(
              'Your Voices',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, postSnapshot) {
                if (postSnapshot.hasError) {
                  return const Text('पोस्ट देखाउन समस्या भयो');
                }

                if (!postSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final posts = postSnapshot.data!.docs;

                if (posts.isEmpty) {
                  return const Text('तपाईंले अहिलेसम्म पोस्ट गर्नुभएको छैन।');
                }

                return Column(
                  children: posts.map((post) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.forum_outlined,
                          color: Colors.red,
                        ),
                        title: Text(
                          post.data()['text']?.toString() ?? '',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// SETTINGS PAGE

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> editName(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final controller = TextEditingController(
      text: user.displayName ?? '',
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Identity'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || newName.isEmpty) return;

    try {
      await user.updateDisplayName(newName);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'name': newName});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('नाम परिवर्तन भयो')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('नाम परिवर्तन गर्न सकिएन')),
        );
      }
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$email मा Password Reset Email पठाइयो'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'समस्या भयो')),
        );
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('के तपाईं Logout गर्न चाहनुहुन्छ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.red),
            title: const Text('Edit Identity'),
            subtitle: const Text('Change your name'),
            onTap: () => editName(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.red),
            title: const Text('Change Password'),
            subtitle: const Text('Receive password reset email'),
            onTap: () => resetPassword(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.red),
            title: Text('Privacy Settings'),
            subtitle: Text('Privacy information'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}

// EXPLORES PAGE

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search Voices...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
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
              if (snapshot.hasError) {
                return const Center(
                  child: Text('खोज्न समस्या भयो'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final posts = snapshot.data!.docs.where((post) {
                final text = post.data()['text']
                    ?.toString()
                    .toLowerCase() ?? '';
                final name = post.data()['name']
                    ?.toString()
                    .toLowerCase() ?? '';

                return text.contains(searchText) ||
                    name.contains(searchText);
              }).toList();

              if (posts.isEmpty) {
                return const Center(
                  child: Text('कुनै Voice भेटिएन'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final data = posts[index].data();

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(data['name'] ?? 'User'),
                      subtitle: Text(data['text'] ?? ''),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// TOP DEBATES PAGE

class TopDebatesPage extends StatelessWidget {
  const TopDebatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Top Debates लोड गर्न समस्या भयो'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final posts = snapshot.data!.docs.toList();

        posts.sort((a, b) {
          final aCount =
              (a.data()['agreedBy'] as List?)?.length ?? 0;
          final bCount =
              (b.data()['agreedBy'] as List?)?.length ?? 0;

          return bCount.compareTo(aCount);
        });

        if (posts.isEmpty) {
          return const Center(
            child: Text('अहिलेसम्म कुनै Debate छैन'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index].data();
            final count =
                (data['agreedBy'] as List?)?.length ?? 0;

            return Card(
              color: const Color(0xFFFFF0EF),
              child: ListTile(
                leading: const Icon(
                  Icons.trending_up,
                  color: Colors.red,
                ),
                title: Text(data['text'] ?? ''),
                subtitle: Text(
                  '${data['name'] ?? 'User'} · Agree ($count)',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ACTIVITY PAGE

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Login गर्नुहोस्'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Activity लोड गर्न समस्या भयो'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return const Center(
            child: Text('अहिलेसम्म कुनै Activity छैन'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Your Recent Voices',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...posts.map((post) {
              final data = post.data();

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: Colors.red,
                  ),
                  title: Text(data['text'] ?? ''),
                  subtitle: const Text('Your Voice'),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// भाग ३ समाप्त
