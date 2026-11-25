
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ==========================================
// MAIN
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BicharApp());
}

// ==========================================
// BICHAR APP
// ==========================================

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ==========================================
// AUTH GATE
// ==========================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

// ==========================================
// LOGIN PAGE
// ==========================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

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
        title: const Text(
          'Bichar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 35),

                const Icon(
                  Icons.forum_rounded,
                  size: 75,
                  color: Colors.red,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Bichar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Your Voice, Your Opinion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: loading ? null : resetPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 23,
                            width: 23,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Text("Don't have an account?"),
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
                      child: const Text(
                        'Create New Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SIGNUP PAGE
// ==========================================

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
  bool obscurePassword = true;

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
          .collection('publicProfiles')
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),

              const Icon(
                Icons.person_add_alt_1_rounded,
                size: 70,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                'Join Bichar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SECTION 1 END
// SECTION 2 STARTS WITH HOMEPAGE
// ==========================================

// ==========================================
// HOME PAGE
// ==========================================

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
      if (mounted) {
        showMessage('Agree गर्न सकिएन');
      }
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
                  isOpinion
                      ? 'Write your Opinion'
                      : 'Voice your thoughts',
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
                      builder: (_) => SettingsPage(),
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
        return ExplorePage();

      case 2:
        return TopDebatesPage();

      case 3:
        return ActivityPage();

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
                        builder: (_) => SettingsPage(),
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

// ==========================================
// POST CARD
// ==========================================

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> post;
  final ValueChanged<List<String>> onAgree;
  final VoidCallback onOpinion;
  final ValueChanged<String> onSpread;

  const PostCard({
    super.key,
    required this.post,
    required this.onAgree,
    required this.onOpinion,
    required this.onSpread,
  });

  // EDIT POST

  Future<void> editPost(BuildContext context) async {
    final controller = TextEditingController(
      text: post.data()['text']?.toString() ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Voice'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Edit your voice...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    try {
      await post.reference.update({
        'text': result,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('पोस्ट Edit गर्न सकिएन'),
          ),
        );
      }
    }
  }
  // ==========================================
  // DELETE POST
  // ==========================================

  Future<void> deletePost(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Voice?'),
          content: const Text(
            'के तपाईं यो पोस्ट हटाउन चाहनुहुन्छ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await post.reference.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('पोस्ट हटाइयो'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('पोस्ट हटाउन सकिएन'),
          ),
        );
      }
    }
  }

// TIME AGO

String timeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

    @override
  Widget build(BuildContext context) {
    final data = post.data();

    final user = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid ?? '';

    final postUid = data['uid']?.toString() ?? '';
    final name = data['name']?.toString() ?? 'User';
    final createdAt = data['createdAt'] is Timestamp
    ? (data['createdAt'] as Timestamp).toDate()
    : null;
    final text = data['text']?.toString() ?? '';
    final photoPath = data['photoPath']?.toString() ?? '';

    final agreedBy = data['agreedBy'] is List
        ? List<String>.from(data['agreedBy'])
        : <String>[];

    final hasAgreed = agreedBy.contains(currentUid);
    final isOwner = currentUid == postUid;

    final hasPhoto = photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER INFORMATION

            Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  backgroundColor: Color(0xFFFFDAD6),
                  child: Icon(
                    Icons.person,
                    color: Colors.brown,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),

      if (createdAt != null) ...[
        const SizedBox(height: 3),
        Text(
          timeAgo(createdAt),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    ],
  ),
),

                if (isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        editPost(context);
                      } else if (value == 'delete') {
                        deletePost(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // POST TEXT

            if (text.isNotEmpty)
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

            // POST PHOTO

            if (hasPhoto) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
  File(photoPath),
  width: double.infinity,
  height: 300,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: Text('फोटो देखाउन सकिएन'),
      ),
    );
  },
),
              ),
            ],

            const SizedBox(height: 12),

            // AGREE COUNT

            Text(
              '${agreedBy.length} Agrees',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const Divider(height: 20),

            // POST ACTIONS             
            
Row(
  children: [
    Expanded(
      child: TextButton.icon(
        onPressed: () => onAgree(agreedBy),
        icon: Icon(
          Icons.thumb_up_alt_outlined,
          color: hasAgreed ? Colors.red : Colors.grey,
        ),
        label: Text(
          'Agree',
          style: TextStyle(
            color: hasAgreed ? Colors.red : Colors.grey,
          ),
        ),
      ),
    ),

    Expanded(
      child: TextButton.icon(
        onPressed: onOpinion,
        icon: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.grey,
        ),
        label: const Text(
          'Opinion',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ),

    Expanded(
      child: TextButton.icon(
        onPressed: () => onSpread(text),
        icon: const Icon(
          Icons.share_outlined,
          color: Colors.grey,
        ),
        label: const Text(
          'Spread',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ),
  ],
),
                      
              
        

            const Divider(height: 15),

            // RECENT OPINIONS

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: post.reference
                  .collection('opinions')
                  .orderBy('createdAt', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, opinionSnapshot) {
                if (opinionSnapshot.hasError) {
                  return const Text(
                    'Opinion देखाउन समस्या भयो',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                if (!opinionSnapshot.hasData ||
                    opinionSnapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                final opinions = opinionSnapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Opinions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...opinions.map((opinion) {
                      final opinionData = opinion.data();

                      final opinionName =
                          opinionData['name']?.toString() ?? 'User';

                      final opinionText =
                          opinionData['text']?.toString() ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 15,
                              backgroundColor: Color(0xFFFFDAD6),
                              child: Icon(
                                Icons.person,
                                size: 17,
                                color: Colors.brown,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opinionName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    opinionText,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

// ==========================================
// POST CARD समाप्त
// ==========================================

// ==========================================
// VOICE IT PAGE
// ==========================================

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
  bool isPickingPhoto = false;

  Future<void> pickImage() async {
    if (loading || isPickingPhoto) return;

    setState(() {
      isPickingPhoto = true;
    });

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
    } finally {
      if (mounted) {
        setState(() {
          isPickingPhoto = false;
        });
      }
    }
  }

  void submit() {
    if (loading) return;

    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पहिले आफ्नो विचार लेख्नुहोस्'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

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
              onPressed: loading || isPickingPhoto
                  ? null
                  : pickImage,
              icon: isPickingPhoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.red,
                    ),
              label: Text(
                isPickingPhoto
                    ? 'Selecting Photo...'
                    : 'Add Photo from Gallery',
              ),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(selectedImage!.path),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              TextButton.icon(
                onPressed: loading
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

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading || isPickingPhoto
                  ? null
                  : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('VOICE IT'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// भाग ३ समाप्त
// ==========================================

// ==========================================
// OPINION PAGE
// ==========================================

class OpinionPage extends StatefulWidget {
  const OpinionPage({super.key});

  @override
  State<OpinionPage> createState() => _OpinionPageState();
}

class _OpinionPageState extends State<OpinionPage> {
  final controller = TextEditingController();
  bool isSubmitting = false;

  void submit() {
    if (isSubmitting) return;

    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पहिले आफ्नो Opinion लेख्नुहोस्'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

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
      body: SingleChildScrollView(
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
                onPressed: isSubmitting ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: isSubmitting
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
    : const Text('SUBMIT OPINION'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// खण्ड ४ समाप्त
// ==========================================

// ==========================================
// IDENTITY PAGE
// ==========================================

class IdentityPage extends StatefulWidget {
  const IdentityPage({super.key});

  @override
  State<IdentityPage> createState() => _IdentityPageState();
}

class _IdentityPageState extends State<IdentityPage> {
  final ImagePicker picker = ImagePicker();
  bool isPickingPhoto = false;

  late Future<Directory> directoryFuture;

  @override
  void initState() {
    super.initState();
    directoryFuture = getApplicationDocumentsDirectory();
  }

  // PICK PROFILE PHOTO

  Future<void> pickProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || isPickingPhoto) return;

    setState(() {
      isPickingPhoto = true;
    });

    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();

      final photoPath =
          '${directory.path}/profile_${user.uid}.jpg';

      await File(image.path).copy(photoPath);

if (!mounted) return;

setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('प्रोफाइल फोटो सुरक्षित भयो'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('फोटो राख्न सकिएन'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPickingPhoto = false;
        });
      }
    }
  }

  // EDIT ABOUT ME

  Future<void> editAboutMe(String oldAboutMe) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final controller = TextEditingController(
      text: oldAboutMe,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About Me'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'आफ्नो बारेमा लेख्नुहोस्...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'aboutMe': result,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('About Me सुरक्षित भयो'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('About Me सुरक्षित गर्न सकिएन'),
          ),
        );
      }
    }
  }

  // ==========================================
  // PROFILE STATISTICS
 // ==========================================
  
  Widget buildStat(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Login गर्नुहोस्'),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (userSnapshot.hasError) {
          return const Center(
            child: Text('Profile खोल्न समस्या भयो'),
          );
        }

        final data = userSnapshot.data?.data() ?? {};

        final name = data['name']?.toString() ??
            user.displayName ??
            'User';

        final email = data['email']?.toString() ??
            user.email ??
            '';

        final aboutMe =
            data['aboutMe']?.toString() ?? '';

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, postSnapshot) {
            final posts = postSnapshot.data?.docs ?? [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('followers')
                  .snapshots(),
              builder: (context, followerSnapshot) {
                final followers =
                    followerSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('following')
                      .snapshots(),
                  builder: (context, followingSnapshot) {
                    final following =
                        followingSnapshot.data?.docs.length ?? 0;

                    return FutureBuilder<Directory>(
                      future: directoryFuture,
                      builder: (context, directorySnapshot) {
                        final savedPhotoPath =
                            directorySnapshot.hasData
                                ? '${directorySnapshot.data!.path}/profile_${user.uid}.jpg'
                                : '';

                        final hasPhoto =
                            savedPhotoPath.isNotEmpty &&
                            File(savedPhotoPath).existsSync();

                        return ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            const SizedBox(height: 20),

                            // PROFILE PHOTO

                            Center(
                              child: GestureDetector(
                                onTap: isPickingPhoto
                                    ? null
                                    : pickProfilePhoto,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundColor:
                                          const Color(0xFFFFDAD6),
                                      backgroundImage: hasPhoto
                                          ? FileImage(
                                              File(savedPhotoPath),
                                            )
                                          : null,
                                      child: hasPhoto
                                          ? null
                                          : const Icon(
                                              Icons.person,
                                              size: 55,
                                              color: Colors.brown,
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 17,
                                        backgroundColor: Colors.red,
                                        child: isPickingPhoto
                                            ? const Padding(
                                                padding:
                                                    EdgeInsets.all(8),
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.camera_alt,
                                                size: 19,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Center(
                              child: Text(
                                'Change Profile Photo',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // NAME

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
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25), 
                                                                                                                                                                                                                               
                            // ==========================================
                            // PROFILE STATISTICS
                            // ==========================================

                            Card(
                              elevation: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Row(
                                  children: [
                                    buildStat(
                                      postSnapshot.hasError
                                          ? '—'
                                          : posts.length.toString(),
                                      'Voices',
                                    ),
                                    buildStat(
                                      followerSnapshot.hasError
                                          ? '—'
                                          : followers.toString(),
                                      'Followers',
                                    ),
                                    buildStat(
                                      followingSnapshot.hasError
                                          ? '—'
                                          : following.toString(),
                                      'Following',
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==========================================
                            // ABOUT ME
                            // ==========================================

                            Card(
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'About Me',
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            editAboutMe(aboutMe);
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      aboutMe.isEmpty
                                          ? 'आफ्नो बारेमा केही लेख्नुहोस्।'
                                          : aboutMe,
                                      style: TextStyle(
                                        color: aboutMe.isEmpty
                                            ? Colors.grey
                                            : Colors.black87,
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // MY VOICES

                            const Text(
                              'My Voices',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (postSnapshot.hasError)
                              const Text(
                                'पोस्ट देखाउन समस्या भयो',
                              )
                            else if (!postSnapshot.hasData)
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            else if (posts.isEmpty)
                              const Text(
                                'तपाईंले अहिलेसम्म पोस्ट गर्नुभएको छैन।',
                              )
                            else
                              ...posts.map((post) {
                                final postData = post.data();

                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.forum_outlined,
                                      color: Colors.red,
                                    ),
                                    title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if ((postData['text']?.toString() ?? '').isNotEmpty)
      Text(
        postData['text'].toString(),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),

    if ((postData['photoPath']?.toString() ?? '').isNotEmpty &&
        File(postData['photoPath'].toString()).existsSync()) ...[
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(postData['photoPath'].toString()),
          width: double.infinity,
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    ],
  ],
),
                                    ),
                                );
                              }),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// खण्ड ५ समाप्त


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // EDIT IDENTITY

  Future<void> editIdentity(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final controller = TextEditingController(
      text: user.displayName ?? '',
    );

    try {
      final result = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Identity'),
            content: TextField(
              controller: controller,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  Navigator.pop(dialogContext, name);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (!context.mounted || result == null) return;

      await user.updateDisplayName(result);

            final firestore = FirebaseFirestore.instance;

      await firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'name': result,
      });

      await firestore
          .collection('publicProfiles')
          .doc(user.uid)
          .update({
        'name': result,
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('नाम परिवर्तन भयो'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('नाम परिवर्तन गर्न सकिएन'),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  // CHANGE PASSWORD

  Future<void> changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) return;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password Reset Email पठाइयो'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email पठाउन सकिएन'),
        ),
      );
    }
  }

  // LOGOUT

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'के तपाईं Logout गर्न चाहनुहुन्छ?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout गर्न सकिएन'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ACCOUNT',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Identity'),
            subtitle: const Text('Change your name'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => editIdentity(context),
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Reset password through email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => changePassword(context),
          ),

          const Divider(height: 30),

          const Text(
            'PRIVACY',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Settings'),
            subtitle: Text(
              'Privacy information and policies',
            ),
          ),

          const Divider(height: 30),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}

// खण्ड ६ समाप्त

// EXPLORE PAGE

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'People'),
              Tab(text: 'Voices'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ExplorePeopleTab(),
            ExploreVoicesTab(),
          ],
        ),
      ),
    );
  }
}

// EXPLORE PEOPLE

class ExplorePeopleTab extends StatelessWidget {
  const ExplorePeopleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('publicProfiles')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('People देखाउन समस्या भयो'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final profiles = snapshot.data!.docs;

        if (profiles.isEmpty) {
          return const Center(
            child: Text('कुनै People भेटिएन'),
          );
        }

        return ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index].data();

            final name = profile['name']?.toString() ?? 'User';
            final aboutMe = profile['aboutMe']?.toString() ?? '';

            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(name),
              subtitle: aboutMe.isNotEmpty
                  ? Text(
                      aboutMe,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const Text('No bio'),
            );
          },
        );
      },
    );
  }
}

// EXPLORE VOICES

class ExploreVoicesTab extends StatelessWidget {
  const ExploreVoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Voices देखाउन समस्या भयो'),
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
            child: Text('कुनै Voices भेटिएन'),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data();

            final name = post['name']?.toString() ?? 'User';
            final text = post['text']?.toString() ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(name),
                subtitle: Text(text),
              ),
            );
          },
        );
      },
    );
  }
}

// खण्ड ७ समाप्त

// TOP DEBATES PAGE

class TopDebatesPage extends StatelessWidget {
  const TopDebatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Debates'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Top Debates देखाउन समस्या भयो'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final posts = snapshot.data!.docs.toList();

          posts.sort((a, b) {
            final aAgrees = a.data()['agreedBy'] is List
                ? (a.data()['agreedBy'] as List).length
                : 0;

            final bAgrees = b.data()['agreedBy'] is List
                ? (b.data()['agreedBy'] as List).length
                : 0;

            return bAgrees.compareTo(aAgrees);
          });

          if (posts.isEmpty) {
            return const Center(
              child: Text('कुनै Voices भेटिएन'),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data();

              final name = post['name']?.toString() ?? 'User';
              final text = post['text']?.toString() ?? '';

              final agreedBy = post['agreedBy'] is List
                  ? (post['agreedBy'] as List).length
                  : 0;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text('$agreedBy Agree'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// खण्ड ८ समाप्त

// ACTIVITY PAGE

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: const Center(
        child: Text(
          'Your activity will appear here',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// खण्ड ८ समाप्त

