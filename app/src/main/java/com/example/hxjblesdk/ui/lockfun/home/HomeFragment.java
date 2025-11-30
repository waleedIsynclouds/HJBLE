package com.example.hxjblesdk.ui.lockfun.home;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemClickListener;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.adapters.LockFunMenuAdapter;
import com.example.hxjblesdk.db.beans.LockFunMenuBean;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.ui.firmwareupgrade.FirmwareUpgradeActivity;
import com.example.hxjblesdk.ui.lockfun.LockFunViewModel;
import com.example.hxjblesdk.viewmodel.LockViewModel;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BleHotelLockSystemParam;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BleSetHotelLockSystemAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.OpenLockAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SyncLockRecordAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
import com.example.hxjblinklibrary.blinkble.entity.reslut.HxBLEUnlockResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockRecordDataResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.lockrecord1.HXRecordBaseModel;
import com.example.hxjblinklibrary.blinkble.entity.reslut.lockrecord2.HXRecord2BaseModel;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.common.HxbleError;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.profile.other.ATConfigHelper;
import com.example.hxjblinklibrary.blinkble.profile.other.Cat1ATConfigHelper;
import com.example.utils.IntentExtraType;
import com.example.utils.MyBleClient;
import com.example.utils.RFModuleTypeHelper;
import com.google.android.material.button.MaterialButton;
import com.kongzue.dialogx.dialogs.MessageDialog;
import com.xiasuhuei321.loadingdialog.view.LoadingDialog;

import java.util.ArrayList;
import java.util.List;

public class HomeFragment extends Fragment {
    private static final String TAG = "HomeFragment";
    private HomeViewModel homeViewModel;
    private LockFunViewModel lockFunViewModel;
    private BlinkyAuthAction mAuthion;
    private RecyclerView recyclerView;
    private LockFunMenuAdapter lockFunMenuAdapter;
    private MaterialButton openLockButton;
    private LoadingDialog loadingDialog;

    private int startIndex;
    private int allRecordCount;

    private Cat1ATConfigHelper cat1ATConfigHelper;
    private ATConfigHelper nbATConfigHelper;

