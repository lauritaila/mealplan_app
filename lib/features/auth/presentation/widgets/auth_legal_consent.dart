import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class LegalConsentRichText extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colors;
  final AppLocalizations l10n;

  const LegalConsentRichText({
    super.key,
    required this.textTheme,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    
    // Hardcoded splits for English and Spanish as they are the supported languages
    if (language == 'es') {
      return _buildSpanish(context);
    } else {
      return _buildEnglish(context);
    }
  }

  Widget _buildSpanish(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        children: [
          const TextSpan(text: 'Al continuar, aceptas nuestros '),
          TextSpan(
            text: 'Términos de Servicio',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push('/terms-and-conditions'),
          ),
          const TextSpan(text: ' y '),
          TextSpan(
            text: 'Política de Privacidad',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push('/privacy-policy'),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  Widget _buildEnglish(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        children: [
          const TextSpan(text: 'By continuing, you accept our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push('/terms-and-conditions'),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push('/privacy-policy'),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
