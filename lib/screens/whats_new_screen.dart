import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WhatsNewScreen extends StatefulWidget {
  const WhatsNewScreen({super.key});

  @override
  State<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {
  String _version = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _version = 'Unknown';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        leading: Semantics(
          label: 'Back to home',
          hint: 'Returns to the main screen',
          button: true,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1A1A1A),
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'What\'s New',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with version
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF007AFF),
                                  Color(0xFF5856D6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.new_releases,
                              color: Color(0xFFFFFFFF),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Version $_version',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Latest Updates',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Current Version Updates
                    _buildUpdateSection(
                      'Phase 4: Version Control & Settings',
                      [
                        _buildUpdateItem(
                          'New',
                          'Three-dot menu for easy access to app options',
                          Icons.more_vert,
                          const Color(0xFF34C759),
                        ),
                        _buildUpdateItem(
                          'New',
                          'Clear completed tasks with confirmation dialog',
                          Icons.clear_all,
                          const Color(0xFF34C759),
                        ),
                        _buildUpdateItem(
                          'New',
                          'Comprehensive Settings screen with app information',
                          Icons.settings,
                          const Color(0xFF34C759),
                        ),
                        _buildUpdateItem(
                          'New',
                          'What\'s New screen for tracking updates',
                          Icons.new_releases,
                          const Color(0xFF34C759),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Previous Updates
                    _buildUpdateSection(
                      'Phase 3: Polish & Refinement',
                      [
                        _buildUpdateItem(
                          'Improved',
                          'Enhanced accessibility with screen reader support',
                          Icons.accessibility,
                          const Color(0xFF007AFF),
                        ),
                        _buildUpdateItem(
                          'Improved',
                          'Better edge case handling for empty states',
                          Icons.check_circle,
                          const Color(0xFF007AFF),
                        ),
                        _buildUpdateItem(
                          'Improved',
                          'Task input validation and error messages',
                          Icons.edit,
                          const Color(0xFF007AFF),
                        ),
                        _buildUpdateItem(
                          'Performance',
                          'Optimized app startup and animations',
                          Icons.speed,
                          const Color(0xFFFF9500),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Core Features
                    _buildUpdateSection(
                      'Core Features (Phases 1-2)',
                      [
                        _buildUpdateItem(
                          'Core',
                          'Daily task management with weekday navigation',
                          Icons.today,
                          const Color(0xFF6B7280),
                        ),
                        _buildUpdateItem(
                          'Core',
                          'Time-prominent interface design',
                          Icons.access_time,
                          const Color(0xFF6B7280),
                        ),
                        _buildUpdateItem(
                          'Core',
                          'Lightning-fast task entry and completion',
                          Icons.flash_on,
                          const Color(0xFF6B7280),
                        ),
                        _buildUpdateItem(
                          'Core',
                          'Offline-first with local data storage',
                          Icons.offline_bolt,
                          const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'More updates coming soon!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'We\'re constantly improving Pare while\nstaying true to our minimalist philosophy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUpdateSection(String title, List<Widget> updates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EA),
              width: 1,
            ),
          ),
          child: Column(
            children: _addDividers(updates),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateItem(String type, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _addDividers(List<Widget> children) {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: const Color(0xFFE5E7EA).withValues(alpha: 0.5),
        ));
      }
    }
    return result;
  }
} 