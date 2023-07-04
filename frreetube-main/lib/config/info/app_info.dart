import 'package:pstube/foundation/services.dart';

class AppInfo {
  static final myApp = SFInfo(
    name: 'FreeTube',
    nickname: 'FreeTube',
    url: '',
    description: 'Watch and download videos without ads',
    image: 'freetube-logo.png',
  );

  static List<SFInfo> developerInfos = <SFInfo>[
    SFInfo(
      name: 'Muhammad Ilham Faiz - 1906108',
      url: '',
      description: 'Pengembang',
    ),
    SFInfo(
      name: 'Dekha Ramdhan - 2006054',
      url: '',
      description: 'Pengembang',
    ),
  ];
}
