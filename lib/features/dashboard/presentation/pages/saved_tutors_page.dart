import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/saved_tutor_store.dart';

class SavedTutorsPage extends StatelessWidget {
  const SavedTutorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Tutors')),
      body: ValueListenableBuilder<List<SavedTutor>>(
        valueListenable: SavedTutorStore.savedTutors,
        builder: (context, tutors, _) {
          if (tutors.isEmpty) {
            return const Center(child: Text('No saved tutors yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              final tutor = tutors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: tutor.imageUrl.isNotEmpty ? NetworkImage(tutor.imageUrl) : null,
                    child: tutor.imageUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(tutor.name),
                  subtitle: Text('${tutor.subject} • ${tutor.rating} • ${tutor.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark, color: Color(0xFFF4C430)),
                    onPressed: () => SavedTutorStore.toggleSaved(tutor),
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
