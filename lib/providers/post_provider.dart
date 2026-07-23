import 'package:flutter/cupertino.dart';
import 'package:simple_blog/services/post_service.dart';

import '../models/post_model.dart';

class PostProvider extends ChangeNotifier{
  final PostService _postService = PostService();

  bool _loading = false;
  List<Post> _posts = [];
  String? _error;

  bool get loading => _loading;
  List<Post> get posts => _posts;
  String? get error => _error;

  Future<List<Post>> _loadPosts() async {
    return await _postService.getPosts();
  }

  Future<void> getPosts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _loadPosts();
    } catch (e){
      _error = e.toString();
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({required String title, required String content}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try{
      await _postService.createPost(title: title, content: content);

      _posts = await _loadPosts();
      return true;
    } catch (e){
      _error = e.toString();
      print(_error);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost({required int id, required String title, required String content}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.updatePost(id: id, title: title, content: content);
      _posts = await _loadPosts();
      return true;
    } catch (e){
      _error = e.toString();
      print(_error);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost({required int id}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.deletePost(id: id);
      _posts = await _loadPosts();
      return true;
    } catch (e){
      _error = e.toString();
      print(_error);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}