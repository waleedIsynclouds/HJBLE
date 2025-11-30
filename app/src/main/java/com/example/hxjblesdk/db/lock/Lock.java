package com.example.hxjblesdk.db.lock;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "lock_table")
public class Lock implements Parcelable {

    @PrimaryKey
    @NonNull
    @ColumnInfo(name = "lock")
    private String lockMac;
    private String lockName;
    private int deviceType;
    private long projectID;
    private String hardWareVer;
    private String softWareVer;
    private int protocolVer;
    private int lockFunctionType;
    private int maxVolume;
    private int maxUserNum;
    private int menuFeature;
    private int rFModuleType;
    private String rFModuleMac;

    private long lockSystemFunction;

    private long lockNetSystemFunction;

    private String adminAuthCode;

    private String aesKey;

    public Lock() {
    }

    protected Lock(Parcel in) {
        lockMac = in.readString();
        lockName = in.readString();
        deviceType = in.readInt();
        projectID = in.readLong();
        hardWareVer = in.readString();
        softWareVer = in.readString();
        protocolVer = in.readInt();
        lockFunctionType = in.readInt();
        maxVolume = in.readInt();
        maxUserNum = in.readInt();
        menuFeature = in.readInt();
        rFModuleType = in.readInt();
        rFModuleMac = in.readString();
        lockSystemFunction = in.readLong();
        lockNetSystemFunction =in.readLong();
        adminAuthCode = in.readString();
        aesKey = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(lockMac);
        dest.writeString(lockName);
        dest.writeInt(deviceType);
        dest.writeLong(projectID);
        dest.writeString(hardWareVer);
        dest.writeString(softWareVer);
        dest.writeInt(protocolVer);
        dest.writeInt(lockFunctionType);
        dest.writeInt(maxVolume);
        dest.writeInt(maxUserNum);
        dest.writeInt(menuFeature);
        dest.writeInt(rFModuleType);
        dest.writeString(rFModuleMac);
        dest.writeLong(lockSystemFunction);
        dest.writeLong(lockNetSystemFunction);
        dest.writeString(adminAuthCode);
        dest.writeString(aesKey);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<Lock> CREATOR = new Creator<Lock>() {
        @Override
        public Lock createFromParcel(Parcel in) {
            return new Lock(in);
        }

        @Override
        public Lock[] newArray(int size) {
            return new Lock[size];
        }
    };

    @NonNull
    public String getLockMac() {
        return lockMac;
    }

    public String getLockName() {
        return lockName;
    }

    public int getDeviceType() {
        return deviceType;
    }

    public long getProjectID() {
        return projectID;
    }

    public String getHardWareVer() {
        return hardWareVer;
    }

    public String getSoftWareVer() {
        return softWareVer;
    }

    public int getProtocolVer() {
        return protocolVer;
    }

    public int getLockFunctionType() {
        return lockFunctionType;
    }

    public int getMaxVolume() {
        return maxVolume;
    }

    public int getMaxUserNum() {
        return maxUserNum;
    }

    public int getMenuFeature() {
        return menuFeature;
    }

    public int getRFModuleType() {
        return rFModuleType;
    }

    public String getRFModuleMac() {
        return rFModuleMac;
    }

    public void setLockMac(@NonNull String lockMac) {
        this.lockMac = lockMac;
    }

    public void setLockName(String lockName) {
        this.lockName = lockName;
    }

    public void setDeviceType(int deviceType) {
        this.deviceType = deviceType;
    }

    public void setProjectID(long projectID) {
        this.projectID = projectID;
    }

    public void setHardWareVer(String hardWareVer) {
        this.hardWareVer = hardWareVer;
    }

    public void setSoftWareVer(String softWareVer) {
        this.softWareVer = softWareVer;
    }

    public void setProtocolVer(int protocolVer) {
        this.protocolVer = protocolVer;
    }

    public void setLockFunctionType(int lockFunctionType) {
        this.lockFunctionType = lockFunctionType;
    }

    public void setMaxVolume(int maxVolume) {
        this.maxVolume = maxVolume;
    }

    public void setMaxUserNum(int maxUserNum) {
        this.maxUserNum = maxUserNum;
    }

    public void setMenuFeature(int menuFeature) {
        this.menuFeature = menuFeature;
    }

    public void setRFModuleType(int rFModuleType) {
        this.rFModuleType = rFModuleType;
    }

    public void setRFModuleMac(String rFModuleMac) {
        this.rFModuleMac = rFModuleMac;
    }

    public long getLockSystemFunction() {
        return lockSystemFunction;
    }

    public void setLockSystemFunction(long lockSystemFunction) {
        this.lockSystemFunction = lockSystemFunction;
    }

    public long getLockNetSystemFunction() {
        return lockNetSystemFunction;
    }

    public void setLockNetSystemFunction(long lockNetSystemFunction) {
        this.lockNetSystemFunction = lockNetSystemFunction;
    }

    public String getAdminAuthCode() {
        return adminAuthCode;
    }

    public void setAdminAuthCode(String adminAuthCode) {
        this.adminAuthCode = adminAuthCode;
    }

    public String getAesKey() {
        return aesKey;
    }

    public void setAesKey(String aesKey) {
        this.aesKey = aesKey;
    }

    public static final class LockBuilder {
        private String lockMac;
        private String lockName;
        private int deviceType;
        private long projectID;
        private String hardWareVer;
        private String softWareVer;
        private int protocolVer;
        private int lockFunctionType;
        private int maxVolume;
        private int maxUserNum;
        private int menuFeature;
        private int rFModuleType;
        private String rFModuleMac;

        private long lockSystemFunction;

        private long lockNetSystemFunction;

        private String adminAuthCode;

        private String aesKey;

        private LockBuilder() {
        }

        public static LockBuilder aLock() {
            return new LockBuilder();
        }

        public LockBuilder lockMac(String lockMac) {
            this.lockMac = lockMac;
            return this;
        }

        public LockBuilder lockName(String lockName) {
            this.lockName = lockName;
            return this;
        }

        public LockBuilder deviceType(int deviceType) {
            this.deviceType = deviceType;
            return this;
        }

        public LockBuilder projectID(long projectID) {
            this.projectID = projectID;
            return this;
        }

        public LockBuilder hardWareVer(String hardWareVer) {
            this.hardWareVer = hardWareVer;
            return this;
        }

        public LockBuilder softWareVer(String softWareVer) {
            this.softWareVer = softWareVer;
            return this;
        }

        public LockBuilder protocolVer(int protocolVer) {
            this.protocolVer = protocolVer;
            return this;
        }

        public LockBuilder lockFunctionType(int lockFunctionType) {
            this.lockFunctionType = lockFunctionType;
            return this;
        }

        public LockBuilder maxVolume(int maxVolume) {
            this.maxVolume = maxVolume;
            return this;
        }

        public LockBuilder maxUserNum(int maxUserNum) {
            this.maxUserNum = maxUserNum;
            return this;
        }

        public LockBuilder menuFeature(int menuFeature) {
            this.menuFeature = menuFeature;
            return this;
        }

        public LockBuilder rFModuleType(int rFModuleType) {
            this.rFModuleType = rFModuleType;
            return this;
        }

        public LockBuilder rFModuleMac(String rFModuleMac) {
            this.rFModuleMac = rFModuleMac;
            return this;
        }

        public LockBuilder lockSystemFunction(long lockSystemFunction) {
            this.lockSystemFunction = lockSystemFunction;
            return this;
        }

        public LockBuilder lockNetSystemFunction(long lockNetSystemFunction) {
            this.lockNetSystemFunction = lockNetSystemFunction;
            return this;
        }

        public LockBuilder adminAuthCode(String adminAuthCode) {
            this.adminAuthCode = adminAuthCode;
            return this;
        }

        public LockBuilder aesKey(String aesKey) {
            this.aesKey = aesKey;
            return this;
        }

        public Lock build() {
            Lock lock = new Lock();
            lock.lockName = this.lockName;
            lock.deviceType = this.deviceType;
            lock.hardWareVer = this.hardWareVer;
            lock.softWareVer = this.softWareVer;
            lock.rFModuleMac = this.rFModuleMac;
            lock.lockMac = this.lockMac;
            lock.protocolVer = this.protocolVer;
            lock.projectID = this.projectID;
            lock.maxVolume = this.maxVolume;
            lock.rFModuleType = this.rFModuleType;
            lock.maxUserNum = this.maxUserNum;
            lock.menuFeature = this.menuFeature;
            lock.lockFunctionType = this.lockFunctionType;
            lock.lockSystemFunction = this.lockSystemFunction;
            lock.lockNetSystemFunction = this.lockNetSystemFunction;
            lock.adminAuthCode = this.adminAuthCode;
            lock.aesKey = this.aesKey;
            return lock;
        }
    }
}