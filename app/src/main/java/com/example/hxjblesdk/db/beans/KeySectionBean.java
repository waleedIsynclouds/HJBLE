package com.example.hxjblesdk.db.beans;

import com.chad.library.adapter.base.entity.JSectionEntity;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;
import com.example.hxjblinklibrary.blinkble.profile.data.common.KeyType;

public class KeySectionBean extends JSectionEntity {


    private int keyType;
    private LockKeyResult lockKeyResult;

    public KeySectionBean(LockKeyResult lockKeyResult) {
        this.lockKeyResult = lockKeyResult;
    }

    public KeySectionBean(int keyType) {
        this.keyType = keyType;
    }

    @Override
    public boolean isHeader() {
        return lockKeyResult == null;
    }


    public int getKeyType() {
        return keyType;
    }

    public void setKeyType(int keyType) {
        this.keyType = keyType;
    }

    public LockKeyResult getLockKeyResult() {
        return lockKeyResult;
    }

    public void setLockKeyResult(LockKeyResult lockKeyResult) {
        this.lockKeyResult = lockKeyResult;
    }

    public String getHeaderStr() {
        switch (keyType) {
            case KeyType.FINGER:
                return "FINGER";
            case KeyType.PASSWORD:
                return "PASSWORD";
            case KeyType.CARD:
                return "CARD";
            case KeyType.REMOTE:
                return "REMOTE";
            default:
                return "OTHER";
        }
    }
}
