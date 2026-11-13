import 'package:go_router/go_router.dart';
import 'package:indo_mobile/features/home/app.dart';
import 'package:indo_mobile/features/auth/login/login.dart';
import 'package:indo_mobile/features/scanner/external_scanner.dart';
// import 'package:indo_mobile/features/scanner/bluetooth_device_scanner.dart';
import 'package:indo_mobile/features/scanner/miss_record.dart';
import 'package:indo_mobile/features/scanner/challan_details.dart';
import 'package:indo_mobile/features/scanner/model/challan_details_model.dart';
import 'package:indo_mobile/features/scanner/model/submit_batch_model.dart';
import 'package:indo_mobile/features/scanner/scanned_carton.dart';
import 'package:indo_mobile/features/scanner/scanner_view.dart';
import 'package:indo_mobile/features/scanner/scan_details_view.dart';
import 'package:indo_mobile/features/scanner/widgets/submitting_error_widget.dart';
import 'package:indo_mobile/features/scanner/widgets/submittion_success_msg.dart';
import 'package:indo_mobile/features/splash/splash_view.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: SplashScreen.routeName,

    routes: [
      GoRoute(
        path: IndoGripLoginView.routeName,
        name: IndoGripLoginView.routeName,
        builder: (context, state) => IndoGripLoginView(),
      ),
      GoRoute(
        path: ScannedCarton.routeName,
        name: ScannedCarton.routeName,
        builder: (context, state) {
          final data = state.extra as ScannedData;
          return ScannedCarton(data: data);
        },
      ),
      GoRoute(
        path: ChallanDetailsPage.routeName,
        name: ChallanDetailsPage.routeName,
        builder: (context, state) {
          final response = state.extra as ChallanDetailsResponse;

          return ChallanDetailsPage(response: response);
        },
      ),
      GoRoute(
        path: AppHome.routeName,
        name: AppHome.routeName,
        builder: (context, state) => const AppHome(),
      ),
      GoRoute(
        path: ScannerView.routeName,
        name: ScannerView.routeName,
        builder: (context, state) {
          final args = state.extra as ScannerViewArguments;
          return ScannerView(args: args);
        },
      ),

      GoRoute(
        path: ExternalScanner.routeName,
        name: ExternalScanner.routeName,
        builder: (context, state) {
          final args = state.extra as ScannerViewArguments;
          return ExternalScanner(args: args);
        },
      ),
      GoRoute(
        path: MissRecordPanel.routeName,
        name: MissRecordPanel.routeName,
        builder: (context, state) {
          final data = state.extra as SubmitBatchModel;
          return MissRecordPanel(missedRecords: data);
        },
      ),
      GoRoute(
        path: ScanDetailsView.routeName,
        name: ScanDetailsView.routeName,
        builder: (context, state) {
          final submitData = state.extra as SubmitData;
          return ScanDetailsView(submitData: submitData);
        },
      ),
      GoRoute(
        path: SubmittingSuccessMsg.routeName,
        name: SubmittingSuccessMsg.routeName,
        builder: (context, state) {
          final successMessage = state.extra as String;
          return SubmittingSuccessMsg(successMessage: successMessage);
        },
      ),

      GoRoute(
        path: SubmittingErrorWidget.routeName,
        name: SubmittingErrorWidget.routeName,
        builder: (context, state) {
          final errorMessage = state.extra as String;
          return SubmittingErrorWidget(errorMessage: errorMessage);
        },
      ),
      GoRoute(
        path: SplashScreen.routeName,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}
