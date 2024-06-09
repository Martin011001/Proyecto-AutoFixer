import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:aplicacion_taller/entities/user.dart';

class PerfilesScreen extends StatelessWidget {
  const PerfilesScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles'),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder(
        stream: usersRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(
                child: Text('Algo ha salido mal: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .map((doc) => User.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.phone),
                  onTap: () {
                    // Navigate to profile page using go_router
                    context.push('/administrador/perfiles/profile',
                        extra: user);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
