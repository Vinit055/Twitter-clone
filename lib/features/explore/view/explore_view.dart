import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/features/explore/controller/explore_controller.dart';
import 'package:twitter_clone/features/explore/widgets/search_bio.dart';
import 'package:twitter_clone/theme/pallete.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final searchTextController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTextFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Pallete.searchBarColor,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TextField(
            controller: searchTextController,
            onSubmitted: (value) {
              setState(() {
                isShowUsers = true;
              });
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10).copyWith(left: 20),
              enabledBorder: appBarTextFieldBorder,
              fillColor: Pallete.searchBarColor,
              filled: true,
              focusedBorder: appBarTextFieldBorder,
              hintText: 'Search Twitter',
              hintStyle: const TextStyle(
                color: Pallete.greyColor,
              ),
            ),
          ),
        ),
      ),
      body: isShowUsers
          ? ref.watch(searchUserProvider(searchTextController.text)).when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found with username "${searchTextController.text}"',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Pallete.greyColor,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = users[index];
                      return SearchTile(userModel: user);
                    },
                  );
                },
                error: (error, st) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              )
          : const SizedBox(),
    );
  }
}
