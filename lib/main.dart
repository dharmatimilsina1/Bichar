
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

  Future<void> editPost(BuildContext context, String oldText) async {
    final controller = TextEditingController(text: oldText);

    final editedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Voice'),
          content: TextField(
            controller: controller,
            maxLines: 6,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'आफ्नो पोस्ट सम्पादन गर्नुहोस्',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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

    if (editedText == null || editedText.isEmpty) {
      return;
    }

    try {
      await post.reference.update({
        'text': editedText,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post update गर्न सकिएन'),
          ),
        );
      }
    }
  }

  Future<void> deletePost(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post?'),
          content: const Text(
            'के तपाईं यो पोस्ट हटाउन चाहनुहुन्छ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const 
             
