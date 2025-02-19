import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WonderShort {
  final int idWonderShort;
  int like;
  final String desc;
  final String videoPath;
  final String dateUpload;
  final int vues;
  final int wond;

  WonderShort({
    required this.idWonderShort,
    required this.like,
    required this.desc,
    required this.videoPath,
    required this.dateUpload,
    required this.vues,
    required this.wond,
  });

  factory WonderShort.fromDocument(Map<String, dynamic> doc) {
    return WonderShort(
      idWonderShort: doc['id'] as int,
      like: doc['likes'] as int,
      desc: doc['description'] as String,
      videoPath: doc['video_path'] as String,
      dateUpload: doc['created_at'] as String,
      vues: doc['vues'] as int,
      wond: doc['wonder']?['id'] as int,
    );
  }

  String getDescription() {
    return desc;
  }

  Future<int?> getLikes() async {
    final response = await Supabase.instance.client
        .from('wonder_short')
        .select('likes')
        .eq('id', idWonderShort)
        .single();

    if (response != null) {
      return response['likes'] as int;
    }
    return null;
  }

  Future<void> setLike() async {
    final int? likeactu = await getLikes();
    final int likeUpdate = likeactu! + 1;
    await Supabase.instance.client
        .from('wonder_short')
        .update({'likes': likeUpdate})
        .eq('id', idWonderShort);
  }

  Future<void> disLike() async {
    final int? likeactu = await getLikes();
    final int likeUpdate = likeactu! - 1;
    await Supabase.instance.client
        .from('wonder_short')
        .update({'likes': likeUpdate})
        .eq('id', idWonderShort);
  }

  Future<int?> getVues() async {
    final response = await Supabase.instance.client
        .from('wonder_short')
        .select('vues')
        .eq('id', idWonderShort)
        .single();

    if (response != null) {
      return response['vues'] as int;
    }
    return null;
  }

  Future<void> setVues() async {
    final int? vuesActu = await getVues();
    final int vuesUpdate = vuesActu! + 1;
    await Supabase.instance.client
        .from('wonder_short')
        .update({'vues': vuesUpdate})
        .eq('id', idWonderShort);
  }

  Future<void> addCommentaire(String content) async {
    final Utilisateur user = await Camwonder().getUserInfo();
    final Comment comment = Comment(
      idComment: 1,
      content: content,
      wondershort: idWonderShort,
      idUser: user.uid, userImage: '', userName: '',
    );

    await Supabase.instance.client.from('commentaire').insert({
      'content': comment.content,
      'wonder_short': comment.wondershort,
      'user': comment.idUser,
    });
  }

  Stream<List<Map<String, dynamic>>> getCommentaires() {
    return Supabase.instance.client
        .from('commentaire')
        .stream(primaryKey: ['id'])
        .eq('wondershort', idWonderShort);
  }
}