import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/board.dart';
import 'package:mobile/domain/models/card.dart';
import 'package:mobile/domain/models/checklist_item.dart';
import 'package:mobile/domain/models/notification.dart';
import 'package:mobile/domain/models/user.dart';
import 'package:mobile/main.dart';
import 'package:mobile/utils/enums.dart' as app_enums;

Future<void> pumpKanbanApp(WidgetTester tester) async {
  await tester.pumpWidget(const KanbanBoardApp());
  await tester.pumpAndSettle();
}

void main() {
  group('App widget smoke tests', () {
    testWidgets('renders splash screen actions', (tester) async {
      await pumpKanbanApp(tester);

      expect(find.text('Kanban Board'), findsOneWidget);
      expect(find.text('Üye Ol'), findsOneWidget);
      expect(find.text('Oturum Aç'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    });

    testWidgets('opens login screen from splash', (tester) async {
      await pumpKanbanApp(tester);

      await tester.tap(find.text('Oturum Aç'));
      await tester.pumpAndSettle();

      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(find.text('Google ile Giriş Yap'), findsOneWidget);
      expect(find.text('Şifremi Unuttum'), findsOneWidget);
    });

    testWidgets('login form validates required fields', (tester) async {
      await pumpKanbanApp(tester);
      await tester.tap(find.text('Oturum Aç'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
      await tester.pumpAndSettle();

      expect(find.text('E-posta adresi gerekli'), findsOneWidget);
      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('login form validates invalid email', (tester) async {
      await pumpKanbanApp(tester);
      await tester.tap(find.text('Oturum Aç'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
      await tester.pumpAndSettle();

      expect(find.text('Geçerli bir e-posta adresi girin'), findsOneWidget);
    });

    testWidgets('login password visibility toggle changes icon', (
      tester,
    ) async {
      await pumpKanbanApp(tester);
      await tester.tap(find.text('Oturum Aç'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('opens signup screen from splash', (tester) async {
      await pumpKanbanApp(tester);

      await tester.tap(find.text('Üye Ol'));
      await tester.pumpAndSettle();

      expect(find.text('Ad Soyad'), findsOneWidget);
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(
        find.textContaining('Gizlilik Politikası', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('signup form validates required fields', (tester) async {
      await pumpKanbanApp(tester);
      await tester.tap(find.text('Üye Ol'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Üye Ol'));
      await tester.pumpAndSettle();

      expect(find.text('Ad gerekli'), findsOneWidget);
      expect(find.text('E-posta adresi gerekli'), findsOneWidget);
      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('signup form validates short password', (tester) async {
      await pumpKanbanApp(tester);
      await tester.tap(find.text('Üye Ol'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.tap(find.widgetWithText(FilledButton, 'Üye Ol'));
      await tester.pumpAndSettle();

      expect(find.text('Şifre en az 8 karakter olmalı'), findsOneWidget);
    });
  });

  group('Domain model mapping tests', () {
    test('User parses JSON defaults and serializes full_name', () {
      final user = User.fromJson({
        'id': 'user-1',
        'email': 'test@example.com',
        'full_name': 'Test User',
      });

      expect(user.isActive, isTrue);
      expect(user.isDeleted, isFalse);
      expect(user.toJson()['full_name'], 'Test User');
    });

    test('Board falls back to workspace visibility for unknown values', () {
      final board = Board.fromJson({
        'id': 'board-1',
        'name': 'Demo Board',
        'visibility': 'unexpected',
        'workspace_id': 'workspace-1',
        'owner_id': 'user-1',
      });

      expect(board.visibility, app_enums.Visibility.workspace);
      expect(board.toJson()['visibility'], 'workspace');
    });

    test('KanbanCard parses dates, defaults position, and serializes IDs', () {
      final card = KanbanCard.fromJson({
        'id': 'card-1',
        'title': 'Prepare demo',
        'list_id': 'list-1',
        'created_at': '2026-05-17T10:00:00.000',
        'updated_at': '2026-05-17T11:00:00.000',
      });

      expect(card.position, 65535.0);
      expect(card.createdAt.year, 2026);
      expect(card.toJson()['list_id'], 'list-1');
    });

    test('KanbanCard parses optional assignee and due date fields', () {
      final card = KanbanCard.fromJson({
        'id': 'card-2',
        'title': 'Assigned task',
        'list_id': 'list-1',
        'assigned_to': 'user-2',
        'due_date': '2026-05-18T09:00:00.000',
        'created_at': '2026-05-17T10:00:00.000',
        'updated_at': '2026-05-17T11:00:00.000',
      });

      expect(card.assignedTo, 'user-2');
      expect(card.dueDate?.day, 18);
      expect(card.toJson()['due_date'], contains('2026-05-18'));
    });

    test('ChecklistItem copyWith updates only selected fields', () {
      final now = DateTime(2026, 5, 17);
      final item = ChecklistItem(
        id: 'check-1',
        cardId: 'card-1',
        title: 'Initial',
        isCompleted: false,
        position: 1,
        createdAt: now,
        updatedAt: now,
      );

      final updated = item.copyWith(title: 'Updated', isCompleted: true);

      expect(updated.id, item.id);
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, isTrue);
      expect(updated.position, 1);
    });

    test('ChecklistItem JSON defaults completion and position', () {
      final item = ChecklistItem.fromJson({
        'id': 'check-2',
        'card_id': 'card-1',
        'title': 'Write tests',
        'created_at': '2026-05-17T10:00:00.000',
        'updated_at': '2026-05-17T11:00:00.000',
      });

      expect(item.isCompleted, isFalse);
      expect(item.position, 65535.0);
      expect(item.toJson()['card_id'], 'card-1');
    });

    test('AppNotification falls back to commentAdded for unknown type', () {
      final notification = AppNotification.fromJson({
        'id': 'notification-1',
        'user_id': 'user-1',
        'type': 'unknown',
        'title': 'New event',
        'message': 'Something happened',
        'created_at': '2026-05-17T10:00:00.000',
      });

      expect(notification.type, app_enums.NotificationType.commentAdded);
      expect(notification.isRead, isFalse);
      expect(notification.toJson()['type'], 'commentAdded');
    });
  });
}
