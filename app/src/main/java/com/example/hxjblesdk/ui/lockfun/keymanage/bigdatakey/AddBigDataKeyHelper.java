package com.example.hxjblesdk.ui.lockfun.keymanage.bigdatakey;

import android.content.Context;
import android.os.Handler;
import android.util.Base64;
import android.util.Log;

import com.example.HxjApp;
import com.example.hxjblesdk.R;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BLEAddBigDataKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BLEKeyValidTimeParam;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.BleLockAddFaceKeyResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.common.HxbleError;
import com.example.hxjblinklibrary.blinkble.profile.data.common.KeyType;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.utils_2.TimeUtils;
import com.example.utils.MyBleClient;

import java.util.Formatter;

public class AddBigDataKeyHelper {

    public static final String TAG = AddBigDataKeyHelper.class.getSimpleName();

    Context context = HxjApp.getAppContext();

    private boolean isCancel;

    private byte[] keyBytes;

    private String lockMac;
    private int keyGroupId;
    private SendBigKeyDataCallback progressCallback;
    private int curKeyType;
    private BlinkyAuthAction baseAuthObj;

    private Handler timeHandle;

    public int curPhase;
    public int lastStatusCode;

    private BLEAddBigDataKeyAction param;

    /// 每包最大发送的字节数
    private int maxBlockSize = 180;

    /// 添加人脸钥匙成功门锁返回的钥匙Id
    private int lockKeyId;

    private LockKeyResult keyObj;

    private BLEKeyValidTimeParam timeParam;

    //region 开始

    /**
     * 开始添加人脸数据/指纹数据到门锁中
     * @param bigDataBase64Str 人脸特征值/指纹特征值（注意：该值需要经过服务器进一步处理后获取，避免图片不满足门锁识别的要求）
     * @param lockMac 门锁Mac
     * @param keyGroupId 要添加给哪个用户，表示这个用户的Id（由自己的服务器分配keyGroupId，确保一把锁中用户的keyGroupId不冲突，取值范围：900~4095）
     * @param keyType 钥匙类型：指纹或人脸
     * @param timeParam 钥匙有效期
     * @param baseAuthObj 鉴权信息
     * @param progressCallback 结果回调
     */
    public void startWithBigDataBase64Str(String bigDataBase64Str,
                                          String lockMac,
                                          int keyGroupId,
                                          int keyType,
                                          BLEKeyValidTimeParam timeParam,
                                          BlinkyAuthAction baseAuthObj,
                                          SendBigKeyDataCallback progressCallback) {
        String error = decodeBase64ImgStr(bigDataBase64Str);
        if (error != null) {
            if (progressCallback != null) {
                progressCallback.onCallback(StatusCode.ACK_STATUS_PARAM_ERR, error, BLESendBigKeyDataPhase.sending, 0, null);
            }
            return;
        }
        this.timeParam = timeParam;
        this.baseAuthObj = baseAuthObj;
        this.curKeyType = keyType;
        this.progressCallback = progressCallback;
        this.lockMac = lockMac;
        this.keyGroupId = keyGroupId;
        start();
    }
    //endregion

    private void start() {
        isCancel = false;
        lockKeyId = 0;

        param = new BLEAddBigDataKeyAction();
        param.setBaseAuthAction(baseAuthObj);
        param.totalBytesLength = (int) keyBytes.length;
        param.currentIndex = 0;
        int totalNum = (int) (keyBytes.length / maxBlockSize) + ((keyBytes.length % maxBlockSize) == 0 ? 0 : 1);
        param.totalNum = totalNum;
        param.keyGroupId = keyGroupId;

        if (progressCallback != null) {
            curPhase = BLESendBigKeyDataPhase.sending;
            lastStatusCode = StatusCode.ACK_STATUS_SUCCESS;
            progressCallback.onCallback(lastStatusCode, context.getString(R.string.Localizable_preBleSendKeyData), curPhase, 0, null);
        }
        recursionSendKeyData();
    }

