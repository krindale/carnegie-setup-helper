import 'package:flutter/material.dart';

/// IBM Carbon Design System — White (light) theme tokens.
/// https://carbondesignsystem.com/elements/color/tokens/
abstract final class CarbonColors {
  // Custom palette: https://coolors.co/eef0f2-dadcdb-c6c7c4-a2999e-846a6a-353b3c
  // Backgrounds & layers
  static const pageBackground = Color(0xFFEEF0F2);
  static const background = Color(0xFFFFFFFF);
  static const layer01 = Color(0xFFDADCDB);
  static const layerHover01 = Color(0xFFC6C7C4);
  static const field01 = Color(0xFFDADCDB);
  static const borderSubtle = Color(0xFFC6C7C4);
  static const borderStrong = Color(0xFFA2999E);

  // Text
  static const textPrimary = Color(0xFF353B3C);
  static const textSecondary = Color(0xFF846A6A);
  static const textHelper = Color(0xFFA2999E);
  static const textOnColor = Color(0xFFFFFFFF);

  // Interactive — rose taupe accent from the palette.
  static const interactive = Color(0xFF846A6A);
  static const buttonPrimaryHover = Color(0xFF6E5757);
  static const buttonSecondary = Color(0xFF353B3C);
  static const buttonSecondaryHover = Color(0xFF454C4D);

  // UI shell
  static const shell = Color(0xFF353B3C);
  static const shellHover = Color(0xFF454C4D);

  // Support
  static const supportError = Color(0xFFDA1E28); // Red 60
  static const supportWarning = Color(0xFFF1C21B); // Yellow 30
  static const supportWarningText = Color(0xFF8E6A00);
  static const supportSuccess = Color(0xFF24A148); // Green 50

  // Notification tints (Carbon inline notification, light theme)
  static const notifErrorBg = Color(0xFFFFF1F1);
  static const notifWarningBg = Color(0xFFFCF4D6); // Yellow 10
  static const notifSuccessBg = Color(0xFFDEFBE6);

  // Tint used for selected/hovered interactive surfaces (rose taupe 15%).
  static const interactiveTint = Color(0xFFECE6E6);

  // Tag colors (bg / text)
  static const tagRedBg = Color(0xFFFFD7D9);
  static const tagRedText = Color(0xFFA2191F);
  static const tagGreenBg = Color(0xFFA7F0BA);
  static const tagGreenText = Color(0xFF0E6027);
  static const tagAccentBg = Color(0xFFECE6E6);
  static const tagAccentText = Color(0xFF6E5757);
  static const tagGrayBg = Color(0xFFC6C7C4);
  static const tagGrayText = Color(0xFF353B3C);
}

/// Carbon type scale (productive), rendered with the SUIT typeface.
abstract final class CarbonText {
  static const _family = 'SUIT';

  static const heading05 = TextStyle(
    fontFamily: _family,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w300,
    color: CarbonColors.textPrimary,
  );
  static const heading04 = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w400,
    color: CarbonColors.textPrimary,
  );
  static const heading03 = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w500,
    color: CarbonColors.textPrimary,
  );
  static const heading02 = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w700,
    color: CarbonColors.textPrimary,
  );
  static const heading01 = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    color: CarbonColors.textPrimary,
  );
  static const body02 = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: CarbonColors.textPrimary,
  );
  static const body01 = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.16,
    color: CarbonColors.textPrimary,
  );
  static const label01 = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.32,
    color: CarbonColors.textSecondary,
  );
  static const helperText01 = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.32,
    color: CarbonColors.textHelper,
  );
}

/// Carbon spacing scale.
abstract final class CarbonSpacing {
  static const double s2 = 4;
  static const double s3 = 8;
  static const double s4 = 12;
  static const double s5 = 16;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 40;
  static const double s9 = 48;
}

/// Carbon button: sharp corners, 48px tall, left-aligned label with
/// trailing icon.
class CarbonButton extends StatelessWidget {
  const CarbonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = CarbonButtonKind.primary,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CarbonButtonKind kind;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return Container(
        height: 48,
        color: CarbonColors.layerHover01,
        padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Text(
              label,
              style: CarbonText.body01.copyWith(color: CarbonColors.textHelper),
            ),
            if (icon != null) ...[
              if (expanded) const Spacer() else const SizedBox(width: 32),
              Icon(icon, size: 16, color: CarbonColors.textHelper),
            ],
          ],
        ),
      );
    }
    final (bg, fg, hover, border) = switch (kind) {
      CarbonButtonKind.primary => (
        CarbonColors.interactive,
        CarbonColors.textOnColor,
        CarbonColors.buttonPrimaryHover,
        null,
      ),
      CarbonButtonKind.secondary => (
        CarbonColors.buttonSecondary,
        CarbonColors.textOnColor,
        CarbonColors.buttonSecondaryHover,
        null,
      ),
      CarbonButtonKind.tertiary => (
        Colors.transparent,
        CarbonColors.interactive,
        CarbonColors.interactiveTint,
        CarbonColors.interactive,
      ),
      CarbonButtonKind.ghost => (
        Colors.transparent,
        CarbonColors.interactive,
        CarbonColors.interactiveTint,
        null,
      ),
    };

    return Material(
      color: bg,
      shape: border == null
          ? const RoundedRectangleBorder()
          : RoundedRectangleBorder(side: BorderSide(color: border)),
      child: InkWell(
        onTap: onPressed,
        hoverColor: hover,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(label, style: CarbonText.body01.copyWith(color: fg)),
              if (icon != null) ...[
                if (expanded) const Spacer() else const SizedBox(width: 32),
                Icon(icon, size: 16, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum CarbonButtonKind { primary, secondary, tertiary, ghost }

/// Bar-less top action: 44x44 ghost icon button on the page background.
class TopIconButton extends StatelessWidget {
  const TopIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: CarbonColors.layerHover01,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: CarbonColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Top row for bar-less screens: optional back button + right-aligned actions.
class TopBar extends StatelessWidget {
  const TopBar({super.key, this.onBack, this.actions = const []});

  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: CarbonSpacing.s3),
      child: Row(
        children: [
          if (onBack != null)
            TopIconButton(
              icon: Icons.arrow_back,
              tooltip: '뒤로',
              onTap: onBack!,
            ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

/// Carbon content switcher: segmented toggle with sharp corners.
class CarbonContentSwitcher extends StatelessWidget {
  const CarbonContentSwitcher({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: CarbonColors.buttonSecondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, label) in labels.indexed)
            InkWell(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CarbonSpacing.s5,
                ),
                alignment: Alignment.center,
                color: i == selected
                    ? CarbonColors.buttonSecondary
                    : CarbonColors.background,
                child: Text(
                  label,
                  style: CarbonText.body01.copyWith(
                    color: i == selected
                        ? CarbonColors.textOnColor
                        : CarbonColors.textPrimary,
                    fontWeight: i == selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Carbon tag: small rounded-full label chip.
class CarbonTag extends StatelessWidget {
  const CarbonTag({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
  });

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: CarbonText.label01.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
