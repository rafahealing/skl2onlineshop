import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_creation_req.dart';
import '../models/user_signin_req.dart';

abstract class AuthFirebaseService {

  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> getAges();
  Future<Either> sendPasswordResetEmail(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {


  @override
  Future<Either> signup(UserCreationReq user) async {
    try {

      var returnedData = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!
      );

     await FirebaseFirestore.instance.collection('Users').doc(
        returnedData.user!.uid
      ).set(
        {
          'Nama Depan' : user.firstName,
          'Nama Belakang' : user.lastName,
          'Email' : user.email,
          'jenis kelamin' : user.gender,
          'Umur' : user.age,
          'Gambar' :returnedData.user!.photoURL,
          'userId': returnedData.user!.uid
        }
      );

      return const Right(
        'Pendaftaran berhasil'
      );

    } on FirebaseAuthException catch(e){
      String message = '';
      
      if(e.code == 'weak-password') {
        message = 'Kata sandi yang diberikan terlalu lemah';
      } else if (e.code == 'email-already-in-use') {
        message = 'Akun sudah ada dengan email tersebut.';
      }
      return Left(message);
    }
  }
  
  @override
  Future<Either> getAges() async {
    try {
      var returnedData = await FirebaseFirestore.instance.collection('Ages').get();
      return Right(
        returnedData.docs
      );
    } catch (e) {
      return const Left(
        'Silakan coba lagi'
      );
    }
  }
  
  @override
  Future<Either> signin(UserSigninReq user) async {
     try {
       await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: user.password!
      );
      return const Right(
        'Proses masuk berhasil'
      );

    } on FirebaseAuthException catch(e){
      String message = '';
      
      if(e.code == 'email tidak valid') {
        message = 'Tidak ditemukan pengguna untuk email ini';
      } else if (e.code == 'kredensial tidak valid') {
        message = 'Kata sandi yang diberikan untuk pengguna ini salah';
      }
      
      return Left(message);
    }
  }
  
  @override
  Future<Either> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return const Right(
        'Email pengaturan ulang kata sandi telah dikirim'
      );
    } catch (e){
      return const Left(
        'Silakan coba lagi'
      );
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }
  
  @override
  Future<Either> getUser() async {
    try {
    var currentUser = FirebaseAuth.instance.currentUser;
    var userData = await FirebaseFirestore.instance.collection('Users').doc(
      currentUser?.uid
    ).get().then((value) => value.data());
    return Right(
      userData
    );
    } catch(e) {
      return const Left(
        'Silakan coba lagi'
      );
    }
  }

  
}