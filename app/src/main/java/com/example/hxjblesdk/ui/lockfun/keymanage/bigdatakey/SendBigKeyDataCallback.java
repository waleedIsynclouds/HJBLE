package com.example.hxjblesdk.ui.lockfun.keymanage.bigdatakey;

import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;

public interface SendBigKeyDataCallback {
    void onCallback(int statusCode, String reason, int phase, double progress, LockKeyResult keyObj);
}
