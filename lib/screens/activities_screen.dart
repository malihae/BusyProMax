import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/common.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onDevice = activities
        .where((activity) => !activity.opensWebsite)
        .toList(growable: false);
    final websites = activities
        .where((activity) => activity.opensWebsite)
        .toList(growable: false);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('activities-scroll'),
        padding: const EdgeInsets.only(bottom: 32),
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Activities'),
              const SectionLabel(label: 'On device'),
              const SizedBox(height: 12),
              for (var index = 0; index < onDevice.length; index++) ...[
                ActivityRow(activity: onDevice[index]),
                if (index != onDevice.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 30),
              const SectionLabel(label: 'Websites'),
              const SizedBox(height: 12),
              for (var index = 0; index < websites.length; index++) ...[
                ActivityRow(activity: websites[index]),
                if (index != websites.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 20),
              const DemoNotice(
                icon: Icons.language_rounded,
                text: 'Real sites. No orders or purchases here.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
