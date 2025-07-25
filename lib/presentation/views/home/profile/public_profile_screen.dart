import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repx/data/models/user_model.dart';
import 'package:repx/data/providers/auth_providers.dart';
import 'package:repx/data/providers/user_data_provider.dart';
import 'package:repx/presentation/widgets/custom_wide_button.dart';

class PublicProfileScreen extends ConsumerWidget {
  static const String id = 'public_profile_screen';
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'];

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final userRepo = ref.watch(userRepositoryProvider);
    final authRepo = ref.watch(authRepositoryProvider);

    final currentUser = authRepo.currentUser;

    return FutureBuilder<UserModel?>(
      future: userRepo.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(body: Center(child: Text('User not found')));
        }

        final userData = snapshot.data!;
        final followers = userRepo.getUserFollowers(userData.id);
        final following = userRepo.getUserFollowings(userData.id);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ListView(
            children: [
              // Cover image
              Container(
                height: height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/profile/pro4.jpeg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              // User Info
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: height * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.username ?? 'N/A',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Joined at: ${userData.createdAt?.year ?? 'N/A'}/${userData.createdAt?.month ?? 'N/A'}/${userData.createdAt?.day ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    FutureBuilder<bool>(
                      future: userRepo.isUserFollowed(
                        currentUser!.id,
                        userData.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        bool isFollowing = snapshot.data ?? false;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            bool isLoading = false;

                            Future<void> _followUser() async {
                              setState(() => isLoading = true);
                              await userRepo.followUser(
                                currentUser.id,
                                userData.id,
                              );
                              setState(() {
                                isLoading = false;
                                isFollowing = true;
                              });
                            }

                            Future<void> _unfollowUser() async {
                              setState(() => isLoading = true);
                              await userRepo.unfollowUser(
                                currentUser.id,
                                userData.id,
                              );
                              setState(() {
                                isLoading = false;
                                isFollowing = false;
                              });
                            }

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.01,
                              ),
                              child: currentUser.id == userData.id
                                  ? SizedBox()
                                  : isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : CustomWideButton(
                                      text: isFollowing
                                          ? "Remove Friend"
                                          : "Add Friend",
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      textColor: Colors.black,
                                      onPressed: isFollowing
                                          ? _unfollowUser
                                          : _followUser,
                                    ),
                            );
                          },
                        );
                      },
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: Container(
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              "friends_screen",
                              arguments: {'userId': userData.id},
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Make here logic
                                  FutureBuilder<List<UserModel>>(
                                    future: followers,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error');
                                      } else {
                                        return Text(
                                          '${snapshot.data?.length ?? 0}',
                                        );
                                      }
                                    },
                                  ),
                                  Text("Followers"),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder<List<UserModel>>(
                                    future: following,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error');
                                      } else {
                                        return Text(
                                          '${snapshot.data?.length ?? 0}',
                                        );
                                      }
                                    },
                                  ),
                                  Text("Following"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Age, Weight, Height
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: Container(
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('${userData.age}'), Text("Age")],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${userData.weight}'),
                                Text("Weight"),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${userData.height}'),
                                Text("Height"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Streak & EXP
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard(
                            width,
                            height,
                            Theme.of(context).colorScheme.secondary,
                            'assets/icons/burn.png',
                            '${userData.streak}',
                            "Streak",
                          ),
                          _buildStatCard(
                            width,
                            height,
                            Theme.of(context).colorScheme.secondary,
                            'assets/icons/flash.png',
                            '${userData.exp}',
                            "Experience",
                          ),
                        ],
                      ),
                    ),

                    // (Optional) Follow/Unfollow Button here
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    double width,
    double height,
    Color color,
    String iconPath,
    String value,
    String label,
  ) {
    return Container(
      width: width * 0.42,
      height: height * 0.08,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: Color(0xFFd1fc3e),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(value), Text(label)],
          ),
        ],
      ),
    );
  }
}
