import 'package:meal_plan_app/features/shared/shared.dart';
// lib/features/preferences/presentation/screens/preference_wizard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/preferences_wizard/preferences_wizard_state.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';

import '../provider/provider.dart';
import '../views/views.dart';
import '../widgets/widgets_auth.dart';

class PreferenceWizardScreen extends ConsumerStatefulWidget {
  const PreferenceWizardScreen({super.key});

  @override
  PreferenceWizardScreenState createState() => PreferenceWizardScreenState();
}

class PreferenceWizardScreenState
    extends ConsumerState<PreferenceWizardScreen> {
  late PageController _pageController;

  final List<Widget> _viewRoutes = const [
    DietaryStep(),
    AllergiesStep(),
    FoodPreferencesStep(),
    GoalsStep(),
    CookingDetailsStep(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(preferencesWizardProvider.select((state) => state.step), (
      previous,
      next,
    ) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    final int currentStep = ref.watch(preferencesWizardProvider).step;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: StepsWizard(
                currentStep: currentStep + 1,
                totalSteps: _viewRoutes.length,
              ),
            ),
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                itemCount: _viewRoutes.length,
                itemBuilder: (context, index) {
                  return _viewRoutes[index];
                },
              ),
            ),
            _NavigationControls(
              pageIndex: currentStep,
              totalSteps: _viewRoutes.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationControls extends ConsumerWidget {
  final int pageIndex;
  final int totalSteps;

  const _NavigationControls({
    required this.pageIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen(preferencesWizardProvider.select((s) => s.formStatus), (
      previous,
      next,
    ) {
      if (next == FormStatus.error) {
        final errorState = ref.read(preferencesWizardProvider);
        CustomSnackbar.showInfo(context, 
              localizeErrorCode(
                l10n,
                errorState.errorCode,
                fallback: errorState.errorMessage ?? l10n.unknownError,
              ),
            );
      }
      if (next == FormStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.preferencesSaved)));
      }
    });

    final wizardState = ref.watch(preferencesWizardProvider);
    final bool isLastStep = pageIndex == totalSteps - 1;
    final bool isSubmitting = wizardState.formStatus == FormStatus.submitting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (pageIndex > 0)
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      ref
                          .read(preferencesWizardProvider.notifier)
                          .previousStep();
                    },
              child: Text(l10n.wizardPrevious),
            )
          else
            const SizedBox(),

          ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () {
                    if (isLastStep) {
                      ref
                          .read(preferencesWizardProvider.notifier)
                          .submitPreferences();
                    } else {
                      ref.read(preferencesWizardProvider.notifier).nextStep();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: isSubmitting && isLastStep
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(isLastStep ? l10n.wizardFinish : l10n.wizardNext),
          ),
        ],
      ),
    );
  }
}
