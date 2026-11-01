import 'package:flutter/material.dart';

enum ActivityKind {
  videoCall,
  messages,
  texting,
  foodOrdering,
  shopping,
  villaSecurity,
}

enum ActivitySurface {
  onDevice,
  externalWebsite;

  String get label => switch (this) {
    ActivitySurface.onDevice => 'ON DEVICE',
    ActivitySurface.externalWebsite => 'IN-APP BROWSER',
  };
}

@immutable
class ActivityDefinition {
  const ActivityDefinition({
    required this.id,
    required this.route,
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.image,
    required this.kind,
    required this.surface,
    this.url,
  });

  final String id;
  final String route;
  final String title;
  final String tagline;
  final String description;
  final IconData icon;
  final String image;
  final ActivityKind kind;
  final ActivitySurface surface;
  final String? url;

  bool get opensWebsite => surface == ActivitySurface.externalWebsite;
  Uri? get websiteUri => url == null ? null : Uri.tryParse(url!);
  String get domain => websiteUri?.host ?? '';
}

const activities = <ActivityDefinition>[
  ActivityDefinition(
    id: 'video-call',
    route: '/video-call',
    title: 'Video Call',
    tagline: 'Just your camera.',
    description: 'A private preview in a simulated call.',
    icon: Icons.videocam_outlined,
    image: 'assets/images/activities/video_call.jpg',
    kind: ActivityKind.videoCall,
    surface: ActivitySurface.onDevice,
  ),
  ActivityDefinition(
    id: 'messages',
    route: '/messages',
    title: 'Instagram Messages',
    tagline: 'AI demo threads.',
    description: 'Fictional contacts. AI replies when connected.',
    icon: Icons.chat_bubble_outline_rounded,
    image: 'assets/images/activities/messages.jpg',
    kind: ActivityKind.messages,
    surface: ActivitySurface.onDevice,
  ),
  ActivityDefinition(
    id: 'texting',
    route: '/texting',
    title: 'Texting',
    tagline: 'Short, quiet threads.',
    description: 'SMS-style demo. No SMS access.',
    icon: Icons.sms_outlined,
    image: 'assets/images/activities/texting.jpg',
    kind: ActivityKind.texting,
    surface: ActivitySurface.onDevice,
  ),
  ActivityDefinition(
    id: 'food',
    route: '/food',
    title: 'Order Food',
    tagline: 'FoodNeverComes.',
    description: 'The real site, in-app.',
    icon: Icons.takeout_dining_outlined,
    image: 'assets/images/activities/food.jpg',
    kind: ActivityKind.foodOrdering,
    surface: ActivitySurface.externalWebsite,
    url: 'https://foodnevercome.com/',
  ),
  ActivityDefinition(
    id: 'shopping',
    route: '/shop',
    title: 'Browse & Shop',
    tagline: 'Amazon, in-app.',
    description: 'The real store. No checkout help.',
    icon: Icons.shopping_bag_outlined,
    image: 'assets/images/activities/shopping.jpg',
    kind: ActivityKind.shopping,
    surface: ActivitySurface.externalWebsite,
    url: 'https://www.amazon.com/',
  ),
  ActivityDefinition(
    id: 'villa',
    route: '/villa',
    title: 'Villa Security',
    tagline: 'A quiet camera loop.',
    description: 'AI-generated camera loop. Not live.',
    icon: Icons.photo_camera_outlined,
    image: 'assets/images/activities/villa.jpg',
    kind: ActivityKind.villaSecurity,
    surface: ActivitySurface.onDevice,
  ),
];

ActivityDefinition activityById(String id) =>
    activities.firstWhere((activity) => activity.id == id);

const placeholderActivity = ActivityDefinition(
  id: 'missing',
  route: '/',
  title: 'Activity',
  tagline: '',
  description: '',
  icon: Icons.apps_outlined,
  image: 'assets/images/activities/video_call.jpg',
  kind: ActivityKind.videoCall,
  surface: ActivitySurface.onDevice,
);
