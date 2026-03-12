import 'package:meal_plan_app/features/shared/shared.dart';
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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    
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

    return AuthLayout(
      child: Column(
        children: [
          StepsWizard(
            currentStep: currentStep + 1,
            totalSteps: _viewRoutes.length,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 500, // Fixed height for page view or use intrinsic if needed
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemCount: _viewRoutes.length,
              itemBuilder: (context, index) {
                return _viewRoutes[index];
              },
            ),
          ),
        ],
      ),
      footer: _NavigationControls(
        pageIndex: currentStep,
        totalSteps: _viewRoutes.length,
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
    final colors = Theme.of(context).colorScheme;
    
    ref.listen(preferencesWizardProvider.select((s) => s.formStatus), (
      previous,
      next,
    ) {
      if (next == FormStatus.error) {
        final errorState = ref.read(preferencesWizardProvider);
        CustomSnackbar.showError(context, 
              localizeErrorCode(
                l10n,
                errorState.errorCode,
                fallback: errorState.errorMessage ?? l10n.unknownError,
              ),
            );
      }
      if (next == FormStatus.success) {
        CustomSnackbar.showSuccess(context, l10n.preferencesSaved);
      }
    });

    final wizardState = ref.watch(preferencesWizardProvider);
    final bool isLastStep = pageIndex == totalSteps - 1;
    final bool isSubmitting = wizardState.formStatus == FormStatus.submitting;

    return Row(
      children: [
        if (pageIndex > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () => ref.read(preferencesWizardProvider.notifier).previousStep(),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.wizardPrevious),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          )
        else
          const Spacer(),
        
        const SizedBox(width: 16),
        
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: isSubmitting
                ? null
                : () {
                    if (isLastStep) {
                      ref.read(preferencesWizardProvider.notifier).submitPreferences();
                    } else {
                      ref.read(preferencesWizardProvider.notifier).nextStep();
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSubmitting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  Text(
                    isLastStep ? l10n.wizardFinish : l10n.wizardNext,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
