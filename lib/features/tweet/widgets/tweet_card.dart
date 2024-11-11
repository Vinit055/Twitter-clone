import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/carousel_image.dart';
import 'package:twitter_clone/features/tweet/widgets/hashtags_text.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_icon_button.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userDetailsProvider(tweet.uid)).when(
          data: (user) {
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 35,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //re tweeted TODO

                            //user name & no. of hours since tweet
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                                Text(
                                  '@${user.name} · ${timeago.format(
                                    tweet.tweetedAt,
                                    //locale: 'en_short',
                                  )}',
                                  style: const TextStyle(
                                      fontSize: 17, color: Pallete.greyColor),
                                ),
                              ],
                            ),
                            // replied to TODO

                            // tweet text
                            HashtagsText(text: tweet.text),

                            // show images
                            if (tweet.tweetType == TweetType.image)
                              CarouselImage(imageLinks: tweet.imageLinks),
                            if (tweet.link.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              AnyLinkPreview(
                                link: tweet.link,
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                              ),
                            ],
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                                right: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TweetIconButton(
                                    pathName: AssetsConstants.viewsIcon,
                                    text: (tweet.commentIds.length +
                                            tweet.reshareCount +
                                            tweet.likes.length)
                                        .toString(),
                                    onTap: () {},
                                  ),
                                  TweetIconButton(
                                    pathName: AssetsConstants.commentIcon,
                                    text: (tweet.commentIds.length).toString(),
                                    onTap: () {},
                                  ),
                                  TweetIconButton(
                                    pathName: AssetsConstants.retweetIcon,
                                    text: (tweet.reshareCount).toString(),
                                    onTap: () {},
                                  ),
                                  TweetIconButton(
                                    pathName: AssetsConstants.likeOutlinedIcon,
                                    text: (tweet.likes.length).toString(),
                                    onTap: () {},
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      size: 25,
                                      color: Pallete.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Pallete.greyColor,
                    thickness: 0.3,
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
