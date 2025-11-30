package com.example.hxjblesdk.db.beans;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public class LockFunMenuBean {
    int type;
    String name;
    int iconResId;

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getIconResId() {
        return iconResId;
    }

    public void setIconResId(int iconResId) {
        this.iconResId = iconResId;
    }

    public LockFunMenuBean(int type, String name, int iconResId) {
        this.type = type;
        this.name = name;
        this.iconResId = iconResId;
    }

    public static final class MenuType {
        public static final int OPEN_LOCK = 1;
        public static final int ADD_KEY = 2;
        public static final int READ_DNA = 3;
        public static final int DEL_DEVICE = 4;
        public static final int KEY_MENAGE = 5;
        public static final int LOCK_SETTING = 6;
        public static final int UP_DATE= 7;
        public static final int Lock_RECORD = 8;
        public static final int Cat1_Info = 9;
        public static final int NBIoT_Info = 10;
        public static final int Set_Key_Expiration_Alarm_Time = 11;

        @IntDef({OPEN_LOCK, ADD_KEY, READ_DNA, DEL_DEVICE, KEY_MENAGE, LOCK_SETTING,UP_DATE, Cat1_Info, NBIoT_Info, Set_Key_Expiration_Alarm_Time})
        @Retention(RetentionPolicy.SOURCE)
        public @interface HotActionInt {
        }
    }
}
