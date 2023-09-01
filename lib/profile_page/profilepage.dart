import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/profile_page/profile_bloc.dart';
import 'package:project/profile_page/view_profile/viewProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileBloc homeBloc = ProfileBloc();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      bloc: homeBloc,
      listenWhen: (previous, current) => current is NavigateToViewPageState,
      buildWhen: (previous, current) => current is! NavigateToViewPageState,
      listener: (context, state) {
        // TODO: implement listener

        if (state is NavigateToViewPageState) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewPage(),
              ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE26142),
            foregroundColor: const Color(0xFFFDf7f5),
            title: const Text(
              "PROFILE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(
                    width: 150,
                    height: 150,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/icons/man.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "@Your Name",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Cabin'),
                    ),
                  ),
                  Text(
                    "@Your Email/Username",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.amberAccent),
                    ),
                    onPressed: () {
                      homeBloc.add(NavigateToViewPageEvent());
                    },
                    child: const Text(
                      "View Profile",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 30,
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),

                  // Menu
                  const tileWidget(title: 'Settings', icon: Icons.settings),
                  const tileWidget(title: 'Billing Details', icon: Icons.payment),
                  const tileWidget(
                      title: 'User Management',
                      icon: Icons.supervised_user_circle_sharp),
                  const Divider(
                    color: Colors.grey,
                    height: 30,
                    thickness: 1,
                  ),
                  const tileWidget(title: 'Information', icon: Icons.info_outline),
                  const tileWidget(title: 'Logout', icon: Icons.logout),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class tileWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const tileWidget({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.navigate_next),
    );
  }
}
