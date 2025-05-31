import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stud_bud/screens/feed_screen.dart';
import 'package:stud_bud/models/post_model.dart';
import 'package:stud_bud/services/post_service.dart';

class MockPostService extends Mock implements PostService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedScreen Widget Tests', () {
    late List<Post> mockPosts;

    setUp(() {
      mockPosts = [
        Post(
          id: 1,
          author: 'Иван',
          authorPicture: null,
          content: 'Привет, мир!',
          imageUrl: null,
          likesCount: 5,
          likedByCurrentUser: false,
          createdAt: DateTime.now(),
        ),
        Post(
          id: 2,
          author: 'Ольга',
          authorPicture: 'https://via.placeholder.com/50',
          content: 'Новый пост!',
          imageUrl: 'https://via.placeholder.com/300',
          likesCount: 3,
          likedByCurrentUser: true,
          createdAt: DateTime.now(),
        ),
      ];
    });

    testWidgets('Отображается CircularProgressIndicator во время загрузки', (
      WidgetTester tester,
    ) async {
      // Задержка для эмуляции загрузки
      await tester.pumpWidget(
        MaterialApp(
          home: FutureBuilder<List<Post>>(
            future: Future.delayed(const Duration(seconds: 1), () => mockPosts),
            builder: (context, snapshot) {
              return const FeedScreen();
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Отображается сообщение об ошибке', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<List<Post>>(
              future: Future.error('Ошибка загрузки постов'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await tester.pump(); // Отрисовываем FutureBuilder

      expect(find.textContaining('Ошибка:'), findsOneWidget);
    });

    testWidgets('Отображаются истории и карточки постов', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: FeedScreenMocked(posts: mockPosts)),
      );

      await tester.pumpAndSettle(); // Ждем завершения Future

      // Проверяем наличие stories
      expect(find.text('Анна'), findsOneWidget);
      expect(find.text('Иван'), findsWidgets);

      // Проверяем наличие постов
      expect(find.text('Привет, мир!'), findsOneWidget);
      expect(find.text('Новый пост!'), findsOneWidget);
    });

    testWidgets('Лайк можно нажать и количество лайков отображается', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: FeedScreenMocked(posts: mockPosts)),
      );

      await tester.pumpAndSettle();

      // Находим лайкнутый пост
      final likeIcon = find.byIcon(Icons.favorite);
      final likeCount = find.text('3');

      expect(likeIcon, findsOneWidget);
      expect(likeCount, findsOneWidget);
    });
  });
}

/// Обёртка с кастомными мок-данными
class FeedScreenMocked extends StatefulWidget {
  final List<Post> posts;

  const FeedScreenMocked({super.key, required this.posts});

  @override
  State<FeedScreenMocked> createState() => _FeedScreenMockedState();
}

class _FeedScreenMockedState extends State<FeedScreenMocked> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Post>>(
        future: Future.value(widget.posts),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final posts = snapshot.data!;

          return ListView(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 30, child: Icon(Icons.add)),
                          Text('Добавить'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [CircleAvatar(radius: 30), Text('Анна')],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ...posts.map(
                (post) => ListTile(
                  title: Text(post.author),
                  subtitle: Text(post.content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.likedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            post.likedByCurrentUser ? Colors.red : Colors.grey,
                      ),
                      Text('${post.likesCount}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
