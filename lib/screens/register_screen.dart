import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor llena los campos';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Email invalido';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'La contraseña debe contener aunque sea 6 caracteres';
        _isLoading = false;
      });
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
      setState(() {
        _errorMessage = 'El telefono debe contener solo digitos numericos';
        _isLoading = false;
      });
      return;
    }
    if (_phoneController.text.length < 8) {
      setState(() {
        _errorMessage = 'el telefono debe contener aunque sea 8 caracteres';
        _isLoading = false;
      });
      return;
    }

    try {
      final existingUser = await _auth.fetchSignInMethodsForEmail(_emailController.text);
      if (existingUser.isNotEmpty) {
        setState(() {
          _errorMessage = 'El email ya esta en uso';
          _isLoading = false;
        });
        return;
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });
        if (user.email == 'admin@example.com') {
          context.go('/administrador');
        } else {
          context.go('/cliente');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El email ya esta en uso';
      case 'invalid-email':
        return 'El email es invalido';
      case 'weak-password':
        return 'La contraseña es muy debil';
      case 'operation-not-allowed':
        return 'Operacion no valida';
      default:
        return e.message ?? 'Ocurrio un error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefono',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Registrate'),
                  ),
            const SizedBox(height: 16.0),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
