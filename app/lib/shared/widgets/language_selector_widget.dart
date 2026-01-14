/// File: lib/shared/widgets/language_selector_widget.dart
/// Purpose: Widget/Dropdown to switch application language (English/Bangla).
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';

/// Widget that allows users to change the app's locale.
class LanguageSelectorWidget extends ConsumerWidget {
  final bool isDropdown;
  final Color? contentColor;

  const LanguageSelectorWidget({
    super.key,
    this.isDropdown = false,
    this.contentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Default to white if not provided (for backward compatibility with AuthLayout),
    // or arguably should default to theme color.
    // Given existing usage was hardcoded white, let's default to null and handle logic.
    final effectiveColor = contentColor ?? Colors.white;

    if (isDropdown) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: currentLocale,
          icon: Icon(Icons.language, color: effectiveColor),
          dropdownColor: theme
              .cardColor, // Changed from hardcoded blueGrey to theme card color for better adaptive look
          style: GoogleFonts.poppins(color: effectiveColor),
          selectedItemBuilder: (BuildContext context) {
            return [const Locale('en'), const Locale('bn')].map<Widget>((
              Locale item,
            ) {
              return Center(
                child: Text(
                  item.languageCode == 'en'
                      ? (l10n?.english ?? 'English')
                      : (l10n?.bangla ?? 'Bangla'),
                  style: GoogleFonts.poppins(color: effectiveColor),
                ),
              );
            }).toList();
          },
          items: [
            DropdownMenuItem(
              value: const Locale('en'),
              child: Text(
                l10n?.english ?? 'English',
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyMedium?.color,
                ), // Dropdown menu items should track theme text color
              ),
            ),
            DropdownMenuItem(
              value: const Locale('bn'),
              child: Text(
                l10n?.bangla ?? 'Bangla',
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              ref.read(languageProvider.notifier).setLocale(newLocale);
            }
          },
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(
                l10n?.language ?? 'Language',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildOption(
                context,
                ref,
                'EN',
                const Locale('en'),
                currentLocale,
              ),
              const SizedBox(width: 8),
              _buildOption(
                context,
                ref,
                'বাংলা',
                const Locale('bn'),
                currentLocale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    Locale locale,
    Locale current,
  ) {
    final isSelected = current.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: () => ref.read(languageProvider.notifier).setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
