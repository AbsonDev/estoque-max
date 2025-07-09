import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/design_tokens.dart';
import '../responsive/responsive_utils.dart';

enum ButtonSize { small, medium, large }
enum ButtonVariant { primary, secondary, tertiary, outline, ghost, danger }

class ResponsiveButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final bool iconOnRight;
  final EdgeInsets? customPadding;
  final double? customBorderRadius;
  final Color? customColor;
  final String? tooltip;

  const ResponsiveButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconOnRight = false,
    this.customPadding,
    this.customBorderRadius,
    this.customColor,
    this.tooltip,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final buttonContent = _buildButtonContent(context);

    Widget button = isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonContent,
            ),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final padding = customPadding ?? _getPadding(context);
    final borderRadius = customBorderRadius ?? ResponsiveUtils.getCardBorderRadius(context);
    final minimumSize = _getMinimumSize(context);
    final textStyle = _getTextStyle(context);

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: DesignTokens.elevation2,
          shadowColor: AppColors.withOpacity(AppColors.primary, 0.3),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
          minimumSize: minimumSize,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.secondary,
          foregroundColor: AppColors.white,
          elevation: DesignTokens.elevation2,
          shadowColor: AppColors.withOpacity(AppColors.secondary, 0.3),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
          minimumSize: minimumSize,
        );
      case ButtonVariant.tertiary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.gray100,
          foregroundColor: AppColors.textPrimary,
          elevation: DesignTokens.elevation1,
          shadowColor: AppColors.withOpacity(AppColors.gray500, 0.2),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
          minimumSize: minimumSize,
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: customColor ?? AppColors.primary,
          side: BorderSide(
            color: customColor ?? AppColors.primary,
            width: 1.5,
          ),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
          minimumSize: minimumSize,
        );
      case ButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor: customColor ?? AppColors.primary,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
          minimumSize: minimumSize,
        );
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.error,
          foregroundColor: AppColors.white,
          elevation: DesignTokens.elevation2,
          shadowColor: AppColors.withOpacity(AppColors.error, 0.3),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
          minimumSize: minimumSize,
        );
    }
  }

  EdgeInsets _getPadding(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return ResponsiveUtils.valueByScreen(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          tablet: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          desktop: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      case ButtonSize.medium:
        return ResponsiveUtils.valueByScreen(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        );
      case ButtonSize.large:
        return ResponsiveUtils.valueByScreen(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          desktop: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        );
    }
  }

  Size _getMinimumSize(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return Size(0, ResponsiveUtils.getFontSize(context, DesignTokens.buttonHeightSmall));
      case ButtonSize.medium:
        return Size(0, ResponsiveUtils.getFontSize(context, DesignTokens.buttonHeightMedium));
      case ButtonSize.large:
        return Size(0, ResponsiveUtils.getFontSize(context, DesignTokens.buttonHeightLarge));
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return AppTypography.buttonSmall(context);
      case ButtonSize.medium:
        return AppTypography.buttonMedium(context);
      case ButtonSize.large:
        return AppTypography.buttonLarge(context);
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: ResponsiveUtils.getIconSize(context, DesignTokens.iconSmall),
        height: ResponsiveUtils.getIconSize(context, DesignTokens.iconSmall),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (icon != null) {
      final iconSize = ResponsiveUtils.getIconSize(context, DesignTokens.iconSmall);
      final spacing = ResponsiveUtils.valueByScreen(
        context,
        mobile: DesignTokens.spacing8,
        tablet: DesignTokens.spacing8,
        desktop: DesignTokens.spacing12,
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: iconOnRight
            ? [
                Text(text!),
                SizedBox(width: spacing),
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: icon!,
                ),
              ]
            : [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: icon!,
                ),
                SizedBox(width: spacing),
                Text(text!),
              ],
      );
    }

    return Text(text!);
  }
}

class ResponsiveIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonVariant variant;
  final bool isLoading;
  final double? customSize;
  final Color? customColor;
  final Color? customBackgroundColor;
  final String? tooltip;

  const ResponsiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.customSize,
    this.customColor,
    this.customBackgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = customSize ?? _getButtonSize(context);
    final iconSize = buttonSize * 0.6;

    Widget button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context)),
        border: variant == ButtonVariant.outline
            ? Border.all(
                color: customColor ?? AppColors.primary,
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context)),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize * 0.8,
                    height: iconSize * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
                    ),
                  )
                : SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: IconTheme(
                      data: IconThemeData(
                        color: _getIconColor(),
                        size: iconSize,
                      ),
                      child: icon,
                    ),
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  double _getButtonSize(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return ResponsiveUtils.getFontSize(context, 32);
      case ButtonSize.medium:
        return ResponsiveUtils.getFontSize(context, 40);
      case ButtonSize.large:
        return ResponsiveUtils.getFontSize(context, 48);
    }
  }

  Color _getBackgroundColor() {
    if (customBackgroundColor != null) return customBackgroundColor!;
    
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.tertiary:
        return AppColors.gray100;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color _getIconColor() {
    if (customColor != null) return customColor!;
    
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.white;
      case ButtonVariant.secondary:
        return AppColors.white;
      case ButtonVariant.tertiary:
        return AppColors.textPrimary;
      case ButtonVariant.outline:
        return AppColors.primary;
      case ButtonVariant.ghost:
        return AppColors.primary;
      case ButtonVariant.danger:
        return AppColors.white;
    }
  }
}

class ResponsiveButtonGroup extends StatelessWidget {
  final List<ResponsiveButton> buttons;
  final Axis direction;
  final double? spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapOnMobile;

  const ResponsiveButtonGroup({
    super.key,
    required this.buttons,
    this.direction = Axis.horizontal,
    this.spacing,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonSpacing = spacing ?? ResponsiveUtils.valueByScreen(
      context,
      mobile: DesignTokens.spacing8,
      tablet: DesignTokens.spacing12,
      desktop: DesignTokens.spacing16,
    );

    if (wrapOnMobile && ResponsiveUtils.isMobile(context)) {
      return Wrap(
        spacing: buttonSpacing,
        runSpacing: buttonSpacing,
        children: buttons,
      );
    }

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(buttons, buttonSpacing, true),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(buttons, buttonSpacing, false),
      );
    }
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing, bool horizontal) {
    if (widgets.isEmpty) return widgets;
    
    final List<Widget> spacedWidgets = [];
    for (int i = 0; i < widgets.length; i++) {
      spacedWidgets.add(widgets[i]);
      if (i < widgets.length - 1) {
        spacedWidgets.add(
          horizontal 
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }
    return spacedWidgets;
  }
}

class ResponsiveFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool mini;

  const ResponsiveFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = mini 
        ? ResponsiveUtils.getFontSize(context, 40)
        : ResponsiveUtils.getFontSize(context, 56);

    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? AppColors.white,
        elevation: elevation ?? DesignTokens.elevation4,
        mini: mini,
        child: child,
      ),
    );
  }
}