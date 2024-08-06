import 'package:go_router/go_router.dart';
import 'home.dart';
import 'content.dart';
import 'boardContent.dart';
import 'write.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) {
          return const Home();
        }),
    GoRoute(
        path: '/content',
        builder: (context, state) {
          final BoardContent thisContent = state.extra as BoardContent;
          return Content(thisContent: thisContent);
        }),
    GoRoute(
        path: '/write',
        builder: (context, state) {
          return Write();
        }),
  ],
);
