package com.example.hxjblesdk.ui.locklist;

import android.Manifest;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemClickListener;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.adapters.LockListAdapter;
import com.example.hxjblesdk.db.beans.LockListBean;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.ui.addLock.AddDeviceActivity;
import com.example.hxjblesdk.ui.lockfun.LockFunActivity;
import com.example.hxjblesdk.viewmodel.LockViewModel;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanCallback;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanner;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.xiasuhuei321.loadingdialog.view.LoadingDialog;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import no.nordicsemi.android.support.v18.scanner.ScanResult;

import static androidx.core.content.PermissionChecker.PERMISSION_DENIED;
import static androidx.core.content.PermissionChecker.PERMISSION_GRANTED;

public class LockListActivity extends AppCompatActivity {
    private LockViewModel mLockViewModel;
    private LockListAdapter adapter;
    private int NEW_LOCK_ACTIVITY_REQUEST_CODE = 1;
    private LoadingDialog loadingDialog;
    private Toast mToast;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_lock_list);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mLockViewModel = new ViewModelProvider(this).get(LockViewModel.class);
        initView();
        initListener();


        mLockViewModel.getAllLocks().observe(this, new Observer<List<Lock>>() {
            @Override
            public void onChanged(@Nullable final List<Lock> locks) {
                // Update the cached copy of the words in the adapter.
                List<LockListBean> llbList = new ArrayList<>();


                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                    //使用stream拷贝list
                    llbList = locks.stream().map(LockListBean::new).collect(Collectors.toList());
                } else {
                    //不使用stream拷贝list
                    llbList = new ArrayList<>();
                    for (Lock lock : locks) {
                        LockListBean l = new LockListBean(lock);
                        llbList.add(l);
                    }
                }
                adapter.setList(llbList);
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_device_list, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        int itemId = item.getItemId();
        if (itemId == R.id.action_settings) {
            //Intent intent = new Intent(LockListActivity.this, OadListActivity.class);
//                startActivity(intent);
//                Intent intent = new Intent(LockListActivity.this, ProximityActivity.class);
//                startActivity(intent);
//                Intent intent = new Intent(LockListActivity.this, LockListTestConnectActivity.class);
//                startActivity(intent);
        } else if (itemId == R.id.action_dfu) {
        }

        return false;
    }

    @Override
    protected void onStart() {
        super.onStart();

    }


    private void initListener() {
        adapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(@NonNull BaseQuickAdapter<?, ?> adapter, @NonNull View view, int position) {
                //startScan(((LockListBean) adapter.getData().get(position)).getLock());
                if (!requetPermission()) return;
                Intent intent = new Intent(LockListActivity.this, LockFunActivity.class);
                Lock lockObj = ((LockListBean) adapter.getData().get(position)).getLock();
                intent.putExtra(LockFunActivity.LOCK_INFO, lockObj);
                startActivity(intent);
            }
        });
    }


    private boolean requetPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
            return false;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_ADVERTISE}, 1);
                return false;
            }
        }
        return true;
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1) {
            for (int i = 0; i < permissions.length; i++) {
                if (grantResults[i] == PERMISSION_GRANTED) {//选择了允许授权
                }else if (grantResults[i] == PERMISSION_DENIED){
                    if (mToast != null) {
                        mToast.cancel();
                    }
                    mToast = Toast.makeText(this, permissions[i] + getString(R.string.permission_tips), Toast.LENGTH_SHORT);
                    mToast.show();
                }
            }
        }
    }


    private void initView() {
        RecyclerView recyclerView = findViewById(R.id.recyclerview);
        adapter = new LockListAdapter(new ArrayList<>());
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));


        FloatingActionButton fab = findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!requetPermission()) return;
                Intent intent = new Intent(LockListActivity.this, AddDeviceActivity.class);
                startActivityForResult(intent, NEW_LOCK_ACTIVITY_REQUEST_CODE);
            }
        });
    }


    private void startScan(Lock lock) {
        loadingDialog = new LoadingDialog(this);
        loadingDialog.setLoadingText("正在搜索设备..." + lock.getLockMac()).show();//设置loading时显示的文字


        //Make sure this device is not connected,otherwise you can not scan this lock
        HxjScanner.getInstance().startScan(5000, getApplicationContext(), new HxjScanCallback() {
            @Override
            public void onHxjScanResults(@NonNull List<HxjBluetoothDevice> results) {
                super.onHxjScanResults(results);
                if (results.size() > 0) {
                    for (final HxjBluetoothDevice result : results) {
                        if (lock.getLockMac().equals(result.getMac())) {
                            stopScan();
                            loadingDialog.loadSuccess();
                            Intent intent = new Intent(LockListActivity.this, LockFunActivity.class);
                            intent.putExtra(LockFunActivity.DEVICE, result);
                            startActivity(intent);
                        }
                    }
                }
            }

            @Override
            public void onScanResult(int callbackType, @NonNull ScanResult result) {
                super.onScanResult(callbackType, result);
                HxjBluetoothDevice hxjBluetoothDevice = new HxjBluetoothDevice(result);
            }

            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
                loadingDialog.loadFailed();
            }
        });
    }


    private void stopScan() {
        HxjScanner.getInstance().stopScan();
    }


    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == NEW_LOCK_ACTIVITY_REQUEST_CODE && resultCode == RESULT_OK) {
            Log.d(TAG, "onActivityResult: RESULT_OK" + resultCode);
        } else {
            Log.d(TAG, "onActivityResult: " + resultCode);
        }
    }

    private static final String TAG = "LockListActivity";

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
