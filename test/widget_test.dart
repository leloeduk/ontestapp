import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ontestapp/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap parse correctement les champs', () {
      final createdAt = DateTime(2024, 1, 1);
      final model = UserModel.fromMap('uid1', {
        'name': 'Alice',
        'email': 'alice@test.com',
        'points': 30,
        'testsDone': 3,
        'joinedGroup': true,
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(model.uid, 'uid1');
      expect(model.name, 'Alice');
      expect(model.email, 'alice@test.com');
      expect(model.points, 30);
      expect(model.testsDone, 3);
      expect(model.joinedGroup, true);
      expect(model.createdAt, createdAt);
    });

    test('fromMap applique des valeurs par défaut', () {
      final model = UserModel.fromMap('uid2', {});

      expect(model.points, 0);
      expect(model.testsDone, 0);
      expect(model.joinedGroup, false);
      expect(model.createdAt, isNull);
    });

    test('toMap conserve les valeurs', () {
      final model = UserModel(
        uid: 'x',
        name: 'Bob',
        email: 'bob@test.com',
        points: 5,
        testsDone: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      final map = model.toMap();

      expect(map['name'], 'Bob');
      expect(map['email'], 'bob@test.com');
      expect(map['points'], 5);
      expect(map['testsDone'], 1);
      expect(map['joinedGroup'], false);
    });
  });
}
