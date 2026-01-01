import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/marked_verses_bloc.dart';
import '../bloc/search_history_bloc.dart';
import '../views/profile_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MarkedVersesBloc(context.read())..add(LoadMarkedVerses()),
        ),
        BlocProvider(
          create: (context) =>
              SearchHistoryBloc(context.read())..add(LoadSearchHistory()),
        ),
      ],
      child: const ProfileView(),
    );
  }
}
