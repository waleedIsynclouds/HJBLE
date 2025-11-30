package com.example.utils;

public class RFModuleType {
    /** 外接433模组  */
    public static final int TCV433 = 0;
    /** 暂未使用  */
    public static final int LPRX315 = 1;
    /** 暂未使用  */
    public static final int TCV868 = 2;
    /** 外接Wi-Fi模组  */
    public static final int HXJWIFI = 4;
    /** NB-IoT，可直接联网  */
    public static final int HXJNBDX = 5;
    /** LoRa模组  */
    public static final int HXJLoRa = 6;
    /** 暂未使用  */
    public static final int HXJZigBee = 7;
    /** 支持身份证云解析的Wi-Fi模组  */
    public static final int HXJWIFIZJJX = 8;
    /** NBIoT模组，MQTT Protocol 支持MQTT协议 */
    public static final int HXJNBMQTT = 9;
    /** NBIoT模组，支持LWM2M协议 */
    public static final int HXJNBLWM2M = 10;
    /** LTEUE-Category1（Cat.1）模组，Cat.1，可以称为“低配版”的 4G 终端，上行峰值速率5Mbit/s，下行峰值速率10Mbit/s，属于蜂窝物联网，是广域网  */
    public static final int HXJCat1= 11;
    /** 没有无线模组，可绑定蓝牙网关实现联网  */
    public static final int Empty = 255;

}
