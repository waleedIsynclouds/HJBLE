package com.example.hxjblesdk.ui.oad;

import android.Manifest;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.CheckBox;
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
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.chad.library.adapter.base.listener.OnItemClickListener;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.adapters.OadLockListAdapter;
import com.example.hxjblesdk.db.beans.LockListBean;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.viewmodel.LockViewModel;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Collectors;

import static androidx.core.content.PermissionChecker.PERMISSION_GRANTED;

public class OadListActivity extends AppCompatActivity {
    private LockViewModel mLockViewModel;
    private OadLockListAdapter adapter;
    private int NEW_LOCK_ACTIVITY_REQUEST_CODE = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_oad_lock_list);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);


        mLockViewModel = new ViewModelProvider(this).get(LockViewModel.class);
        myRequetPermission();
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
    protected void onStart() {
        super.onStart();
    }

    private void initListener() {
        adapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(@NonNull BaseQuickAdapter adapter, @NonNull View view, int position) {
//                LockListBean lockListBean = (LockListBean) adapter.getData().get(position);
//                lockListBean.setSelect(!lockListBean.isSelect());
//                adapter.setData(position, lockListBean);
            }
        });
        adapter.setOnItemChildClickListener(new OnItemChildClickListener() {
            @Override
            public void onItemChildClick(@NonNull BaseQuickAdapter adapter, @NonNull View view, int position) {
                onSelectItem(adapter, view, position);
            }
        });
    }

    private void onSelectItem(@NonNull BaseQuickAdapter adapter, @NonNull View view, int position) {
        LockListBean lockListBean = (LockListBean) adapter.getData().get(position);
        if (view instanceof CheckBox && view.getId() == R.id.checkBox) {
            CheckBox checkBox = (CheckBox) view;
            if (checkBox.isChecked()) {
                lockListBean.setSelect(true);
                adapter.setData(position, lockListBean);
            } else {
                lockListBean.setSelect(false);
                adapter.setData(position, lockListBean);
            }
        }
    }

    private void myRequetPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
        } else {
            Toast.makeText(this, R.string.geted_permission, Toast.LENGTH_SHORT).show();
        }
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1) {
            for (int i = 0; i < permissions.length; i++) {
                if (grantResults[i] == PERMISSION_GRANTED) {//选择了“始终允许”
                    Toast.makeText(this, permissions[i] + getString(R.string.lock_operation_success), Toast.LENGTH_SHORT).show();
                }
            }
        }
    }


    private void initView() {
        RecyclerView recyclerView = findViewById(R.id.recyclerview);
        adapter = new OadLockListAdapter(new ArrayList<>());
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));


        FloatingActionButton fab = findViewById(R.id.fab);
        fab.setOnClickListener(view -> {
            Intent intent = new Intent(OadListActivity.this, OadLoadingActivity.class);
            ArrayList<LockListBean> nextToUpdate = getLockListBeansToUpDate();
            intent.putParcelableArrayListExtra(OadLoadingActivity.UP_DATA_LIST, nextToUpdate);
            startActivity(intent);
        });
    }

    private ArrayList<LockListBean> getLockListBeansToUpDate() {
        Iterator<LockListBean> iterator = adapter.getData().iterator();
        ArrayList<LockListBean> nextToUpdate = new ArrayList<>();
        while (iterator.hasNext()) {
            LockListBean next = iterator.next();
            if (next.isSelect()) {
                nextToUpdate.add(next);
            }
        }
        return nextToUpdate;
    }


    private static final String TAG = "OadListActivity";
}
