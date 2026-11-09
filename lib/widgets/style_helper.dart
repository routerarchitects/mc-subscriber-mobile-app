import 'dart:io';

import 'package:family_wifi/theme/text_style_helper.dart';
import 'package:family_wifi/theme/theme_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StyleHelper {
  static bool get isIOS => Platform.isIOS;
  static const int debounceCoolDownTimeInMillis = 50;

  /* static ThemeData buildThemeData(BuildContext context) => ThemeData(
        primaryColor: ColorUtil.primaryColor,
        primaryColorDark: ColorUtil.primaryColorDark,
        fontFamily: AppConstants.fontFamily,
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(ColorUtil.primaryColor),
            primaryColorDark: ColorUtil.primaryColorDark),
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: const IconThemeData(color: ColorUtil.textTitleColor),
            titleTextStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.fontFamily,
              color: Colors.black,
            )),
        cupertinoOverrideTheme: CupertinoThemeData(
            textTheme: CupertinoTheme.of(context).textTheme.copyWith(
                  textStyle: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500),
                  navTitleTextStyle: CupertinoTheme.of(context)
                      .textTheme
                      .navTitleTextStyle
                      .copyWith(
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.bold),
                )),
      ); */

  static void showProgressDialog(
    BuildContext context,
    String? title,
    String? msg, {
    bool useRootNavigator = true,
  }) {
    final tsh = TextStyleHelper.instance;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) Text(title, style: tsh.title18BoldInter),
                  Row(
                    mainAxisAlignment: msg == null
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      const CircularProgressIndicator(),
                      if (msg != null) const SizedBox(width: 16.0),
                      if (msg != null)
                        Text(msg, style: tsh.title16RegularInter),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* static void showUploadStateDialog(BuildContext context, String? title,
      ValueNotifier<String> msg, ValueNotifier<double>? progressNotifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(title, style: Theme.of(context).textTheme.headline6),
                    if (progressNotifier == null ||
                        progressNotifier.value == -1)
                      _buildProgressWithMsg(context, msg),
                    if (progressNotifier != null)
                      ValueListenableProvider<double>.value(
                        value: progressNotifier,
                        child: Consumer<double>(
                          builder: (context, value, child) => value >= 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(msg.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1),
                                    const SizedBox(height: 16.0),
                                    LinearProgressIndicator(
                                      value: value / 100,
                                      backgroundColor: ColorUtil.lightGrey,
                                      valueColor: const AlwaysStoppedAnimation(
                                          ColorUtil.primaryColor),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text('${value.toInt()} %',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1),
                                  ],
                                )
                              : _buildProgressWithMsg(context, msg),
                        ),
                      ),
                  ],
                ),
              )),
        );
      },
    );
  }

  static Widget _buildProgressWithMsg(
      BuildContext context, ValueNotifier<String> msg) {
    return Row(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(width: 16.0),
        ValueListenableProvider<String>.value(
          value: msg,
          child: Consumer<String>(
            builder: (context, value, child) =>
                Text(value, style: Theme.of(context).textTheme.subtitle1),
          ),
        ),
      ],
    );
  } */

  static Future<dynamic> showAlertDialog(
    BuildContext context,
    String msg,
    String yesLabel, {
    String? title,
    Color backgroundColor = Colors.white,
    Function? yesHandler,
    String? noLabel,
    Function? noHandler,
    bool dismissOnTouchOutside = false,
    bool useRootNavigator = true,
    bool centerAlignment = false,
    double? iosActionWidth,
  }) async {
    TextStyleHelper tsh = TextStyleHelper.instance;
    return isIOS
        ? await showCupertinoDialog(
            context: context,
            useRootNavigator: useRootNavigator,
            barrierDismissible: dismissOnTouchOutside,
            builder: (BuildContext context) {
              return PopScope(
                canPop: dismissOnTouchOutside,
                child: CupertinoAlertDialog(
                  title: title != null
                      ? Text(
                          title,
                          textAlign: TextAlign.center,
                          style: tsh.title18BoldInter,
                        )
                      : null,
                  content: SingleChildScrollView(
                    child: Text(
                      msg,
                      style: tsh.title16RegularInter.copyWith(height: 1.2),
                    ),
                  ),
                  actions: alertActions1(
                    yesLabel,
                    context,
                    okHandler: yesHandler,
                    cancelTitle: noLabel,
                    cancelHandler: noHandler,
                    iosActionWidth: iosActionWidth,
                  ),
                ),
              );
            },
          )
        : showDialog(
            context: context,
            useRootNavigator: useRootNavigator,
            barrierDismissible: dismissOnTouchOutside,
            builder: (BuildContext context) {
              return PopScope(
                canPop: dismissOnTouchOutside,
                child: _alertDialog(
                  context,
                  msg,
                  yesLabel,
                  title: title,
                  backgroundColor: backgroundColor,
                  okHandler: yesHandler,
                  cancelTitle: noLabel,
                  cancelHandler: noHandler,
                  actionAlign: centerAlignment,
                ),
              );
            },
          );
  }

  static Widget _alertDialog(
    BuildContext context,
    String msg,
    String okTitle, {
    String? title,
    Color backgroundColor = Colors.white,
    Function? okHandler,
    String? cancelTitle,
    Function? cancelHandler,
    bool actionAlign = false,
  }) {
    TextStyleHelper tsh = TextStyleHelper.instance;
    return AlertDialog(
      actionsAlignment: actionAlign ? MainAxisAlignment.center : null,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      title: title != null
          ? Text(
              title,
              style: tsh.title18BoldInter,
              textAlign: TextAlign.center,
            )
          : null,
      content: SingleChildScrollView(
        child: Text(msg, style: tsh.title16RegularInter.copyWith(height: 1.2)),
      ),
      actions: alertActions1(
        okTitle,
        context,
        okHandler: okHandler,
        cancelTitle: cancelTitle,
        cancelHandler: cancelHandler,
      ),
    );
  }

  static List<Widget> alertActions(
    String okTitle,
    BuildContext context, {
    Function? okHandler,
    String? cancelTitle,
    Function? cancelHandler,
  }) {
    return [
      if (cancelTitle != null)
        TextButton(
          child: Text(cancelTitle),
          onPressed: () {
            Navigator.of(context).pop(false);
            if (cancelHandler != null) cancelHandler();
          },
        ),
      TextButton(
        child: Text(okTitle),
        onPressed: () {
          Navigator.of(context).pop(true);
          if (okHandler != null) okHandler();
        },
      ),
    ];
  }

  static List<Widget> alertActions1(
    String okTitle,
    BuildContext context, {
    Function? okHandler,
    String? cancelTitle,
    Function? cancelHandler,
    double? iosActionWidth,
  }) {
    return [
      _buildAdaptiveAction(
        context,
        okTitle,
        onPressed: () {
          Navigator.of(context).pop(true);
          if (okHandler != null) okHandler();
        },
        iosActionWidth: iosActionWidth,
      ),
      if (cancelTitle != null)
        _buildAdaptiveAction(
          context,
          cancelTitle,
          onPressed: () {
            Navigator.of(context).pop(false);
            if (cancelHandler != null) cancelHandler();
          },
          iosActionWidth: iosActionWidth,
        ),
    ];
  }

  static Widget _buildAdaptiveAction(
    BuildContext context,
    String title, {
    VoidCallback? onPressed,
    double? iosActionWidth,
  }) {
    if (isIOS) {
      return SizedBox(
        width: iosActionWidth,
        child: CupertinoDialogAction(
          child: Text(
            title,
            style: TextStyleHelper.instance.title16RegularInter.copyWith(
              color: appTheme.blue_700,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: onPressed,
        ),
      );
    }
    return TextButton(
      child: Text(
        title,
        style: TextStyleHelper.instance.body14RegularInter.copyWith(
          color: appTheme.blue_700,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
    );
  }

  static Future<T?> showAdaptiveBottomSheet<T>(
    BuildContext ctx, {
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = false,
    bool useRootNavigator = true,
    BorderRadius borderRadius = const BorderRadius.only(
      topLeft: const Radius.circular(16.0),
      topRight: const Radius.circular(16.0),
    ),
  }) {
    if (isIOS) {
      return showCupertinoModalPopup<T>(
        context: ctx,
        useRootNavigator: useRootNavigator,
        barrierDismissible: isDismissible,
        builder: (context) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(ctx).top,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Material(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: ctx,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: isDismissible,
        showDragHandle: isDismissible,
        backgroundColor: Theme.of(ctx).canvasColor,
        useRootNavigator: useRootNavigator,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        builder: (context) {
          return PopScope(
            canPop: isDismissible,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(ctx).top,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: child,
              ),
            ),
          );
        },
      );
    }
  }

  /* static PreferredSizeWidget buildAppBar(
    BuildContext context,
    String? title, {
    bool showLeading = false,
    VoidCallback? backHandler,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? backButtonColor,
    double? toolbarElevation,
    bool? showSearchView,
    Widget? searchView,
  }) {
    if (isIOS) {
      return CupertinoNavigationBar(
        middle: title != null
            ? showSearchView == true
                ? searchView
                : title.isNotEmpty
                    ? FittedBox(child: Text(title.tr()))
                    : Text(title.tr())
            : null,
        trailing: actions != null
            ? Material(
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                child: Theme(
                  data: Theme.of(context).copyWith(
                      iconTheme:
                          const IconThemeData(color: ColorUtil.textTitleColor)),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions.map((e) => e).toList()),
                ),
              )
            : null,
        automaticallyImplyLeading: false,
        leading: showLeading
            ? Material(
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                child: Theme(
                  data: Theme.of(context).copyWith(
                      iconTheme:
                          const IconThemeData(color: ColorUtil.textTitleColor)),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 28.0),
                    color: backButtonColor,
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: backHandler ?? Navigator.of(context).pop,
                  ),
                ),
              )
            : null,
        backgroundColor: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: toolbarElevation == 0.0
                ? Colors.transparent
                : const Color(0x4D000000),
            width: 0.0, // 0.0 means one physical pixel
          ),
        ),
      );
    } else {
      return AppBar(
        title: title != null
            ? showSearchView == true
                ? searchView
                : title.isNotEmpty
                    ? FittedBox(child: Text(title.tr()))
                    : Text(title.tr())
            : const SizedBox.shrink(),
        actions: actions,
        automaticallyImplyLeading: false,
        leading: showLeading
            ? BackButton(
                color: backButtonColor,
                onPressed: backHandler ?? Navigator.of(context).pop)
            : null,
        backgroundColor: backgroundColor,
        elevation: toolbarElevation,
      );
    }
  }

  static Widget buildAdaptiveFilledButton(BuildContext context, String label,
      {double? fontSize,
      Color backgroundColor = ColorUtil.primaryColorDark,
      Color backgroundColorDisabled = ColorUtil.lightGrey,
      Color fontColor = Colors.white,
      Color fontColorDisabled = Colors.grey,
      double borderRadius = 4.0,
      double borderWidth = 0.0,
      Color borderColor = Colors.grey,
      double verticalPadding = 0.0,
      double horizontalPadding = 0.0,
      double? cupertinoOverrideBorderMargin,
      TextDecoration textDecoration = TextDecoration.none,
      TextAlign? textAlign,
      FontWeight? fontWeight,
      double? elevation, // For material button
      double minimumSizeCupertino =
          kMinInteractiveDimensionCupertino, // For cupertino button
      Size? minimumSizeMaterial, // For material button
      MaterialTapTargetSize? tapTargetSize, // For material button
      void Function()? onPressed}) {
    if (isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderWidth > 0
              ? Border.all(width: borderWidth, color: borderColor)
              : null,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        padding: borderWidth > 0
            ? EdgeInsets.all(cupertinoOverrideBorderMargin ?? 0.0)
            : null,
        child: TapDebouncer(
            cooldown: onPressed != null
                ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
                : null,
            onTap: onPressed != null ? () async => onPressed() : null,
            builder: (BuildContext context, TapDebouncerFunc? onPressed) {
              return CupertinoButton(
                onPressed: onPressed,
                minSize: minimumSizeCupertino,
                child: Text(label,
                    textAlign: textAlign,
                    style: Theme.of(context).textTheme.button?.copyWith(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: onPressed != null ? fontColor : Colors.grey,
                        decoration: textDecoration)),
                color: backgroundColor,
                disabledColor: backgroundColorDisabled,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              );
            }),
      );
    } else {
      return TapDebouncer(
        cooldown: onPressed != null
            ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
            : null,
        onTap: onPressed != null ? () async => onPressed() : null,
        builder: (BuildContext context, TapDebouncerFunc? onPressed) {
          return ElevatedButton(
            onPressed: onPressed,
            child: Text(label, textAlign: textAlign),
            style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: fontColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        side: borderWidth > 0
                            ? BorderSide(width: borderWidth, color: borderColor)
                            : BorderSide.none),
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPadding,
                        horizontal: horizontalPadding),
                    elevation: elevation,
                    minimumSize: minimumSizeMaterial,
                    tapTargetSize: tapTargetSize,
                    textStyle: Theme.of(context).textTheme.button?.copyWith(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        decoration: textDecoration))
                .copyWith(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(MaterialState.disabled)) {
                    return backgroundColorDisabled;
                  }
                  return backgroundColor;
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(MaterialState.disabled)) {
                    return fontColorDisabled;
                  }
                  return fontColor;
                },
              ),
            ),
          );
        },
      );
    }
  }

  static Widget buildAdaptiveFlatButton(BuildContext context, String label,
      {double? fontSize,
      Color fontColor = ColorUtil.primaryColor,
      double verticalPadding = 0.0,
      double horizontalPadding = 0.0,
      TextDecoration textDecoration = TextDecoration.none,
      TextAlign? textAlign,
      FontWeight? fontWeight,
      int? maxLines,
      TextOverflow? textOverflow,
      double? elevation, // For material button
      double minimumSizeCupertino =
          kMinInteractiveDimensionCupertino, // For cupertino button
      Size? minimumSizeMaterial, // For material button
      MaterialTapTargetSize? tapTargetSize, // For material button
      void Function()? onPressed}) {
    if (isIOS) {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return CupertinoButton(
              onPressed: onPressed,
              minSize: minimumSizeCupertino,
              child: Text(label,
                  textAlign: textAlign,
                  maxLines: maxLines,
                  overflow: textOverflow,
                  style: Theme.of(context).textTheme.button?.copyWith(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: onPressed != null ? fontColor : Colors.grey,
                      decoration: textDecoration)),
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
            );
          });
    } else {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return TextButton(
              onPressed: onPressed,
              child: Text(label,
                  textAlign: textAlign,
                  maxLines: maxLines,
                  overflow: textOverflow),
              style: TextButton.styleFrom(
                  foregroundColor: fontColor,
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: horizontalPadding),
                  elevation: elevation,
                  minimumSize: minimumSizeMaterial,
                  tapTargetSize: tapTargetSize,
                  textStyle: Theme.of(context).textTheme.button?.copyWith(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: fontColor,
                      decoration: textDecoration)),
            );
          });
    }
  }

  static Widget buildAdaptiveFilledButtonWithIcon(
      BuildContext context, String label, IconData icon,
      {bool invertIconPosition = false,
      double? fontSize,
      Color backgroundColor = ColorUtil.primaryColor,
      Color backgroundColorDisabled = ColorUtil.lightGrey,
      Color fontColor = Colors.white,
      Color fontColorDisabled = Colors.grey,
      Color iconColor = ColorUtil.primaryColor,
      double? iconSize,
      double borderRadius = 4.0,
      double borderWidth = 0.0,
      Color borderColor = Colors.grey,
      double verticalPadding = 0.0,
      double horizontalPadding = 0.0,
      double? cupertinoOverrideBorderMargin,
      TextDecoration textDecoration = TextDecoration.none,
      TextAlign? textAlign,
      FontWeight? fontWeight,
      double? elevation, // For material button
      double minimumSizeCupertino =
          kMinInteractiveDimensionCupertino, // For cupertino button
      Size? minimumSizeMaterial, // For material button
      MaterialTapTargetSize? tapTargetSize, // For material button
      void Function()? onPressed}) {
    if (isIOS) {
      return Container(
        decoration: BoxDecoration(
          border: borderWidth > 0
              ? Border.all(width: borderWidth, color: borderColor)
              : null,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        padding: borderWidth > 0
            ? EdgeInsets.all(cupertinoOverrideBorderMargin ?? 0.0)
            : null,
        child: TapDebouncer(
            cooldown: onPressed != null
                ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
                : null,
            onTap: onPressed != null ? () async => onPressed() : null,
            builder: (BuildContext context, TapDebouncerFunc? onPressed) {
              return CupertinoButton(
                onPressed: onPressed,
                minSize: minimumSizeCupertino,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!invertIconPosition)
                      Icon(icon,
                          color:
                              onPressed != null ? iconColor : fontColorDisabled,
                          size: iconSize),
                    if (!invertIconPosition) const SizedBox(width: 8.0),
                    Flexible(
                      child: FittedBox(
                        child: Text(label,
                            textAlign: textAlign,
                            style: Theme.of(context).textTheme.button?.copyWith(
                                fontSize: fontSize,
                                fontWeight: fontWeight,
                                color:
                                    onPressed != null ? fontColor : Colors.grey,
                                decoration: textDecoration),
                            textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false)),
                      ),
                    ),
                    if (invertIconPosition) const SizedBox(width: 8.0),
                    if (invertIconPosition)
                      Icon(icon,
                          color:
                              onPressed != null ? iconColor : fontColorDisabled,
                          size: iconSize),
                  ],
                ),
                color: backgroundColor,
                disabledColor: backgroundColorDisabled,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              );
            }),
      );
    } else {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return ElevatedButton(
              onPressed: onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!invertIconPosition)
                    Icon(icon,
                        color:
                            onPressed != null ? iconColor : fontColorDisabled,
                        size: iconSize),
                  if (!invertIconPosition) const SizedBox(width: 8.0),
                  Flexible(
                      child: FittedBox(
                          child: Text(label,
                              textAlign: textAlign,
                              textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false)))),
                  if (invertIconPosition) const SizedBox(width: 8.0),
                  if (invertIconPosition)
                    Icon(icon,
                        color:
                            onPressed != null ? iconColor : fontColorDisabled,
                        size: iconSize),
                ],
              ),
              style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: fontColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          side: borderWidth > 0
                              ? BorderSide(
                                  width: borderWidth, color: borderColor)
                              : BorderSide.none),
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                          horizontal: horizontalPadding),
                      elevation: elevation,
                      minimumSize: minimumSizeMaterial,
                      tapTargetSize: tapTargetSize,
                      textStyle: Theme.of(context).textTheme.button?.copyWith(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          decoration: textDecoration))
                  .copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.disabled)) {
                      return backgroundColorDisabled;
                    }
                    return backgroundColor;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.disabled)) {
                      return fontColorDisabled;
                    }
                    return fontColor;
                  },
                ),
              ),
            );
          });
    }
  }

  static Widget buildAdaptiveFlatButtonWithIcon(
      BuildContext context, String label, IconData icon,
      {bool invertIconPosition = false,
      double? fontSize,
      Color fontColor = ColorUtil.primaryColor,
      Color disabledFontColor = Colors.grey,
      Color? iconColor,
      double? iconSize,
      double verticalPadding = 0.0,
      double horizontalPadding = 0.0,
      double iconSpacing = 4.0,
      double? iconRotation,
      TextDecoration textDecoration = TextDecoration.none,
      TextAlign? textAlign,
      FontWeight? fontWeight,
      double? elevation, // For material button
      double minimumSizeCupertino =
          kMinInteractiveDimensionCupertino, // For cupertino button
      Size? minimumSizeMaterial, // For material button
      MaterialTapTargetSize? tapTargetSize, // For material button
      void Function()? onPressed}) {
    Widget iconWidget = Icon(icon, color: iconColor, size: iconSize);
    if (iconRotation != null) {
      iconWidget = rotateChild(iconRotation,
          child: iconWidget, iconColor: iconColor ?? ColorUtil.primaryColor);
    }
    if (isIOS) {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return CupertinoButton(
              onPressed: onPressed,
              minSize: minimumSizeCupertino,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!invertIconPosition) iconWidget,
                  if (!invertIconPosition) SizedBox(width: iconSpacing),
                  Text(label,
                      textAlign: textAlign,
                      style: Theme.of(context).textTheme.button?.copyWith(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: onPressed != null ? fontColor : disabledFontColor,
                          decoration: textDecoration),
                      textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false)),
                  if (invertIconPosition) SizedBox(width: iconSpacing),
                  if (invertIconPosition) iconWidget,
                ],
              ),
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
            );
          });
    } else {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return TextButton(
              onPressed: onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!invertIconPosition) iconWidget,
                  if (!invertIconPosition) SizedBox(width: iconSpacing),
                  Text(
                    label,
                    textAlign: textAlign,
                    textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false),
                  ),
                  if (invertIconPosition) SizedBox(width: iconSpacing),
                  if (invertIconPosition) iconWidget,
                ],
              ),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: horizontalPadding),
                  elevation: elevation,
                  minimumSize: minimumSizeMaterial,
                  tapTargetSize: tapTargetSize,
                  foregroundColor: fontColor,
                  disabledForegroundColor: disabledFontColor,
                  textStyle: Theme.of(context).textTheme.button?.copyWith(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: fontColor,
                      decoration: textDecoration)),
            );
          });
    }
  }

  static Widget rotateChild(double rotation,
      {Widget? child, Color iconColor = ColorUtil.primaryColor}) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(Icons.navigation_outlined, color: iconColor),
    );
  }

  static Widget buildAdaptiveIconButton(BuildContext context, IconData icon,
      {Color iconColor = Colors.black,
      double? iconSize,
      EdgeInsets? padding,
      void Function()? onPressed}) {
    if (isIOS) {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return CupertinoButton(
                onPressed: onPressed,
                padding: padding,
                child: Icon(icon, color: iconColor, size: iconSize));
          });
    } else {
      return TapDebouncer(
          cooldown: onPressed != null
              ? const Duration(milliseconds: debounceCoolDownTimeInMillis)
              : null,
          onTap: onPressed != null ? () async => onPressed() : null,
          builder: (BuildContext context, TapDebouncerFunc? onPressed) {
            return IconButton(
                onPressed: onPressed,
                padding: padding ?? const EdgeInsets.all(8.0),
                icon: Icon(icon, color: iconColor, size: iconSize));
          });
    }
  }

  static Widget buildPlatformScrollBar(Widget child,
      {ScrollController? scrollController, bool isAlwaysShown = true}) {
    if (isIOS) {
      return CupertinoScrollbar(
          controller: scrollController,
          thumbVisibility: isAlwaysShown,
          child: child);
    } else {
      return Scrollbar(
          controller: scrollController,
          thumbVisibility: isAlwaysShown,
          child: child);
    }
  }

  static Future<T?> showAdaptiveDialog<T>(
    BuildContext ctx, {
    required WidgetBuilder builder,
    bool useRootNavigator = true,
    bool barrierDismissible = false,
  }) {
    if (isIOS) {
      return showCupertinoDialog<T>(
          context: ctx,
          useRootNavigator: useRootNavigator,
          builder: (context) {
            return WillPopScope(
                onWillPop: () async => barrierDismissible,
                child: builder(context));
          },
          barrierDismissible: barrierDismissible);
    } else {
      return showDialog<T>(
          context: ctx,
          useRootNavigator: useRootNavigator,
          builder: (context) {
            return WillPopScope(
                onWillPop: () async => barrierDismissible,
                child: builder(context));
          },
          barrierDismissible: barrierDismissible);
    }
  }

  static Widget leftRightActionButtons(
      BuildContext context,
      String? leftButtonText,
      String? rightButtonText,
      Color rightButtonColor,
      Color rightButtonTextColor,
      VoidCallback? rightAction,
      VoidCallback? leftAction,
      {bool smallRightText = false}) {
    return Column(
      children: [
        const Divider(height: 1.0, color: Colors.grey),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (leftButtonText != null)
                buildAdaptiveFlatButtonWithIcon(
                    context, leftButtonText, Icons.arrow_back_ios,
                    onPressed: leftAction ?? Navigator.of(context).pop,
                    fontColor: Colors.black,
                    iconColor: Colors.black,
                    fontSize: 16.0,
                    iconSize: 20.0,
                    iconSpacing: 2.0),
              if (leftButtonText != null) const SizedBox(width: 8.0),
              if (leftButtonText == null)
                const Expanded(child: SizedBox.shrink()),
              if (rightButtonText != null)
                Flexible(
                  child: buildAdaptiveFilledButtonWithIcon(
                    context,
                    rightButtonText,
                    Icons.arrow_forward_ios,
                    onPressed: rightAction,
                    fontColor: rightButtonTextColor,
                    backgroundColor: rightButtonColor,
                    iconColor: rightButtonTextColor,
                    fontColorDisabled: Colors.black45,
                    fontSize: smallRightText ? 12.0 : 16.0,
                    iconSize: 20.0,
                    invertIconPosition: true,
                    horizontalPadding: 16.0,
                    verticalPadding: 8.0,
                    minimumSizeCupertino: 38.0,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget label(String text,
      {FontWeight fontWeight = FontWeight.bold,
      Color? color = Colors.black,
      double fontSize = 14.0,
      int? maxLines,
      double lineSpacing = 1.0,
      TextAlign textAlign = TextAlign.left,
      TextOverflow textOverflow = TextOverflow.visible,
      Alignment alignmentView = Alignment.topLeft}) {
    return Align(
      alignment: alignmentView,
      child: Text(
        text,
        textAlign: textAlign,
        overflow: textOverflow,
        maxLines: maxLines,
        style: TextStyle(
            height: lineSpacing,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: 'GOTHAM'),
      ),
    );
  }

  static ButtonStyle buttonStyle(
      {Color? backgroudColor = Colors.black,
      double? radius,
      Color? borderColor,
      double? elevation,
      double borderWidth = 1.0,
      EdgeInsets? padding}) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(padding),
      alignment: Alignment.center,
      backgroundColor: MaterialStateProperty.all(backgroudColor),
      elevation: MaterialStateProperty.all(elevation),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(radius ?? 0),
          ),
          side: (borderColor != null)
              ? BorderSide(color: borderColor, width: borderWidth)
              : const BorderSide(),
        ),
      ),
    );
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  // Meet Truck
  static TextStyle? themeAppBarSubtitleTextStyle1(BuildContext context) =>
      Theme.of(context).appBarTheme.textTheme?.subtitle1;

  static TextStyle? themeSubtitleTextStyle2(BuildContext context) =>
      Theme.of(context).textTheme.subtitle2;

  static TextStyle? themeHeadlineTextStyle1(BuildContext context) =>
      Theme.of(context).textTheme.headline1;

  static TextStyle? themeSubtitleTextStyle1(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1; */
}
