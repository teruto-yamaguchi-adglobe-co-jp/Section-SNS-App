import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:flutter_sns_app/models/post.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Post> _posts = [];
  bool _isLoading = false;
  int _page = 1;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts({bool isRefresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    if (isRefresh) {
      _page = 1;
      _posts = [];
    }

    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range((_page - 1) * _pageSize, _page * _pageSize - 1);

      final List<Post> newPosts =
          (response as List).map((data) => Post.fromJson(data)).toList();
      setState(() {
        _posts.addAll(newPosts);
        _page++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投稿の取得に失敗しました: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchPosts();
    }
  }

  Future<void> _addPost() async {
    final content = _contentController.text;
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿内容を入力してください。')),
      );
      return;
    }
    if (content.length > 512) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿内容は512文字以内で入力してください。')),
      );
      return;
    }

    try {
      await _supabase.from('posts').insert({'content': content});
      _contentController.clear();
      _fetchPosts(isRefresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投稿に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('本当にこの投稿を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _supabase.from('posts').delete().eq('id', id);
        _fetchPosts(isRefresh: true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('投稿の削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _editPost(Post post) async {
    final contentController = TextEditingController(text: post.content);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('投稿を編集'),
          content: TextField(
            controller: contentController,
            maxLines: null,
            maxLength: 512,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final content = contentController.text;
                if (content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('投稿内容を入力してください。')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _supabase
            .from('posts')
            .update({'content': contentController.text})
            .eq('id', post.id);
        _fetchPosts(isRefresh: true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('投稿の編集に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleLike(Post post) async {
    try {
      final isLiked = await _supabase
          .from('likes')
          .select()
          .eq('post_id', post.id)
          .then((value) => value.isNotEmpty);

      if (isLiked) {
        await _supabase.from('likes').delete().eq('post_id', post.id);
        await _supabase.rpc('decrement_like_count', params: {'post_id_param': post.id});
      } else {
        await _supabase.from('likes').insert({'post_id': post.id});
        await _supabase.rpc('increment_like_count', params: {'post_id_param': post.id});
      }
      _fetchPosts(isRefresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('いいねの操作に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SNS App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: '投稿内容を入力...',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 512,
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _addPost,
                  child: const Text('投稿'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchPosts(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final post = _posts[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.content),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy/MM/dd HH:mm')
                                    .format(post.createdAt.toLocal()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up),
                                    onPressed: () => _toggleLike(post),
                                  ),
                                  Text('${post.likeCount}'),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editPost(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deletePost(post.id),
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
            ),
          ),
        ],
      ),
    );
  }
}