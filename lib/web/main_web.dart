import 'package:flutter/material.dart';

// Mock classes to replace Firebase functionality
class MockAuth {
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}

void main() {
  runApp(const WebPreviewApp());
}

class WebPreviewApp extends StatelessWidget {
  const WebPreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App - Web Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WebPreviewHome(),
      routes: {
        '/login': (context) => const MockLoginScreen(),
        '/signup': (context) => const MockSignUpScreen(),
        '/home': (context) => const MockHomeScreen(),
        '/workout': (context) => const MockWorkoutScreen(),
        '/profile': (context) => const MockProfileScreen(),
      },
    );
  }
}

class WebPreviewHome extends StatelessWidget {
  const WebPreviewHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness App - Web Preview'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Fitness App Preview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is a preview version for web.\nFirebase functionality is mocked.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login Screen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Sign Up Screen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text('Home Screen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/workout'),
              child: const Text('Workout Screen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Profile Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock screens for preview
class MockLoginScreen extends StatelessWidget {
  const MockLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen (Mock)', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class MockSignUpScreen extends StatelessWidget {
  const MockSignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sign Up Screen (Mock)', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen (Mock)', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/workout'),
              child: const Text('Go to Workouts'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

class MockWorkoutScreen extends StatelessWidget {
  const MockWorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Workout Screen (Mock)', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('Your workout plans would appear here'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

class MockProfileScreen extends StatelessWidget {
  const MockProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Screen (Mock)', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            const Text('User Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('user@example.com'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/workout');
          }
        },
      ),
    );
  }
}
