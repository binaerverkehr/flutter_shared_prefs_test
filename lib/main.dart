import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shared Preferences Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Shared Preferences Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //* 1. Create instance of SharedPreferences
  final _prefs = SharedPreferences.getInstance();

  //* 2. Change counter variable from int to Future<int>
  late Future<int> _counter;

  void _incrementCounter() async {
    //* 3. Await SharedPreferences instance
    final SharedPreferences prefs = await _prefs;
    //* 4. Increase counter
    final int counter = (prefs.getInt('counter') ?? 0) + 1;

    setState(() {
      //* 5. Save counter value on device
      _counter = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  //* 6. Initialze counter variable
  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('counter') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            FutureBuilder(
              future: _counter,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        '${snapshot.data}',
                        style: Theme.of(context).textTheme.headline4,
                      );
                    }
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final SharedPreferences prefs = await _prefs;
                prefs.remove('counter').then((success) {
                  final counter = prefs.getInt('counter') ?? 0;
                  setState(() {
                    _counter = prefs.setInt('counter', counter).then((bool success) {
                      return counter;
                    });
                  });
                  return success;
                });
              },
              child: const Text("Delete"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