    private String decodeBase64ImgStr(String base64Str) {
        String errorMessage = null;
        if (base64Str == null || base64Str.length() == 0) {
            errorMessage = "face data is empty";
        } else {
            try {
                keyBytes = Base64.decode(base64Str, Base64.NO_WRAP);
            } catch (IllegalArgumentException e) {
                errorMessage = e.getMessage();
            }
        }
        return errorMessage;
    }

    /**
     * 取消
     */
    public void cancel() {
        isCancel = true;
        progressCallback = null;
        keyBytes = null;
        lockKeyId = 0;
        removeTimeHandle();
    }

    private void removeTimeHandle() {
        if (timeHandle != null) {
            timeHandle.removeCallbacksAndMessages(null);
            timeHandle = null;
        }
    }

    // 递归发送一个人脸/指纹的数据
    private void recursionSendKeyData() {

        if (isCancel) {
            return;
        }
        int currentIndex = param.currentIndex * maxBlockSize; // 第一个包currentIndex为0
        int length = maxBlockSize;
        if (currentIndex + maxBlockSize > param.totalBytesLength) {
            length = (int) (param.totalBytesLength - currentIndex);
            Log.d(TAG, String.format("准备下发第%d个包，最后一个包！！！（共%d个包）", param.currentIndex, param.totalNum));
        } else {
            Log.d(TAG, String.format("准备下发第%d个包（共%d个包）", param.currentIndex, param.totalNum));
        }
        byte[] sendData = new byte[length];
        // 原数组、截取原数组的起始位置（从0开始计算）、目标数组、存放在目标数组的位置（从0开始计算）、截取数据长度
        System.arraycopy(keyBytes, currentIndex, sendData, 0, length);
        Log.d(TAG, "下发给门锁的数据包：" + byteToHexString(sendData));
        param.data = sendData;

        if (curKeyType == KeyType.Face) {
            MyBleClient.getInstance(context).addFaceKeyData(param, timeParam, new FunCallback() {
                @Override
                public void onResponse(Response response) {
                    onBLEAddKeyDataResponse(response);
                }
                @Override
                public void onFailure(Throwable t) {
                    onBLEFailure(t);
                }
            });
        } else if (curKeyType == KeyType.FINGER) {
            MyBleClient.getInstance(context).addFingerprintKeyData(param, timeParam, new FunCallback() {
                @Override
                public void onResponse(Response response) {
                    onBLEAddKeyDataResponse(response);
                }
                @Override
                public void onFailure(Throwable t) {
                    onBLEFailure(t);
                }
            });
        }
    }

    private void onBLEFailure(Throwable t) {
        String reason = t.getMessage();
        int statusCode = StatusCode.ACK_STATUS_FAIL;
        if (t instanceof HxbleError) {
            HxbleError hxbleError = (HxbleError) t;
            statusCode = hxbleError.getmErrorCode();
        }
        String tips = String.format("%s: %s", context.getString(R.string.Localizable_FailedToAddKey), reason);
        onBLEResponseFailed(statusCode, tips);
    }

