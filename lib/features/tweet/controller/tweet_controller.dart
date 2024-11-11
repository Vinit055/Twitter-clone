import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';

final tweetControllerProvider = StateNotifierProvider<TweetController, bool>(
  (ref) {
    return TweetController(
      ref: ref,
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageAPIProvider),
    );
  },
);

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getLatestTweetProvider = StreamProvider.autoDispose((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageApi _storageAPI;
  final Ref _ref;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageApi storageAPI,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
  }) {
    try {
      if (text.isEmpty) {
        showSnackBar(
          context,
          'Please enter a text!',
        );
        return;
      }

      if (images.isNotEmpty) {
        _shareImagesTweet(
          context: context,
          images: images,
          text: text,
        );
      } else {
        _shareTextTweet(
          context: context,
          text: text,
        );
      }
      showSnackBar(context, 'Tweet posted successfully!');
      Navigator.pop(context);
    } on AppwriteException {
      showSnackBar(context, 'Some unexpected error occurred!');
    } catch (e) {
      showSnackBar(context, 'Failed to post tweet: $e');
    }
  }

  void _shareImagesTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHastagsFromSentence(text);
    String link = _getLinksFromSentence(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImage(images);
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
    );
    final res = await _tweetAPI.shareTweet(tweet);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHastagsFromSentence(text);
    String link = _getLinksFromSentence(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
    );
    final res = await _tweetAPI.shareTweet(tweet);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  String _getLinksFromSentence(String text) {
    String link = '';
    List<String> wordsInSentences = text.split(' ');
    for (String word in wordsInSentences) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHastagsFromSentence(String text) {
    List<String> hashtags = [];
    List<String> wordsInSentences = text.split(' ');
    for (String word in wordsInSentences) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }
}
