import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/common.dart';
import '../widgets/moodboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('home-scroll'),
        padding: const EdgeInsets.only(bottom: 30),
        child: ContentFrame(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'BusyProMax', bottom: 22),
              const SectionLabel(label: 'Look busy', showRule: false),
              const SizedBox(height: 9),
              const Moodboard(),
              const SizedBox(height: 26),
              SectionLabel(
                label: 'Activities',
                trailing: TextButton(
                  key: const Key('see-all-activities'),
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('All'),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded, size: 13),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: activities.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                      mainAxisExtent: 176,
                    ),
                    itemBuilder: (context, index) {
                      return ActivityCard(
                        activity: activities[index],
                        number: index + 1,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
