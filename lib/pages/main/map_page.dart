import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/other/error_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
            ),
          );
        } else if (snapshot.hasError) {
          return NoConnectionPage(
            function: () {
              setState(() {});
            },
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        } else {
          final users = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true, // ✅ limits to only what's needed
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(users[index]['name'] ?? 'No Name'),
                      subtitle: Text(users[index]['email'] ?? 'No Email'),
                    );
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    insertTestUser(
                      name: "gayasfaq",
                      email: "gayasfaq@gmail.com",
                    );
                  }, // ✅ Use the callback from parent
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.secondary,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  child: const Text("Add user"),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final data = await fetchUserByName("okok");
                    final userID = data[0]['id'];
                    updateUserName(userId: userID, newName: "johnny hahaha");
                  }, // ✅ Use the callback from parent
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.secondary,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  child: const Text("fetch user"),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await Supabase.instance.client.from('user').select();
    debugPrint('$response');
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchUserByName(String name) async {
    final data = await Supabase.instance.client
        .from('user')
        .select()
        .eq('name', name);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> insertTestUser({
    required String email,
    required String name,
  }) async {
    try {
      final response = await Supabase.instance.client.from('user').insert({
        'email': email,
        'name': name,
      });
      debugPrint('Insert successful: $response');
      setState(() {});
    } catch (e) {
      debugPrint('Insert failed: $e');
    }
  }

  Future<void> updateUserName({
    required String userId,
    required String newName,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('user')
          .update({'name': newName})
          .eq('id', userId);

      debugPrint('Update successful: $response');
      setState(() {});
    } catch (e) {
      debugPrint('Update failed: $e');
    }
  }
}
