import 'package:get/get.dart';
import 'package:hailo/views/job_page_tabs/applicants.dart';
import 'package:hailo/views/job_page_tabs/application.dart';
import 'package:hailo/views/job_page_tabs/jobpage.dart';
import 'package:hailo/views/chat.dart';
import 'package:hailo/views/settings/supportChat.dart';
import '../../views/job_page_tabs/applicant_accept.dart';
import '../../views/job_page_tabs/jobdone.dart';
import '../../views/login.dart';
import '../../views/longterm/longterm.dart';
import '../../views/root.dart';
import '../../views/settings/settingScreens/profile_settings.dart';
import '../../views/signup.dart';
import '../../views/splash.dart';

import '../../views/tabs/createtask_tab.dart';
import '../bindings.dart';

class Routes {

  static List<GetPage> all = [
    GetPage(name: "/", page: () => const Splash(), binding: SplashBinding()),
    GetPage(name: "/login", page: () => const Login(), binding: LoginBinding()),
    GetPage(name: "/signup", page: () => const Signup(), binding: SignupBinding()),
    GetPage(name: "/root", page: () => const Root(), binding: RootBinding()),
    GetPage(name: "/jobpage", page: () => JobPage(), binding: JobPageBinding()),
    GetPage(name: "/createtask_tab", page: () =>  CreateTaskTab(uid: '',)),
    GetPage(name: '/chat', page: () => const Chats(), binding: ChatBinding()),
    GetPage(name: '/profile_settings', page: () =>  ProfileSetting(), binding: ProfileBinding()),
    GetPage(name: "/longterm", page: () =>  LongTerm(), binding: LongTermBinding()),
    GetPage(name: "/jobdone", page: () =>  JobDone()),
    GetPage(name: "/supportChat", page: () =>  supportChat(), binding: SupportChatBinding()),
  ];
}
