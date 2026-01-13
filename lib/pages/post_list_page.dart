import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:math';
import '../models/post.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final _posts = <Post>[];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  String? _editingPostId;
  final _editingController = TextEditingController();
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts({bool clearExisting = false}) async {
    if (_isLoading || (!_hasMore && !clearExisting)) return;

    if (clearExisting) {
      _posts.clear();
      _offset = 0;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(_offset, _offset + _limit - 1);

      if (mounted) {
        final newPosts =
            (response as List).map((json) => Post.fromJson(json)).toList();

        setState(() {
          _posts.addAll(newPosts);
          _offset += newPosts.length;
          _hasMore = newPosts.length == _limit;
        });
      }
    } catch (e) {
      _showErrorSnackBar('投稿の読み込みに失敗しました', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message, Object error) {
    if (!mounted) return;
    final errorMessage =
        error is PostgrestException ? error.message : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message: $errorMessage')),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore) {
      _fetchPosts();
    }
  }

  Future<void> _deletePost(String postId) async {
    for (int i = 0; i < 5; i++) {
      final bool shuffle = _random.nextBool();
      final bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // User must choose an option
        builder: (BuildContext context) {
          final yesButton = TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('はい'),
          );
          final noButton = TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('いいえ'),
          );

          return AlertDialog(
            title: Text('削除の確認 (${i + 1}/5)'),
            content: const Text(
                '本当にこの投稿を削除しますか？この操作は元に戻せません。'),
            actions: shuffle ? [noButton, yesButton] : [yesButton, noButton],
          );
        },
      );

      if (result != true) {
        if (!mounted) return;
        // User cancelled at some point
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('削除をキャンセルしました。')),
        );
        return; // Exit the function
      }
    }

    // If we get here, the user confirmed 5 times
    try {
      await Supabase.instance.client.from('posts').delete().eq('id', postId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿を完全に削除しました！')),
        );
        _fetchPosts(clearExisting: true); // Refresh posts after deletion
      }
    } catch (e) {
      _showErrorSnackBar('投稿の削除に失敗しました', e);
    }
  }

  Future<void> _toggleLike(Post post) async {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final originalPost = _posts[index];
    final newLikedState = !originalPost.isLiked;
    final newLikesCount =
        newLikedState ? originalPost.likesCount + 1 : originalPost.likesCount - 1;

    // Optimistic UI update
    setState(() {
      _posts[index] = originalPost.copyWith(
        likesCount: newLikesCount,
        isLiked: newLikedState,
      );
    });

    try {
      await Supabase.instance.client
          .from('posts')
          .update({'likes_count': newLikesCount}).eq('id', post.id);
    } catch (e) {
      if (mounted) {
        // Revert UI on error
        setState(() {
          _posts[index] = originalPost;
        });
        _showErrorSnackBar('いいねの更新に失敗しました', e);
      }
    }
  }

  void _startEditing(Post post) {
    setState(() {
      _editingPostId = post.id;
      _editingController.text = post.content;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingPostId = null;
      _editingController.clear();
    });
  }

  Future<void> _updatePost() async {
    final newContent = _editingController.text.trim();
    if (newContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('本文を入力してください')),
      );
      return;
    }
    if (newContent.length > 512) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('投稿は512文字以内です')),
      );
      return;
    }

    if (_editingPostId == null) return;

    try {
      await Supabase.instance.client
          .from('posts')
          .update({'content': newContent}).eq('id', _editingPostId!);

      if (mounted) {
        final index = _posts.indexWhere((p) => p.id == _editingPostId);
        if (index != -1) {
          setState(() {
            _posts[index] = _posts[index].copyWith(content: newContent);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿を更新しました！')),
        );
      }
    } catch (e) {
      _showErrorSnackBar('投稿の更新に失敗しました', e);
    } finally {
      if (mounted) {
        _cancelEditing();
      }
    }
  }

  Future<void> _createPost(String content) async {
    try {
      await Supabase.instance.client.from('posts').insert({'content': content});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿しました！')),
        );
        _fetchPosts(clearExisting: true);
      }
    } catch (e) {
      _showErrorSnackBar('投稿に失敗しました', e);
    }
  }

  Future<void> _showCreatePostDialog() async {
    final contentController = TextEditingController();
    String? errorText;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新規投稿'),
              content: TextField(
                controller: contentController,
                autofocus: true,
                maxLines: null,
                maxLength: 512,
                onChanged: (_) {
                  if (errorText != null) {
                    setState(() {
                      errorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'いまどうしてる？',
                  errorText: errorText,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('投稿する'),
                  onPressed: () {
                    final content = contentController.text.trim();
                    if (content.isNotEmpty) {
                      _createPost(content);
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        errorText = '本文を入力してください';
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNSアプリ'),
      ),
      body: _posts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _posts.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final post = _posts[index];
                final isEditing = post.id == _editingPostId;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditing)
                          TextField(
                            controller: _editingController,
                            autofocus: true,
                            maxLines: null,
                            maxLength: 512,
                          )
                        else
                          Text(
                            post.content,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isEditing)
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _updatePost,
                                    child: const Text('保存'),
                                  ),
                                  const SizedBox(width: 8.0),
                                  TextButton(
                                    onPressed: _cancelEditing,
                                    child: const Text('キャンセル'),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: post.isLiked
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () => _toggleLike(post),
                                  ),
                                  Text(
                                    '${post.likesCount}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            if (!isEditing)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _startEditing(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deletePost(post.id),
                                  ),
                                  Text(
                                    DateFormat('yyyy/MM/dd HH:mm')
                                        .format(post.createdAt.toLocal()),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12.0),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
