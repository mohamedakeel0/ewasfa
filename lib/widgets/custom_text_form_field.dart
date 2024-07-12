
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
   CustomTextFormField({
    super.key,
     this.controller,
    this.hintText,
    this.labelText,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines,
    this.fillColor,
    this.textInputType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.style,
    this.focusNode,
    this.textCapitalization,
    this.onSaved,
    this.enabledBorder,
    this.enabled,
    this.maxLength,
    this.context,
    this.cursorColor,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final   Color? cursorColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final Color? fillColor;
  final InputBorder? enabledBorder;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextStyle? style;
  final int?   maxLength;
  final FocusNode? focusNode;
  final BuildContext? context;
   bool? enabled;
  TextCapitalization? textCapitalization  ;
  @override
  Widget build(BuildContext context) {
    return //Directionality(textDirection: TextDirection.ltr,
        TextFormField(  cursorColor:cursorColor,
          obscuringCharacter: '●',
      focusNode: focusNode,
      controller: controller,maxLength:maxLength ,
      onChanged: onChanged,onSaved:onSaved ,
      validator: validator,
      textInputAction: textInputAction ?? TextInputAction.done,
      textAlignVertical: TextAlignVertical.center,
      cursorOpacityAnimates: true,
      enabled: enabled,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      obscureText: obscureText,textCapitalization: textCapitalization??TextCapitalization.none,
      style: style ??
          Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(
              fontSize:14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
      keyboardType: textInputType ?? TextInputType.name,
      decoration: InputDecoration(
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 2.5.sp / 2)),
        contentPadding: EdgeInsets.symmetric(
            vertical:20.sp, horizontal:10.sp),
        fillColor: fillColor ?? Colors.white,
        filled: true,
        hintStyle: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(
                fontSize:14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black),
        labelStyle: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
                color: Colors.grey),
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines ?? 1,
      //  ),
    );
  }
}
