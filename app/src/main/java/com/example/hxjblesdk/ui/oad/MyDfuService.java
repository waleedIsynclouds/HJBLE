package com.example.hxjblesdk.ui.oad;

import android.app.Activity;

import androidx.annotation.Nullable;

import no.nordicsemi.android.dfu.DfuBaseService;

public class MyDfuService extends DfuBaseService {
    @Nullable
    @Override
    protected Class<? extends Activity> getNotificationTarget() {
        return null;
    }
}
