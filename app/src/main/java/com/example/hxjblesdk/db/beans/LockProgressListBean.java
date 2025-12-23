package com.example.hxjblesdk.db.beans;

import android.os.Parcel;
import android.os.Parcelable;

import com.example.hxjblesdk.db.lock.Lock;

public class LockProgressListBean implements Parcelable {
    Lock lock;
    int progress = 0;
    int oadState = 0; // 0: Not started, 1: Upgrading, 2: Upgrade successful, 3: Upgrade failed

    public LockProgressListBean(Lock lock) {
        this.lock = lock;
    }

    protected LockProgressListBean(Parcel in) {
        lock = in.readParcelable(Lock.class.getClassLoader());
        progress = in.readInt();
        oadState = in.readInt();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(lock, flags);
        dest.writeInt(progress);
        dest.writeInt(oadState);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<LockProgressListBean> CREATOR = new Creator<LockProgressListBean>() {
        @Override
        public LockProgressListBean createFromParcel(Parcel in) {
            return new LockProgressListBean(in);
        }

        @Override
        public LockProgressListBean[] newArray(int size) {
            return new LockProgressListBean[size];
        }
    };

    public Lock getLock() {
        return lock;
    }

    public void setLock(Lock lock) {
        this.lock = lock;
    }

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }

    public int getOadState() {
        return oadState;
    }

    public void setOadState(int oadState) {
        this.oadState = oadState;
    }


}
