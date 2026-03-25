import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminQueriesScreen extends StatefulWidget {
  const AdminQueriesScreen({super.key});

  @override
  State<AdminQueriesScreen> createState() => _AdminQueriesScreenState();
}

class _AdminQueriesScreenState extends State<AdminQueriesScreen> {
  final supabase = Supabase.instance.client;

  Future<void> _deleteQuery(int id) async {
    await supabase.from('user_queries').delete().eq('id', id);
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("User Messages", style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('user_queries')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No messages found.", style: TextStyle(color: Colors.white54)));
          }

          final queries = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: queries.length,
            itemBuilder: (context, index) {
              final query = queries[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          query['user_name'] ?? 'User',
                          style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteQuery(query['id']),
                        ),
                      ],
                    ),
                    Text(query['user_email'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 10),
                    Text(
                      query['message'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}