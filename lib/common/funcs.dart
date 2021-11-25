import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 文字提示
void showToast(
  String text, {
  gravity = ToastGravity.CENTER,
  toastLength = Toast.LENGTH_SHORT,
}) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: toastLength,
    gravity: gravity,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey[600],
    fontSize: 16.0,
  );
}

/// 提示加载中
void showLoading(context, [String text = 'Loading...']) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.0),
            boxShadow: const [
              //阴影
              BoxShadow(
                color: Colors.black12,
                //offset: Offset(2.0,2.0),
                blurRadius: 10.0,
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 120, minWidth: 180),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 关闭加载中提示
void hideLoading(BuildContext context) {
  Navigator.of(context).pop();
}