    private void onBLEAddKeyDataResponse(Response response) {

        int statusCode = response.code();
        String reason = StatusCode.parse(statusCode, context);
        if (statusCode == StatusCode.ACK_STATUS_SUCCESS) {
            if (response.body() instanceof BleLockAddFaceKeyResult) {
                BleLockAddFaceKeyResult result = (BleLockAddFaceKeyResult) response.body();
                if (result.flags == 0 && result.currentIndex == result.totalNum) {
                    //发送最后一个钥匙包，该包序号会对应多次回调。
                    //如果返回成功，忽略掉flags == 0的回调，等待flags==1的回调。
                    //flags==1表示最后添加钥匙的结果。

                    // 这里增加超时机制，当最后一包无返回时提示用户
                    timeHandle = new Handler();
                    timeHandle.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            String tips = String.format("%s, %s", context.getString(R.string.Localizable_FailedToAddKey), context.getString(R.string.timeout));
                            onBLEResponseFailed(StatusCode.LOCAL_SCAN_TIME_OUT, tips);
                        }
                    }, 15 * 1000);
                    return;
                }
                removeTimeHandle();
                onBLEResponseSuccess(result.lockKeyId);
            }
        } else {
            String tips = context.getString(R.string.Localizable_FailedToAddKey);
            if (response.code() == StatusCode.ACK_STATUS_FAIL) {
                statusCode = StatusCode.ACK_STATUS_FAIL;
                tips = String.format("%s: \n%s", tips, context.getString(R.string.Localizable_AddKeyTips));

            } else {
                if (reason == null || reason.length() == 0) {
                    if (lastStatusCode != StatusCode.ACK_STATUS_SUCCESS) {
                        return;
                    }
                }
                tips = String.format("%s: %s", tips, reason);
            }
            MyBleClient.getInstance(context).removeFunCallback();
            onBLEResponseFailed(statusCode, tips);
        }
    }

    private void onBLEResponseSuccess(int lockKeyId) {
        param.currentIndex++;
        curPhase = BLESendBigKeyDataPhase.sending;
        if (progressCallback != null) {
            double progress = (param.currentIndex * 1.0) / param.totalNum;
            if (param.currentIndex == param.totalNum) {
                progress = 0.98;
            }
            Log.d(TAG, String.format("************************\n当前进度：%.0f%%(%d/%d)", progress * 100, param.currentIndex, param.totalNum));
            lastStatusCode = StatusCode.ACK_STATUS_SUCCESS;
            String tips = context.getString(R.string.Localizable_bleSendKeyData);
            progressCallback.onCallback(lastStatusCode, tips, curPhase, progress, null);
        }
        if (param.currentIndex == param.totalNum) {
            this.lockKeyId = lockKeyId;
            if (progressCallback != null) {
                curPhase = BLESendBigKeyDataPhase.end;
                lastStatusCode = StatusCode.ACK_STATUS_SUCCESS;
                String tips = context.getString(R.string.addSuccess);
                setupKeyObj();
                progressCallback.onCallback(StatusCode.ACK_STATUS_SUCCESS, tips, BLESendBigKeyDataPhase.end, 1, keyObj);
            }

        } else {
            recursionSendKeyData();
        }
    }

    private void onBLEResponseFailed(int statusCode, String reason) {
        double progress = (param.currentIndex * 1.0) / param.totalNum;
        if (progressCallback != null) {
            isCancel = true;
            curPhase = BLESendBigKeyDataPhase.sending;
            lastStatusCode = statusCode;
            progressCallback.onCallback(statusCode, reason, curPhase, progress, null);
        }
    }

    private void setupKeyObj() {
        if (keyObj == null) {
            keyObj = new LockKeyResult();
        }
        keyObj.setKeyID(this.lockKeyId);
        keyObj.setKeyType(curKeyType);
        keyObj.setModifyTimestamp(TimeUtils.getNowMills() / 1000);
        keyObj.setVaildStartTime(timeParam.validStartTime);
        keyObj.setVaildEndTime(timeParam.validEndTime);
        keyObj.setVaildNumber(timeParam.validNumber);
        keyObj.setVaildMode(timeParam.authMode);
        keyObj.setWeeks(timeParam.weeks);
        keyObj.setDayStartTimes(timeParam.dayStartTimes);
        keyObj.setDayEndTimes(timeParam.dayEndTimes);
        keyObj.setDeleteMode(1);
    }

    public static String byteToHexString(byte[] b) {
        if (b == null) return "NULL";
        StringBuilder sb = new StringBuilder(b.length * (2 + 1));
        Formatter formatter = new Formatter(sb);

        for (int i = 0; i < b.length; i++) {
            if (i < b.length - 1)
                formatter.format("%02X:", b[i]);
            else
                formatter.format("%02X", b[i]);
        }
        formatter.close();
        return sb.toString();
    }
}
