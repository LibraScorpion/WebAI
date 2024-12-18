import 'package:flutter/material.dart';
import '../../services/auth/biometric_service.dart';
import '../../services/auth/secure_storage_service.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({Key? key}) : super(key: key);

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final BiometricService _biometricService = BiometricService();
  final SecureStorageService _secureStorage = SecureStorageService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    setState(() => _isLoading = true);
    
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        setState(() {
          _statusMessage = 'Biometric authentication is not available';
          _isLoading = false;
        });
        return;
      }

      final biometrics = await _biometricService.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        setState(() {
          _statusMessage = 'No biometrics enrolled';
          _isLoading = false;
        });
        return;
      }

      _authenticate();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking biometrics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await _biometricService.authenticate();
      if (authenticated) {
        // Get stored auth token
        final token = await _secureStorage.getAuthToken();
        if (token != null) {
          // Navigate to home page
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        setState(() {
          _statusMessage = 'Authentication failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error during authentication: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                const Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkBiometrics,
                  child: const Text('Try Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Use Password Instead'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
