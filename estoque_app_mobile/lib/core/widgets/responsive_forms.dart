import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/design_tokens.dart';
import '../responsive/responsive_utils.dart';

class ResponsiveTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final String? initialValue;
  final EdgeInsets? contentPadding;
  final bool isRequired;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const ResponsiveTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.initialValue,
    this.contentPadding,
    this.isRequired = false,
    this.labelStyle,
    this.hintStyle,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = contentPadding ?? ResponsiveUtils.valueByScreen(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      desktop: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );

    final responsiveBorderRadius = borderRadius ?? ResponsiveUtils.getCardBorderRadius(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          RichText(
            text: TextSpan(
              text: labelText!,
              style: labelStyle ?? AppTypography.inputLabel(context),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: (labelStyle ?? AppTypography.inputLabel(context))
                            .copyWith(color: AppColors.error),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: ResponsiveUtils.valueByScreen(
            context,
            mobile: DesignTokens.spacing8,
            tablet: DesignTokens.spacing8,
            desktop: DesignTokens.spacing12,
          )),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          initialValue: initialValue,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          autofocus: autofocus,
          style: AppTypography.inputText(context),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ?? AppTypography.inputHint(context),
            helperText: helperText,
            helperStyle: AppTypography.bodySmall(context),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor ?? AppColors.surface,
            contentPadding: responsivePadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.border,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.borderFocus,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: BorderSide(
                color: AppColors.borderLight,
                width: 1.5,
              ),
            ),
            errorStyle: AppTypography.inputError(context),
          ),
        ),
      ],
    );
  }
}

class ResponsiveDropdownFormField<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final bool enabled;
  final bool isRequired;
  final Widget? prefixIcon;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const ResponsiveDropdownFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.isRequired = false,
    this.prefixIcon,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = contentPadding ?? ResponsiveUtils.valueByScreen(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      desktop: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );

    final responsiveBorderRadius = borderRadius ?? ResponsiveUtils.getCardBorderRadius(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          RichText(
            text: TextSpan(
              text: labelText!,
              style: AppTypography.inputLabel(context),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: AppTypography.inputLabel(context)
                            .copyWith(color: AppColors.error),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: ResponsiveUtils.valueByScreen(
            context,
            mobile: DesignTokens.spacing8,
            tablet: DesignTokens.spacing8,
            desktop: DesignTokens.spacing12,
          )),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          onSaved: onSaved,
          style: AppTypography.inputText(context),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.inputHint(context),
            helperText: helperText,
            helperStyle: AppTypography.bodySmall(context),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: fillColor ?? AppColors.surface,
            contentPadding: responsivePadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.border,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.borderFocus,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              borderSide: BorderSide(
                color: AppColors.borderLight,
                width: 1.5,
              ),
            ),
            errorStyle: AppTypography.inputError(context),
          ),
        ),
      ],
    );
  }
}

class ResponsiveCheckboxFormField extends StatelessWidget {
  final String? labelText;
  final String? helperText;
  final bool value;
  final void Function(bool?)? onChanged;
  final String? Function(bool?)? validator;
  final void Function(bool?)? onSaved;
  final bool enabled;
  final bool isRequired;

  const ResponsiveCheckboxFormField({
    super.key,
    this.labelText,
    this.helperText,
    required this.value,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      validator: validator,
      onSaved: onSaved,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ResponsiveUtils.valueByScreen(
                    context,
                    mobile: 24,
                    tablet: 26,
                    desktop: 28,
                  ),
                  height: ResponsiveUtils.valueByScreen(
                    context,
                    mobile: 24,
                    tablet: 26,
                    desktop: 28,
                  ),
                  child: Checkbox(
                    value: field.value,
                    onChanged: enabled
                        ? (bool? newValue) {
                            field.didChange(newValue);
                            if (onChanged != null) onChanged!(newValue);
                          }
                        : null,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.valueByScreen(
                  context,
                  mobile: DesignTokens.spacing8,
                  tablet: DesignTokens.spacing12,
                  desktop: DesignTokens.spacing16,
                )),
                if (labelText != null)
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: labelText!,
                        style: AppTypography.inputLabel(context),
                        children: isRequired
                            ? [
                                TextSpan(
                                  text: ' *',
                                  style: AppTypography.inputLabel(context)
                                      .copyWith(color: AppColors.error),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            if (helperText != null) ...[
              SizedBox(height: DesignTokens.spacing8),
              Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveUtils.valueByScreen(
                    context,
                    mobile: 32,
                    tablet: 38,
                    desktop: 44,
                  ),
                ),
                child: Text(
                  helperText!,
                  style: AppTypography.bodySmall(context),
                ),
              ),
            ],
            if (field.hasError) ...[
              SizedBox(height: DesignTokens.spacing8),
              Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveUtils.valueByScreen(
                    context,
                    mobile: 32,
                    tablet: 38,
                    desktop: 44,
                  ),
                ),
                child: Text(
                  field.errorText!,
                  style: AppTypography.inputError(context),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class ResponsiveFormSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool showDivider;

  const ResponsiveFormSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.padding,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final sectionPadding = padding ?? ResponsiveUtils.valueByScreen(
      context,
      mobile: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
      tablet: const EdgeInsets.symmetric(vertical: DesignTokens.spacing20),
      desktop: const EdgeInsets.symmetric(vertical: DesignTokens.spacing24),
    );

    return Container(
      padding: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTypography.headline6(context),
            ),
            if (subtitle != null) ...[
              SizedBox(height: DesignTokens.spacing8),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium(context),
              ),
            ],
            SizedBox(height: ResponsiveUtils.valueByScreen(
              context,
              mobile: DesignTokens.spacing16,
              tablet: DesignTokens.spacing20,
              desktop: DesignTokens.spacing24,
            )),
          ],
          ...children.map((child) => Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveUtils.valueByScreen(
                    context,
                    mobile: DesignTokens.spacing16,
                    tablet: DesignTokens.spacing20,
                    desktop: DesignTokens.spacing24,
                  ),
                ),
                child: child,
              )),
          if (showDivider)
            Divider(
              height: ResponsiveUtils.valueByScreen(
                context,
                mobile: DesignTokens.spacing24,
                tablet: DesignTokens.spacing32,
                desktop: DesignTokens.spacing40,
              ),
            ),
        ],
      ),
    );
  }
}

class ResponsiveForm extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool autovalidateMode;
  final WillPopCallback? onWillPop;

  const ResponsiveForm({
    super.key,
    this.formKey,
    required this.children,
    this.padding,
    this.autovalidateMode = false,
    this.onWillPop,
  });

  @override
  Widget build(BuildContext context) {
    final formPadding = padding ?? ResponsiveUtils.getPagePadding(context);

    Widget form = Form(
      key: formKey,
      autovalidateMode: autovalidateMode ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Padding(
        padding: formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );

    if (onWillPop != null) {
      form = WillPopScope(
        onWillPop: onWillPop,
        child: form,
      );
    }

    return form;
  }
}