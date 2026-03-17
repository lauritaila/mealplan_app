import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/shared/providers/subscription_promo_code_provider.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class PromoCodeBottomSheet extends ConsumerStatefulWidget {
  final String planId;

  const PromoCodeBottomSheet({
    super.key,
    required this.planId,
  });

  static Future<void> show(BuildContext context, {required String planId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromoCodeBottomSheet(planId: planId),
    );
  }

  @override
  ConsumerState<PromoCodeBottomSheet> createState() => _PromoCodeBottomSheetState();
}

class _PromoCodeBottomSheetState extends ConsumerState<PromoCodeBottomSheet> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>() ?? const AppCustomColors();
    final l10n = AppLocalizations.of(context);
    final promoState = ref.watch(subscriptionPromoCodeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: customColors.chartTabBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.enterPromoCode,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.textDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.promoCodeHint,
            style: textTheme.bodyMedium?.copyWith(color: customColors.slateGrey),
          ),
          const SizedBox(height: 32),
          
          Text(
            l10n.promoCodeLabel.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.slateGrey?.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600, 
              color: customColors.textDarkBlue,
            ),
            decoration: InputDecoration(
              hintText: 'MEAL15',
              hintStyle: textTheme.bodyLarge?.copyWith(color: customColors.slateGrey?.withValues(alpha: 0.4)),
              filled: true,
              fillColor: customColors.chartTabBackground?.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
              suffixIcon: promoState.isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            ),
          ),
          
          if (promoState.error != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.invalidPromoCode,
              style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ],
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: promoState.isLoading 
                  ? null 
                  : () async {
                      if (_codeController.text.trim().isEmpty) return;
                      
                      final success = await ref.read(subscriptionPromoCodeProvider.notifier).validateCode(
                        _codeController.text.trim().toUpperCase(),
                      );
                      
                      if (success) {
                        if (context.mounted) {
                          CustomSnackbar.showSuccess(context, l10n.promoCodeApplied);
                          Navigator.pop(context);
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: customColors.darkSage,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: promoState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      l10n.validateAction,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
