import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InstalledAppList extends ConsumerStatefulWidget {
  const InstalledAppList({super.key});

  @override
  ConsumerState<InstalledAppList> createState() => _InstalledAppListState();
}

class _InstalledAppListState extends ConsumerState<InstalledAppList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(
      () {
        ref.read(installedAppProvider.notifier).getAppInstalledList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(installedAppProvider);
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (status is installedAppLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
        if (status is installedAppLoaded)
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            itemCount: status.appsData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 apps per row
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final app = status.appsData[index];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.memory(
                    app.iconBytes!,
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.appName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            },
          ),
      ],
    )

        // ref.watch(installedAppInfoProvider).map(
        //       data: (data) => SafeArea(
        //         child: GridView.builder(
        //           padding: const EdgeInsets.all(12),
        //           itemCount: data.value.length,
        //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //             crossAxisCount: 4, // 4 apps per row
        //             crossAxisSpacing: 12,
        //             mainAxisSpacing: 12,
        //             childAspectRatio: 0.8,
        //           ),
        //           itemBuilder: (context, index) {
        //             final app = data.value[index];

        //             return Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Image.memory(
        //                   app.iconBytes!,
        //                   width: 50,
        //                   height: 50,
        //                 ),
        //                 const SizedBox(height: 6),
        //                 Text(
        //                   app.appName ?? '',
        //                   maxLines: 1,
        //                   overflow: TextOverflow.ellipsis,
        //                   textAlign: TextAlign.center,
        //                   style: const TextStyle(fontSize: 12),
        //                 ),
        //               ],
        //             );
        //           },
        //         ),
        //       ),
        //       error: (error) {
        //         return Center(
        //           child: Text('Error $error'),
        //         );
        //       },
        //       loading: (loading) => Center(
        //         child: CircularProgressIndicator(),
        //       ),
        //     ));
        );
  }
}

// Basic Provider Approch \\
Future<List<AppInfo>> getAllApp() async {
  final apps = await FlutterDeviceApps.listApps(
    includeSystem: false,
    onlyLaunchable: true,
    includeIcons: true,
  );

  return apps;
}

final FutureProvider<List<AppInfo>> installedAppInfoProvider = FutureProvider(
  (ref) {
    return getAllApp();
  },
);

// State Class \\
class installedAppState {}

class installedAppInitial extends installedAppState {}

class installedAppLoading extends installedAppState {}

class installedAppLoaded extends installedAppState {
  final List<AppInfo> appsData;

  installedAppLoaded(this.appsData);
}

class installedAppError extends installedAppState {}

class InstalledAppNotifier extends StateNotifier<installedAppState> {
  InstalledAppNotifier() : super(installedAppInitial());

  void getAppInstalledList() async {
    state = installedAppLoading();
    final apps = await FlutterDeviceApps.listApps(
      includeSystem: false,
      onlyLaunchable: true,
      includeIcons: true,
    );

    state = installedAppLoaded(apps);
  }
}

final installedAppProvider =
    StateNotifierProvider<InstalledAppNotifier, installedAppState>(
  (ref) => InstalledAppNotifier(),
);
