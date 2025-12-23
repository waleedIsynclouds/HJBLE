package com.example.utils;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import com.example.HxjApp;

public class HXToast {

    public static final String TAG = HXToast.class.getSimpleName();

    private static Toast mToast;

    private static Handler mHandler = new Handler(Looper.getMainLooper());

    public static Handler getMainHandler() {
        return mHandler;
    }

    /**
     * Can be called in a child thread
     *
     * @param msg toast message content
     */
    public static void show(final String msg) {
        if (msg != null && msg.length() > 0) {
            runOnUIThread(new Runnable() {
                @Override
                public void run() {
                    if (mToast == null) {
                        mToast = Toast.makeText(HxjApp.getAppContext(), msg, Toast.LENGTH_SHORT);
                    }else {
                        mToast.cancel();
                        mToast = Toast.makeText(HxjApp.getAppContext(), msg, Toast.LENGTH_SHORT);
                    }
                    mToast.setText(msg);
                    Log.d(TAG, "Toast: " + msg);
                    mToast.show();
                }
            });
        }
    }


    public static void runOnUIThread(Runnable run) {
        if (isUIThread()) {
            run.run();
        } else {
            mHandler.post(run);
        }
    }

    public static boolean isUIThread() {
        return Looper.getMainLooper() == Looper.myLooper();
    }

}
