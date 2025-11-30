package com.example;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import com.kongzue.dialogx.DialogX;
import com.xiasuhuei321.loadingdialog.manager.StyleManager;
import com.xiasuhuei321.loadingdialog.view.LoadingDialog;

public class HxjApp extends Application {
    private static HxjApp INSTANCE;

    public static HxjApp getInstance() {
        return INSTANCE;
    }

    public static Context getAppContext() {
        return INSTANCE.getApplicationContext();
    }

    @Override
    public void onCreate() {
        super.onCreate();
        INSTANCE = this;
        DialogX.init(this);
        initThirdSdk();
    }

    private void initThirdSdk() {
        initLoadingDialog();
    }

    private void initLoadingDialog() {
        StyleManager styleManager = new StyleManager();
        styleManager.Anim(false).repeatTime(0).contentSize(-1).intercept(true);
        LoadingDialog.initStyle(styleManager);
    }

}
