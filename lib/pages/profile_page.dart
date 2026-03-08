import 'package:flutter/material.dart';
import 'editProfile_page.dart';
import '../controllers/user_controller.dart';
import '../widgets/app_bottom_navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _userController.loadUserData(); //
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _userController, //
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "My Profile",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (_userController.profileImage != null &&
                                _userController.profileImage!.isNotEmpty)
                            ? NetworkImage(_userController.profileImage!)
                            : null, //
                        child:
                            (_userController.profileImage == null ||
                                _userController.profileImage!.isEmpty)
                            ? Icon(
                                Icons.person_rounded,
                                size: 65,
                                color: Colors.grey.shade300,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userController.name.isEmpty
                        ? "Loading..."
                        : _userController.name, //
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "🍳 Food Enthusiast",
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8B5E), Color(0xFFFF6B35)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Member",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Joined Since",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _userController.createdAt.isEmpty
                              ? "N/A"
                              : _userController.createdAt, //
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  _buildMenuButton(
                    icon: Icons.edit_outlined,
                    label: "Edit Profile",
                    color: Colors.white,
                    textColor: Colors.black87,
                    iconColor: const Color(0xFFFF6B35),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditprofilePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuButton(
                    icon: Icons.logout_rounded,
                    label: "Logout",
                    color: Colors.white,
                    textColor: Colors.red.shade600,
                    iconColor: Colors.red.shade500,
                    isDanger: true,
                    onTap: () => _userController.handleLogout(context), //
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required Color iconColor,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDanger
            ? Border.all(color: Colors.red.shade100, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.red.shade50
                        : iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
