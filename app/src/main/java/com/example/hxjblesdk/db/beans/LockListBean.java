package com.example.hxjblesdk.db.beans;

import android.os.Parcel;
import android.os.Parcelable;

import com.example.hxjblesdk.db.lock.Lock;

public class LockListBean implements Parcelable {
    Lock lock;
    boolean isSelect = false;

    public LockListBean(Lock lock) {
        this.lock = lock;
    }

    protected LockListBean(Parcel in) {
        lock = in.readParcelable(Lock.class.getClassLoader());
        isSelect = in.readByte() != 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(lock, flags);
        dest.writeByte((byte) (isSelect ? 1 : 0));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<LockListBean> CREATOR = new Creator<LockListBean>() {
        @Override
        public LockListBean createFromParcel(Parcel in) {
            return new LockListBean(in);
        }

        @Override
        public LockListBean[] newArray(int size) {
            return new LockListBean[size];
        }
    };

    public Lock getLock() {
        return lock;
    }

    public void setLock(Lock lock) {
        this.lock = lock;
    }

    public boolean isSelect() {
        return isSelect;
    }

    public void setSelect(boolean select) {
        isSelect = select;
    }
}
