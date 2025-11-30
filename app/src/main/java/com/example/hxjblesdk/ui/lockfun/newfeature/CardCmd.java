package com.example.hxjblesdk.ui.lockfun.newfeature;


import com.example.hxjblinklibrary.blinkble.profile.data.HXMutableData;
import com.example.hxjblinklibrary.blinkble.utils_2.TimeUtils;

class CardCmd {
    /**
     * 制作校时卡
     *
     * @return
     */
    public static HXMutableData makeTimeCard() {
        HXMutableData dataOpen;
        dataOpen = new HXMutableData(new byte[47]);
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT16, 0);
        dataOpen.setValue(2, HXMutableData.FORMAT_UINT8, 2);
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT16, 3);
        dataOpen.setValue(5, HXMutableData.FORMAT_UINT8, 5);
        dataOpen.setValue(TimeUtils.getNowMills() / 1000, HXMutableData.FORMAT_UINT32, 6);
        dataOpen.setValue(TimeUtils.getTimeZoneOffset() / 3600, HXMutableData.FORMAT_UINT8, 10);
        dataOpen.setValue(TimeUtils.getDSTOffset() / 3600, HXMutableData.FORMAT_UINT8, 11);
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT8, 12);
        return dataOpen;
    }


    /**
     * 制作清除卡 慧享佳AES秘钥进行加密写入1扇区
     *
     * @return
     */
    public static HXMutableData makeClearCard() {
        HXMutableData dataOpen;
        dataOpen = new HXMutableData(new byte[47]);

        dataOpen.setValue(1, HXMutableData.FORMAT_UINT16, 0);
        dataOpen.setValue(2, HXMutableData.FORMAT_UINT8, 2);
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT16, 3);
        dataOpen.setValue(3, HXMutableData.FORMAT_UINT8, 5);//清除卡

        dataOpen.setValue(TimeUtils.getNowMills() / 1000, HXMutableData.FORMAT_UINT32, 6);//开始时间
        dataOpen.setValue(TimeUtils.getNowMills() / 1000 + 60 * 60 * 24, HXMutableData.FORMAT_UINT32, 10);//结束时间

        dataOpen.setValue(0xFFFF, HXMutableData.FORMAT_UINT16, 44);//youxiasocishu
        return dataOpen;
    }

    /**
     * 制作安装卡 必须用慧享佳AES秘钥进行加密写入(安装卡是1-5扇区)
     *
     * @param hotelAES128
     * @return
     */
    public static HXMutableData makeSetCard(byte[] hotelAES128) {
        HXMutableData dataOpen;
        dataOpen = new HXMutableData(new byte[47]);
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT16, 0);
        dataOpen.setValue(2, HXMutableData.FORMAT_UINT8, 2);
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT16, 3);
        dataOpen.setValue(4, HXMutableData.FORMAT_UINT8, 5);//安装卡

        dataOpen.setValue(TimeUtils.getNowMills() / 1000, HXMutableData.FORMAT_UINT32, 6);
        dataOpen.setValue(0, HXMutableData.FORMAT_UINT8, 10);//楼栋
        dataOpen.setValue(0, HXMutableData.FORMAT_UINT8, 11);//楼层
        dataOpen.setValue(0, HXMutableData.FORMAT_UINT24, 12);//房间号
        dataOpen.setValue(0, HXMutableData.FORMAT_UINT8, 15);//套房号
        dataOpen.setBytes(hotelAES128, 16);//密钥


        dataOpen.setValue(1, HXMutableData.FORMAT_UINT8, 32);//读卡扇区
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT8, 33);//通道模式 0x01：常开  0x02：正常模式
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT8, 34);//顶替功能 0x00：不修改  0x01：使能  0x02：禁用
        dataOpen.setValue(1, HXMutableData.FORMAT_UINT8, 45);//允许使用次数  生成安装卡时写1, 门锁安装成功后写0
        return dataOpen;
    }

    /**
     * 制作系统设置卡
     *
     * @return
     */
    public static HXMutableData makeSysSettingCard() {
        HXMutableData dataOpen;
        dataOpen = new HXMutableData(new byte[47]);
        return dataOpen;
    }


}