    Toast tempToast;
    Handler handler = new Handler();
    private Runnable runnable = new Runnable() {
        @Override
        public void run() {
            Log.d(TAG, "run() called");
            openLock();
        }
    };

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        homeViewModel = new ViewModelProvider(this).get(HomeViewModel.class);
        lockFunViewModel = new ViewModelProvider(getActivity()).get(LockFunViewModel.class);
        View root = inflater.inflate(R.layout.fragment_home, container, false);
        recyclerView = root.findViewById(R.id.rv_fun);
        openLockButton = root.findViewById(R.id.button_open);
        initLockMenu();
        observer();
        loadData();
        initListener();
        return root;
    }

    private void initLockMenu() {

        Lock lockObj = lockFunViewModel.getLockObj();
        if (lockObj == null) return;

        ArrayList<LockFunMenuBean> data = new ArrayList<>();
        data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.ADD_KEY, getString(R.string.add_key), R.drawable.ic_baseline_add_key_24));
        data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.KEY_MENAGE, getString(R.string.menu_keymanage), R.drawable.ic_baseline_key_manage_24));
        data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.LOCK_SETTING, getString(R.string.lock_setting), R.drawable.ic_baseline_settings_24));
        data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.Lock_RECORD, getString(R.string.operation_record), R.drawable.ic_baseline_lock_open_24));
        data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.DEL_DEVICE, getString(R.string.del_lock), R.drawable.ic_baseline_delete_device_24));
        data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.UP_DATE, getString(R.string.updata), R.drawable.ic_baseline_arrow_circle_up_24));
        if (RFModuleTypeHelper.isHXJNBIoTRFType(lockObj.getRFModuleType())) {
            data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.NBIoT_Info, getString(R.string.get_nbIoT_module_info), R.drawable.ic_sim_card));

        }else if (RFModuleTypeHelper.isCat1RFType(lockObj.getRFModuleType())) {
            data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.Cat1_Info, getString(R.string.get_cat1_module_info), R.drawable.ic_sim_card));
        }

        if (((lockObj.getLockNetSystemFunction() & 0x1000000) >> 24) == 1) {
            data.add(new LockFunMenuBean(LockFunMenuBean.MenuType.Set_Key_Expiration_Alarm_Time, getString(R.string.set_lock_key_expiration_alarm_time), R.drawable.ic_lock_detail_alarm));
        }

        lockFunMenuAdapter = new LockFunMenuAdapter(data);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), 3));
        recyclerView.setAdapter(lockFunMenuAdapter);
    }


    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    private void observer() {
        homeViewModel.getText().observe(getViewLifecycleOwner(), s -> {
        });
        lockFunViewModel.getAuthAction().observe(getViewLifecycleOwner(), s -> {
            mAuthion = s;
             /*
             注：如果App无法获取到门锁的DNA key 和 authCode传给SDK，需要创建一个类实现IHxBleSecureAuth协议的方法
             mAuthion.setDnaKey(null);
             mAuthion.setAuthCode(null);
             mAuthion.setSecureAuthObj(new SecureAuthHelper());
              */
        });
    }

    private void loadData() {
        lockFunViewModel.loadMyAuthAction();
    }

    private void initListener() {
        lockFunMenuAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(@NonNull BaseQuickAdapter<?, ?> adapter, @NonNull View view, int position) {
                LockFunMenuBean funMenuBean = (LockFunMenuBean) adapter.getData().get(position);
                switch (funMenuBean.getType()) {
                    case LockFunMenuBean.MenuType.OPEN_LOCK:
                        openLock();
                        break;
                    case LockFunMenuBean.MenuType.ADD_KEY:
                        addKey();
                        break;
                    case LockFunMenuBean.MenuType.DEL_DEVICE:
                        delLock();
                        break;
                    case LockFunMenuBean.MenuType.KEY_MENAGE:
                        keyManage();
                        break;
                    case LockFunMenuBean.MenuType.LOCK_SETTING:
                        lockSetting();
                        break;
                    case LockFunMenuBean.MenuType.UP_DATE:
                        lockUpdate();
                        break;
                    case LockFunMenuBean.MenuType.Lock_RECORD:
                        synLog();
                        break;
                    case LockFunMenuBean.MenuType.NBIoT_Info:
                        getNBIoTInfo();
                        break;
                    case LockFunMenuBean.MenuType.Cat1_Info:
                        getCat1Info();
                        break;
                    case LockFunMenuBean.MenuType.Set_Key_Expiration_Alarm_Time:
                        setKeyExpirationAlarmTime();
                        break;
                }

            }
        });

        openLockButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openLock();
            }
        });
    }

    private void getNBIoTInfo() {

        if (nbATConfigHelper == null) {
            nbATConfigHelper = new ATConfigHelper(getContext(), MyBleClient.getInstance(getActivity()));
        }
        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText("获取信息中，请耐心等待...").show();
        nbATConfigHelper.startSetting(mAuthion, new ATConfigHelper.ATCallBack() {
            @Override
            public void onAtGetSuccess(int rssi, String imsi, String imei) {
                loadingDialog.close();
                String message = String.format("IMEI: %s\nIMSI: %s\nRSSI: %s\n",imei, imsi, rssi);
                MessageDialog messageDialog = new MessageDialog(getString(R.string.lock_operation_success), message);
                messageDialog.show();
            }

            @Override
            public void onError(String str) {
                loadingDialog.close();
                showToast(str, -1);
            }
        });
    }

    private void getCat1Info() {

        if (cat1ATConfigHelper == null) {
            cat1ATConfigHelper = new Cat1ATConfigHelper(getContext(), MyBleClient.getInstance(getActivity()));
        }
        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText("获取信息中，请耐心等待...").show();
        cat1ATConfigHelper.start(mAuthion, new Cat1ATConfigHelper.Cat1ATCallBack() {
            @Override
            public void onAtGetSuccess(String iccid, String imei, String imsi, String rssi, String rsrp, String sinr) {
                loadingDialog.close();
                String message = String.format("ICCID: %s\nIMEI: %s\nIMSI: %s\nRSSI: %s\nRSRP: %s\nSINR: %s\n",iccid, imei, imsi, rssi, rsrp, sinr);
                MessageDialog messageDialog = new MessageDialog(getString(R.string.lock_operation_success), message);
                messageDialog.show();
            }

            @Override
            public void onError(String str) {
                loadingDialog.close();
                showToast(str, -1);
            }
        });
    }

    /// 设置蓝牙锁钥匙到期提醒时间
    private void setKeyExpirationAlarmTime() {

        Log.d(TAG, "点击设置蓝牙锁钥匙到期提醒时间");

        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText("设置中，请稍等...").show();

        BleSetHotelLockSystemAction action = new BleSetHotelLockSystemAction();
        BleHotelLockSystemParam param = new BleHotelLockSystemParam();
        param.setExpirationAlarmTime(30);// 钥匙在30天内过期，开锁时会播报语音提醒
        action.setParam(param);
        action.setBaseAuthAction(mAuthion);

        MyBleClient.getInstance(getActivity()).bleSetHotelLockSystemParam(action, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                loadingDialog.close();
                Log.e(TAG, "开锁回调: code=" + response.code());
                String responseStr = StatusCode.parse(response.code(), requireContext());
                showToast(responseStr, response.code());
            }

            @Override
            public void onFailure(Throwable t) {
                onBLEFailure(t);
            }
        });
    }

    private void onBLEFailure(Throwable t) {
        loadingDialog.close();
        String responseStr = t.getMessage() + " [" + ((HxbleError) t).getmErrorCode() + "]";
        showToast(responseStr, -1);
        MyBleClient.getInstance(getActivity()).disConnectBle(null);
    }

    private void lockUpdate() {

        Intent intent = new Intent(getContext(), FirmwareUpgradeActivity.class);
        intent.putExtra(IntentExtraType.LockMac, mAuthion.getMac());
        startActivity(intent);
    }

    private void lockSetting() {
        NavController navController = NavHostFragment.findNavController(HomeFragment.this);
        navController.navigate(R.id.action_nav_home_to_lockSettingsFragment);
    }

    private void keyManage() {
        NavController navController = NavHostFragment.findNavController(HomeFragment.this);
        navController.navigate(R.id.action_nav_home_to_nav_kayManage);
    }

    private void addKey() {
        int lockFunctionType = lockFunViewModel.getLockObj().getLockFunctionType();
        NavController navController = NavHostFragment.findNavController(HomeFragment.this);
        // Create a bundle and add the argument
        Bundle bundle = new Bundle();
        bundle.putInt("lockFunctionType", lockFunctionType);
        // Navigate with the action ID and bundle
        navController.navigate(R.id.action_nav_home_to_addKeyTypeDialogFragment, bundle);
    }


    /**
     * 开锁
     */
    private void openLock() {
        Log.d(TAG, "点击开锁按钮");

        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText("开锁中...").show();

        OpenLockAction hxBleAction = new OpenLockAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity()).openLock(hxBleAction, new FunCallback<HxBLEUnlockResult>() {
            @Override
            public void onResponse(Response<HxBLEUnlockResult> response) {
                loadingDialog.close();
                Log.e(TAG, "开锁回调: code=" + response.code());
                String responseStr = StatusCode.parse(response.code(), requireContext());
                showToast(responseStr, response.code());
                //handler.postDelayed(runnable, 5 * 1000);  5秒后循环开锁，测试电量消耗
                MyBleClient.getInstance(getActivity()).disConnectBle(null);
            }

            @Override
            public void onFailure(Throwable t) {
                loadingDialog.close();
                String responseStr = t.getMessage() + " [" + ((HxbleError) t).getmErrorCode() + "]";
                showToast(responseStr, -1);
                MyBleClient.getInstance(getActivity()).disConnectBle(null);
            }
        });

    }

    /**
     * 关锁
     */
    private void closeLock() {
        Log.d(TAG, "点击关锁按钮");
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        Context context = getContext();
        loadingDialog = new LoadingDialog(context);
        loadingDialog.setLoadingText("关锁中...").show();//设置loading时显示的文字
        MyBleClient.getInstance(getActivity()).closeLock(hxBleAction, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                loadingDialog.close();
                Log.e(TAG, "关锁回调: code=" + response.code());
                String responseStr = StatusCode.parse(response.code(), requireContext());
                if (responseStr.length() == 0) {
                    responseStr = getString(R.string.ble_timeout);
                }
                showToast(responseStr, response.code());
            }

            @Override
            public void onFailure(Throwable t) {
                loadingDialog.close();
                String responseStr = t.getMessage() + " [" + ((HxbleError) t).getmErrorCode() + "]";
                showToast(responseStr, -1);
            }
        });

    }

    private void showToast(String message, int statusCode) {

        Context context = getContext();
        if (context != null) {
            if (message == null || message.length() == 0) {
                if (statusCode == StatusCode.LOCAL_SCAN_TIME_OUT) {
                    message = getString(R.string.ble_scan_timeout);
                } else {
                    return;
                }
            }
            if (tempToast != null) {
                tempToast.cancel();
            }

            tempToast = Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT);
            tempToast.show();
        }
    }

    /**
     * 1:表示第一代门锁操作记录，
     * 2:表示第二代门锁操作记录，
     * 根据门锁DNA信息中的menuFeature第三个bit位为1表示门锁仅支持第二代操作记录，否则表示门锁仅支持第一代操作记录
     */
    private int getLogVersion() {
        Lock lockObj = lockFunViewModel.getLockObj();
        int logVersion = 1;
        if ((lockObj.getMenuFeature() & 8) == 8) {
            logVersion = 2;
        }
        return logVersion;
    }

    /**
     * 同步门锁记录
     */
    private void synLog() {
        Log.e(TAG, "syncLockRecordAction");
        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText("同步门锁记录...").show();

        BlinkyAction blinkyAction = new BlinkyAction();
        blinkyAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity().getApplicationContext()).getRecordNum(blinkyAction, new FunCallback<Integer>() {
            @Override
            public void onResponse(Response<Integer> response) {
                if (response.isSuccessful()) {
                    Log.d(TAG, "onResponse, Record num = " + response.body().intValue());
                    startIndex = 0;
                    allRecordCount = response.body().intValue();
                    recursionQueryRecords();
                } else {
                    loadingDialog.close();
                    String responseStr = StatusCode.parse(response.code(), requireContext()) + "(" + response.code() + ")";
                    showToast(responseStr, response.code());
                }
            }

            @Override
            public void onFailure(Throwable t) {
                loadingDialog.close();
                String responseStr = t.getMessage() + " [" + ((HxbleError) t).getmErrorCode() + "]";
                showToast(responseStr, -1);
            }
        });
    }

    private void recursionQueryRecords() {
        int logVersion = getLogVersion();
        SyncLockRecordAction syncLockRecordAction = new SyncLockRecordAction(startIndex, 10, logVersion);
        syncLockRecordAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity().getApplicationContext()).syncLockRecord(syncLockRecordAction, new FunCallback<LockRecordDataResult>() {
            public void onResponse(Response<LockRecordDataResult> response) {

                if (response.isSuccessful()) {

                    boolean isNull = true;//应对异常出错的情况
                    if (response.body().getLogNum() > 0) {
                        isNull = false;

                        if (getLogVersion() == 1) {
                            List<HXRecordBaseModel> recordArr = response.body().getLog1Array();
                            for (int i = 0; i < recordArr.size(); i++) {
                                HXRecordBaseModel recordObj = recordArr.get(i);
                                Log.d(TAG, "第" + (startIndex + i) + "条记录, " + recordObj.toString());
                            }

                        } else if (getLogVersion() == 2) {
                            List<HXRecord2BaseModel> recordArr = response.body().getLog2Array();
                            for (int i = 0; i < recordArr.size(); i++) {
                                HXRecord2BaseModel recordObj = recordArr.get(i);
                                Log.d(TAG, "第" + (startIndex + i) + "条记录, " + recordObj.toString());
                            }
                        }
                        startIndex += response.body().getLogNum();
                    }

                    if (response.body().isMoreData()) {
                        Log.d(TAG, "本次同步数据分包返回，后续还有数据返回");
                    } else {
                        if (startIndex >= allRecordCount || isNull) {
                            Log.d(TAG, "Finish");
                            loadingDialog.close();
                            showToast("Success", response.code());
                        } else {
                            recursionQueryRecords();
                        }
                    }
                } else {
                    loadingDialog.close();
                    String responseStr = StatusCode.parse(response.code(), requireContext()) + "(" + response.code() + ")";
                    if (response.code() == 236) {
                        responseStr += "\n\n请修改请求参数logVersion，根据门锁DNA信息中的menuFeature第三个bit位为1表示门锁仅支持第二代操作记录（logVersion填2），否则表示门锁仅支持第一代操作记录（logVersion填1）";
                    }
                    showToast(responseStr, response.code());
                }
            }

            @Override
            public void onFailure(Throwable t) {
                Log.d(TAG, "Failed：" + t.getMessage());
                loadingDialog.close();
                showToast(t.getMessage(), -1);

            }
        });
    }


    /**
     * 刪除门锁
     */
    private void delLock() {

        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText("删除锁...").show();

        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity()).delDevice(hxBleAction, new FunCallback<String>() {
            @Override
            public void onResponse(Response<String> response) {
                loadingDialog.close();
                MyBleClient.getInstance(getActivity()).disConnectBle(null);
                if (response.isSuccessful()) {
                    LockViewModel lockViewModel = new ViewModelProvider(HomeFragment.this).get(LockViewModel.class);
                    lockViewModel.delLockWithMac(mAuthion.getMac());
                    showToast("Success", response.code());
                    getActivity().finish();
                } else {
                    String responseStr = StatusCode.parse(response.code(), requireContext()) + "(" + response.code() + ")";
                    showToast(responseStr, response.code());
                }
            }

            @Override
            public void onFailure(Throwable t) {
                loadingDialog.close();
                MyBleClient.getInstance(getActivity()).disConnectBle(null);
                String responseStr = t.getMessage() + " [" + ((HxbleError) t).getmErrorCode() + "]";
                showToast(responseStr, -1);
            }
        });
    }

    /**
     * 获取dna
     */
    private void getDna() {
//        tvLog.setText(R.string.getDna);
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity()).getDna(hxBleAction, new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
//                tvLog.setText("getDna:" + response.toString() + TimeUtils.getNowString());
            }

            @Override
            public void onFailure(Throwable t) {
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(runnable);
    }

    @Override
    public void onResume() {
        super.onResume();
        autoConnectDevice();
    }

    private void autoConnectDevice() {
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity()).onlyConnectAuth(hxBleAction, new FunCallback() {
            @Override
            public void onResponse(Response response) {

            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private boolean isConnectedToBluetoothDevice(String lockMac) {
        MyBleClient bleSDK = MyBleClient.getInstance(getActivity().getApplicationContext());
        boolean isConnect = bleSDK.isConnect();
        if (isConnect) {
            String curConnectedLockMac = bleSDK.getCurrentConnectLockMac();
            if (lockMac != null && curConnectedLockMac.equals(lockMac)) {
                return true;
            }
        }
        return false;
    }

}
