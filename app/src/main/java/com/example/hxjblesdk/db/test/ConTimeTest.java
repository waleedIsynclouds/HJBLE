package com.example.hxjblesdk.db.test;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "contime_test_table")
public class ConTimeTest implements Parcelable {

    @PrimaryKey
    @NonNull
    private int id;
    private String lockMac;
    private String lockName;
    private int deviceType;
    private long projectID;
    private String hardWareVer;
    private String softWareVer;
    private long connectTime;
    private long openTime;

    public ConTimeTest() {

    }


    protected ConTimeTest(Parcel in) {
        id = in.readInt();
        lockMac = in.readString();
        lockName = in.readString();
        deviceType = in.readInt();
        projectID = in.readLong();
        hardWareVer = in.readString();
        softWareVer = in.readString();
        connectTime = in.readLong();
        openTime = in.readLong();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(id);
        dest.writeString(lockMac);
        dest.writeString(lockName);
        dest.writeInt(deviceType);
        dest.writeLong(projectID);
        dest.writeString(hardWareVer);
        dest.writeString(softWareVer);
        dest.writeLong(connectTime);
        dest.writeLong(openTime);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<ConTimeTest> CREATOR = new Creator<ConTimeTest>() {
        @Override
        public ConTimeTest createFromParcel(Parcel in) {
            return new ConTimeTest(in);
        }

        @Override
        public ConTimeTest[] newArray(int size) {
            return new ConTimeTest[size];
        }
    };

    @NonNull
    public String getLockMac() {
        return lockMac;
    }

    public void setLockMac(@NonNull String lockMac) {
        this.lockMac = lockMac;
    }

    public String getLockName() {
        return lockName;
    }

    public void setLockName(String lockName) {
        this.lockName = lockName;
    }

    public int getDeviceType() {
        return deviceType;
    }

    public void setDeviceType(int deviceType) {
        this.deviceType = deviceType;
    }

    public long getProjectID() {
        return projectID;
    }

    public void setProjectID(long projectID) {
        this.projectID = projectID;
    }

    public String getHardWareVer() {
        return hardWareVer;
    }

    public void setHardWareVer(String hardWareVer) {
        this.hardWareVer = hardWareVer;
    }

    public String getSoftWareVer() {
        return softWareVer;
    }

    public void setSoftWareVer(String softWareVer) {
        this.softWareVer = softWareVer;
    }

    public long getConnectTime() {
        return connectTime;
    }

    public void setConnectTime(long connectTime) {
        this.connectTime = connectTime;
    }

    public long getOpenTime() {
        return openTime;
    }

    public void setOpenTime(long openTime) {
        this.openTime = openTime;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }


    public static final class ConTimeTestBuilder {
        private int id;
        private String lockMac;
        private String lockName;
        private int deviceType;
        private long projectID;
        private String hardWareVer;
        private String softWareVer;
        private long connectTime;
        private long openTime;

        private ConTimeTestBuilder() {
        }

        public static ConTimeTestBuilder aConTimeTest() {
            return new ConTimeTestBuilder();
        }

        public ConTimeTestBuilder withId(int id) {
            this.id = id;
            return this;
        }

        public ConTimeTestBuilder withLockMac(String lockMac) {
            this.lockMac = lockMac;
            return this;
        }

        public ConTimeTestBuilder withLockName(String lockName) {
            this.lockName = lockName;
            return this;
        }

        public ConTimeTestBuilder withDeviceType(int deviceType) {
            this.deviceType = deviceType;
            return this;
        }

        public ConTimeTestBuilder withProjectID(long projectID) {
            this.projectID = projectID;
            return this;
        }

        public ConTimeTestBuilder withHardWareVer(String hardWareVer) {
            this.hardWareVer = hardWareVer;
            return this;
        }

        public ConTimeTestBuilder withSoftWareVer(String softWareVer) {
            this.softWareVer = softWareVer;
            return this;
        }

        public ConTimeTestBuilder withConnectTime(long connectTime) {
            this.connectTime = connectTime;
            return this;
        }

        public ConTimeTestBuilder withOpenTime(long openTime) {
            this.openTime = openTime;
            return this;
        }

        public ConTimeTest build() {
            ConTimeTest conTimeTest = new ConTimeTest();
            conTimeTest.setId(id);
            conTimeTest.setLockMac(lockMac);
            conTimeTest.setLockName(lockName);
            conTimeTest.setDeviceType(deviceType);
            conTimeTest.setProjectID(projectID);
            conTimeTest.setHardWareVer(hardWareVer);
            conTimeTest.setSoftWareVer(softWareVer);
            conTimeTest.setConnectTime(connectTime);
            conTimeTest.setOpenTime(openTime);
            return conTimeTest;
        }
    }
}