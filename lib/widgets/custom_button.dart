// Padding(
// padding:  EdgeInsets.symmetric(vertical: 20.0.h),
// child: GestureDetector(
// onTap: () {
// _submit(context);
// },
// child: Container(
// height: 60.h,
// width: MediaQuery.of(context).size.width - 30,
// decoration: BoxDecoration(
// color: Colors.yellow.shade100,
// border:
// Border.all(color: Colors.black, width: 3)),
// child: Center(
// child: Padding(
// padding: const EdgeInsets.all(10.0),
// child: Text(
// _authMode == AuthMode.login
// ? AppLocalizations.of(context)!
// .login_button_label
//     : AppLocalizations.of(context)!
// .signup_button_label,
// style: Theme.of(context)
// .textTheme
//     .bodyMedium
//     ?.copyWith(color: Colors.black,fontWeight: FontWeight.w600,fontSize:17.sp )),
// ),
// ),
// ),
// ),
// )