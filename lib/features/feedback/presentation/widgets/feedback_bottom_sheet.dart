import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/feedback/domain/entities/submit_feedback_request.dart';
import 'package:meal_plan_app/features/feedback/presentation/providers/feedback_provider.dart';
import 'package:meal_plan_app/features/shared/shared.dart';

class FeedbackBottomSheet extends ConsumerStatefulWidget {
  const FeedbackBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  @override
  ConsumerState<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends ConsumerState<FeedbackBottomSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final String _selectedCategory = 'general';

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>() ?? const AppCustomColors();
    // final l10n = AppLocalizations.of(context); // Unused for now as strings are hardcoded or not in l10n
    final submissionState = ref.watch(feedbackSubmissionProvider);

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
            '¡Tu opinión nos importa!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.textDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuéntanos qué te parece la app o cómo podemos mejorar.',
            style: textTheme.bodyMedium?.copyWith(color: customColors.slateGrey),
          ),
          const SizedBox(height: 32),
          
          // Rating Row
          Text(
            '¿Qué te parece la experiencia?'.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.slateGrey?.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final score = index + 1;
              final isSelected = _rating >= score;
              return Semantics(
                label: 'Rate $score star${score == 1 ? '' : 's'}',
                selected: _rating >= score,
                button: true,
                onTapHint: 'Set rating to $score',
                child: GestureDetector(
                  onTap: () => setState(() => _rating = score),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? customColors.darkSage?.withValues(alpha: 0.1) 
                          : customColors.chartTabBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isSelected ? customColors.darkSage : customColors.slateGrey?.withValues(alpha: 0.5),
                      size: 32,
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 32),
          
          // Category Selection
          Text(
            'COMENTARIOS'.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.slateGrey?.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: customColors.textDarkBlue),
            decoration: InputDecoration(
              hintText: 'Cuéntanos más...',
              hintStyle: textTheme.bodyLarge?.copyWith(color: customColors.slateGrey?.withValues(alpha: 0.4)),
              filled: true,
              fillColor: customColors.chartTabBackground?.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: (submissionState.isLoading || _rating == 0) 
                  ? null 
                  : () async {
                      final req = SubmitFeedbackRequest(
                        type: _selectedCategory,
                        message: _commentController.text,
                        rating: _rating.toString(),
                      );
                      
                      await ref.read(feedbackSubmissionProvider.notifier).submit(req);
                      
                      if (context.mounted) {
                        final newState = ref.read(feedbackSubmissionProvider);
                        if (newState.hasError) {
                          CustomSnackbar.showError(context, 'No se pudo enviar el feedback');
                        } else {
                          CustomSnackbar.showSuccess(context, '¡Gracias por tus comentarios!');
                          Navigator.pop(context);
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: customColors.darkSage,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: submissionState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Enviar Comentarios',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
