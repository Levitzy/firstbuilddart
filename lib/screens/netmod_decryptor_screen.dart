// lib/screens/netmod_decryptor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/netmod_decryptor_screen.dart';

class NetmodDecryptorScreen extends StatefulWidget {
  const NetmodDecryptorScreen({super.key});

  @override
  State<NetmodDecryptorScreen> createState() => _DecryptorScreenState();
}

class _DecryptorScreenState extends State<NetmodDecryptorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String _decryptedResult = '';
  final DecryptorService _decryptorService = DecryptorService();
  bool _isDecrypting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _decrypt() async {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter encrypted data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDecrypting = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Animation delay
      final result = _decryptorService.decrypt(_inputController.text);
      setState(() {
        _decryptedResult = result;
        _isDecrypting = false;
      });
    } catch (e) {
      setState(() {
        _decryptedResult = 'Error during decryption: $e';
        _isDecrypting = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_decryptedResult.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _decryptedResult));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearInput() {
    _inputController.clear();
    setState(() {
      _decryptedResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Netmod Decryptor'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelText: 'Encrypted Content',
                              hintText: 'Enter encrypted base64 data',
                              prefixIcon: const Icon(Icons.enhanced_encryption),
                            ),
                            maxLines: 4,
                          ),
                          if (_inputController.text.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearInput,
                                tooltip: 'Clear input',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isDecrypting ? null : _decrypt,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isDecrypting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.lock_open),
                    label: Text(
                      _isDecrypting ? 'DECRYPTING...' : 'DECRYPT',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[100]!,
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: SelectableText(
                                _decryptedResult,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          if (_decryptedResult.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: _copyToClipboard,
                                    tooltip: 'Copy to clipboard',
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}