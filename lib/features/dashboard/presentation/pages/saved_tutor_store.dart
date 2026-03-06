import 'package:flutter/material.dart';

class SavedTutor {
  const SavedTutor({
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.rating,
    required this.imageUrl,
    required this.price,
  });

  final String tutorId;
  final String name;
  final String subject;
  final String rating;
  final String imageUrl;
  final String price;
}

class SavedTutorStore {
  static final ValueNotifier<List<SavedTutor>> savedTutors =
      ValueNotifier<List<SavedTutor>>(<SavedTutor>[]);

  static bool isSaved(String tutorId) {
    return savedTutors.value.any((tutor) => tutor.tutorId == tutorId);
  }

  static void toggleSaved(SavedTutor tutor) {
    final current = List<SavedTutor>.from(savedTutors.value);
    final index = current.indexWhere((item) => item.tutorId == tutor.tutorId);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.insert(0, tutor);
    }
    savedTutors.value = current;
  }

  static void setSavedTutors(List<SavedTutor> tutors) {
    savedTutors.value = List<SavedTutor>.from(tutors);
  }

  static void removeByTutorId(String tutorId) {
    final current = List<SavedTutor>.from(savedTutors.value)
      ..removeWhere((item) => item.tutorId == tutorId);
    savedTutors.value = current;
  }

  static void upsert(SavedTutor tutor) {
    final current = List<SavedTutor>.from(savedTutors.value);
    final index = current.indexWhere((item) => item.tutorId == tutor.tutorId);
    if (index >= 0) {
      current[index] = tutor;
    } else {
      current.insert(0, tutor);
    }
    savedTutors.value = current;
  }
}
