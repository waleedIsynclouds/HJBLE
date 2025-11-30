package com.example.hxjblesdk.ui.oad;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.HxjApp;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.adapters.OadProgressLockListAdapter;
import com.example.hxjblesdk.db.beans.LockListBean;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanCallback;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanner;
import com.example.utils.SPUtils;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.hxj.bleoad.ti.TIOADEoadClient;
import com.hxj.bleoad.ti.TIOADEoadClientProgressCallback;
import com.hxj.bleoad.ti.TIOADEoadDefinitions;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import static android.app.Activity.RESULT_OK;

public class OadLoadingFirstFragment extends Fragment {
    private static final int SELECT_FILE_REQ = 1;
    public static final String MIME_TYPE_OCTET_STREAM = "application/octet-stream";

    private static final String TAG = "OadLoadingFirstFragment";
    private ArrayList<LockListBean> totalUpgradedList = new ArrayList<>();//所有的
    private OadProgressLockListAdapter adapter;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_first_oad_loading, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        totalUpgradedList = getArguments().getParcelableArrayList(OadLoadingActivity.UP_DATA_LIST);

//        selectFile();
        initView(view);
    }

    private void initView(View view) {
        RecyclerView recyclerView = view.findViewById(R.id.recyclerview);
        adapter = new OadProgressLockListAdapter(new ArrayList<>());
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));


        FloatingActionButton fab = view.findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                NavHostFragment.findNavController(OadLoadingFirstFragment.this)
                        .navigate(R.id.action_First2Fragment_to_Second2Fragment);
            }
        });
    }


    private void oad(final Uri uri) {
        HxjScanner.getInstance().startScan(15 * 1000, getActivity().getApplicationContext(), new HxjScanCallback() {
            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
            }

            @Override
            public void onHxjScanResults(@NonNull List<HxjBluetoothDevice> results) {
                super.onHxjScanResults(results);
                for (HxjBluetoothDevice hxjBluetoothDevice : results) {

                    Lock lock = totalUpgradedList.get(0).getLock();

                    if (hxjBluetoothDevice.getChipType() == 1 && hxjBluetoothDevice.getMac().equals(lock.getLockMac())) {
                        Log.e(TAG, "onHxjScanResults() called with: results = [" + hxjBluetoothDevice.getMac() + "]");
                        BlinkyAuthAction authAction = loadAuthActionData(hxjBluetoothDevice.getMac());

                        InputStream inputStream = null;
                        byte[] rawImageData = new byte[0];
                        try {
                            inputStream = getActivity().getContentResolver().openInputStream(uri);
                            int len;
                            rawImageData = new byte[inputStream.available()];
                            while ((len = inputStream.read(rawImageData)) != -1) { //len就是得出的字节流了。
                                Log.d(TAG, "Read " + rawImageData.length + " bytes from file");
                            }
                        } catch (IOException ex) {
                            //Log.d(TAG, "startOad() called with: hxjBluetoothDevice = [" + hxjBluetoothDevice + "], uri = [" + uri + "], authAction = [" + authAction + "], newVersion = [" + newVersion + "], upDataCallBack = [" + upDataCallBack + "]");
                            ex.printStackTrace();
                        } finally {
                            try {
                                if (inputStream != null)
                                    inputStream.close();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        }

                        new TIOADEoadClient(HxjApp.getAppContext()).initializeTIOADEoadProgrammingOnDevice(
                                hxjBluetoothDevice.getDevice().getAddress(),
                                inputStream,
                                new TIOADEoadClientProgressCallback() {
                                    @Override
                                    public void oadProgressUpdate(float percent, int currentBlock) {

                                    }

                                    @Override
                                    public void oadStatusUpdate(TIOADEoadDefinitions.oadStatusEnumeration status) {

                                    }
                                });
                    }
                }
            }
        });


    }


    public BlinkyAuthAction loadAuthActionData(String mac) {
        String spName = mac;
        SPUtils authInfo = SPUtils.getInstance(spName);
        BlinkyAuthAction authion;
        if (authInfo == null) {
            throw new IllegalArgumentException(getActivity().getApplication().getString(R.string.not_you_device));//如果这台设备属于你，请初始化后重新添加
        } else {
            authion = new BlinkyAuthAction.Builder()
                    .authCode(authInfo.getString("authCode"))
                    .dnaKey(authInfo.getString("dnaKey"))
                    .keyGroupId(authInfo.getInt("keyGroupId"))
                    .bleProtocolVer(0x1C)
                    .build();
        }
        return authion;
    }

    public void selectFile() {
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType(MIME_TYPE_OCTET_STREAM);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        if (intent.resolveActivity(getActivity().getPackageManager()) != null) {
            // file browser has been found on the device
            startActivityForResult(intent, SELECT_FILE_REQ);
        }
    }

    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case SELECT_FILE_REQ:
                final Uri uri = data.getData(); // and read new one
                oad(uri);
                break;
            default:
                break;
        }
    }
}
