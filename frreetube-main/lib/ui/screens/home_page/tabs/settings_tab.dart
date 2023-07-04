import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/config/info/app_info.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/states.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsTab>
    with AutomaticKeepAliveClientMixin {
  late String version = '';

  @override
  void initState() {
    super.initState();
    http
        .get(
      Uri.parse(
        'https://api.github.com/repos/prateekmedia/pstube/releases',
      ),
    )
        .then((http.Response response) async {
      await compute(
        jsonDecode,
        response.body,
      ).then(
        (dynamic value) => setState(
          () {
            final json = value as List<Map<String, String>>;
            version = json.first['tag_name']!;
          },
        ),
      );
    }).catchError((dynamic exception) {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final path = ref.watch(downloadPathProvider).path;
    return AdwClamp.scrollable(
      child: AdwPreferencesGroup(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          AdwActionRow(
            title: context.locals.downloadFolder,
            subtitle: path,
            onActivated: () async => ref.read(downloadPathProvider).path =
                await FilePicker.platform.getDirectoryPath(
              dialogTitle: context.locals.chooseDownloadFolder,
            ),
          ),
          AdwSwitchRow(
            title: context.locals.darkMode,
            value: context.isDark,
            onChanged: (bool value) =>
                ref.read(themeTypeProvider.notifier).toggle = value,
          ),
          AdwSwitchRow(
            title: context.locals.thumbnailDownloader,
            subtitle: context.locals.showThumbnailDownloaderInDownloadPopup,
            value: ref.watch(thumbnailDownloaderProvider),
            onChanged: (bool value) =>
                ref.read(thumbnailDownloaderProvider.notifier).value = value,
          ),
          AdwComboRow(
            title: context.locals.region,
            onSelected: (val) => ref.watch(regionProvider.notifier).region =
                Regions.values.toList()[val],
            selectedIndex:
                Regions.values.toList().indexOf(ref.watch(regionProvider)),
            choices: Regions.values
                .map(
                  (Regions e) => e.toString(),
                )
                .toList(),
          ),
          AdwActionRow(
            title: context.locals.resetSettings,
            onActivated: () => resetSettings(ref),
          ),
          AdwActionRow(
            title: '${context.locals.about} ${AppInfo.myApp.name}',
            onActivated: () => showDialog<dynamic>(
              context: context,
              builder: (_) => AdwAboutWindow(
                appName: AppInfo.myApp.name,
                actions: AdwActions(
                  onDoubleTap: AdwActions().windowManager.onDoubleTap,
                  onHeaderDrag: AdwActions().windowManager.onHeaderDrag,
                  onClose: Navigator.of(context).pop,
                ),
                headerBarStyle: const HeaderBarStyle(
                  isTransparent: true,
                  autoPositionWindowButtons: false,
                ),
                appIcon: Image.asset(AppInfo.myApp.imagePath),
                credits: [
                  AdwPreferencesGroup.credits(
                    title: 'pengembang',
                    children: AppInfo.developerInfos
                        .map(
                          (e) => AdwActionRow(
                            title: e.name,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            subtitle: context.locals.infoAboutTheAppAndtheDevelopers,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
