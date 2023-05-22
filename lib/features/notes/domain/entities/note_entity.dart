import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotesEntity extends Equatable {
  final String? noteId;
  final String? note;
  final Timestamp? time;
  final String? uid;

  NotesEntity({this.noteId, this.note, this.time, this.uid});

  @override
  List<Object?> get props => [noteId, note, time, uid];

  Map<String, dynamic> toJson() {
    return {
      'noteId': noteId,
      'note': note,
      'time': time,
      'uid': uid,
    };
  }

  factory NotesEntity.fromJson(Map<String, dynamic> json) {
    return NotesEntity(
      noteId: json['noteId'],
      note: json['note'],
      time: json['time'],
      uid: json['uid'],
    );
  }
}
