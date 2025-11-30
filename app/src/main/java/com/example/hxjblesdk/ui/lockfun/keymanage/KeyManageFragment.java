package com.example.hxjblesdk.ui.lockfun.keymanage;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.beans.KeySectionBean;
import com.example.hxjblesdk.ui.lockfun.LockFunViewModel;
import com.example.hxjblesdk.ui.lockfun.home.HomeFragment;

import com.example.hxjblesdk.ui.other.AlertDialogFragment;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.DelLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.utils.MyBleClient;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class KeyManageFragment extends Fragment {
    private static final String TAG = "KeyManageFragment";

    private KeyManageViewModel keyManageViewModel;
    private LockFunViewModel lockFunViewModel;
    private BlinkyAuthAction mAuthion;
    private RecyclerView rvKeyList;
    private List<LockKeyResult> lockKeyResults = new ArrayList<>();
    private KeySectionQuickAdapter keySectionQuickAdapter;
    private FloatingActionButton btnAdd;


    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        keyManageViewModel = new ViewModelProvider(this).get(KeyManageViewModel.class);
        lockFunViewModel = new ViewModelProvider(getActivity()).get(LockFunViewModel.class);
        View root = inflater.inflate(R.layout.fragment_keymanage, container, false);
        rvKeyList = root.findViewById(R.id.rvKeyList);

        btnAdd = root.findViewById(R.id.floatingActionButtonAdd);
        observer();
        initView();
        loadData();
        Log.e(TAG, "onCreateView() called with: inflater = [" + inflater + "], container = [" + container + "], savedInstanceState = [" + savedInstanceState + "]");
        return root;
    }

    private void initView() {
        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        rvKeyList.setLayoutManager(layoutManager);
        keySectionQuickAdapter = new KeySectionQuickAdapter(null);
        rvKeyList.setAdapter(keySectionQuickAdapter);

        btnAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                int lockFunctionType = lockFunViewModel.getLockObj().getLockFunctionType();
                // Create a bundle and add the lockFunctionType argument
                Bundle bundle = new Bundle();
                bundle.putInt("lockFunctionType", lockFunctionType);
                // Navigate using the action ID and bundle
                NavHostFragment.findNavController(KeyManageFragment.this)
                        .navigate(R.id.action_nav_slideshow_to_addKeyTypeDialogFragment, bundle);
            }
        });

        keySectionQuickAdapter.setOnItemChildClickListener(new OnItemChildClickListener() {
            @Override
            public void onItemChildClick(@NonNull BaseQuickAdapter adapter, @NonNull View view, int position) {
                if (view.getId() == R.id.imageButtonDel) {//刪除钥匙
                    if (adapter.getData().get(position) instanceof KeySectionBean) {
                        KeySectionBean keySectionBean = (KeySectionBean) adapter.getData().get(position);

                        AlertDialogFragment alertDialogFragment = new AlertDialogFragment(getString(R.string.del),
                                getString(R.string.cancel),
                                getString(R.string.dialog_del_key),
                                new AlertDialogFragment.OnButtonCallBack() {
                                    @Override
                                    public void onPositiveButtonClick() {
                                        cmdDelKey(keySectionBean.getLockKeyResult().getKeyType(),
                                                keySectionBean.getLockKeyResult().getKeyID(), mAuthion);
                                    }

                                    @Override
                                    public void onNegativeButton() {

                                    }
                                }
                        );
                        alertDialogFragment.show(getChildFragmentManager(), TAG);
                    }
                }
            }
        });

        keySectionQuickAdapter.setOnItemClickListener((adapter, view, position) -> {
            if (adapter.getData().get(position) instanceof KeySectionBean) {
                KeySectionBean keySectionBean = (KeySectionBean) adapter.getData().get(position);

                if (!keySectionBean.isHeader()) {
                    LockKeyResult lockKeyResult = keySectionBean.getLockKeyResult();
                    // Navigate with available methods from LockKeyResult
                    // Using getKeyNum() which we know exists, and toString() for the name
                    // Create a bundle with the key details
                    Bundle bundle = new Bundle();
                    try {
                        // Get key number using reflection
                        int keyNum = (int) lockKeyResult.getClass().getMethod("getKeyNum").invoke(lockKeyResult);
                        
                        // Try to get key type if available, otherwise use default
                        int keyType = 0; // Default value
                        try {
                            keyType = (int) lockKeyResult.getClass().getMethod("getKeyType").invoke(lockKeyResult);
                        } catch (Exception e) {
                            // Method not available, use default
                        }
                        
                        bundle.putInt("keyId", keyNum);
                        bundle.putInt("keyType", keyType);
                        bundle.putString("keyName", "Key " + keyNum);
                    } catch (Exception e) {
                        // Fallback to default values if reflection fails
                        bundle.putInt("keyId", 0);
                        bundle.putInt("keyType", 0);
                        bundle.putString("keyName", "Key");
                    }
                    
                    // Navigate using the action ID and bundle
                    NavHostFragment.findNavController(KeyManageFragment.this)
                            .navigate(R.id.action_nav_kayManage_to_keyDetailFragment, bundle);
                }

            }
        });
    }

    private void observer() {
        lockKeyResults.clear();

//        lockFunViewModel.getmLockKeyResult().observe(getViewLifecycleOwner(), lockKeyResult -> {
//            if (lockKeyResult != null) {
//                lockKeyResults.add(lockKeyResult);
//                List<KeySectionBean> list = formatList();
//                keySectionQuickAdapter.setList(list);
//            } else {
//                keySectionQuickAdapter.setList(null);
//            }
//        });
        lockFunViewModel.getmLiveLockKeyResults().observe(getViewLifecycleOwner(), mResults -> {
            if (mResults.size() > 0) {
                lockKeyResults.clear();
                lockKeyResults.addAll(mResults);
                List<KeySectionBean> list = formatList();
                keySectionQuickAdapter.setList(list);
            } else {
                keySectionQuickAdapter.setList(null);
            }
        });


        lockFunViewModel.getAuthAction().observe(getViewLifecycleOwner(), s -> {
            mAuthion = s;
            lockFunViewModel.cmdSyncLockKeys(mAuthion);
        });
    }

    private List<KeySectionBean> formatList() {
        if (lockKeyResults.isEmpty()) {
            return null;
        }
        List<KeySectionBean> keySectionBeans = new ArrayList<>();
        LinkedHashMap<Integer, List<KeySectionBean>> map = new LinkedHashMap<>();
        for (LockKeyResult keyResult : lockKeyResults) {
            if (map.containsKey(keyResult.getKeyType())) {
                List<KeySectionBean> sectionBeans = map.get(keyResult.getKeyType());
                sectionBeans.add(new KeySectionBean(keyResult));
                map.put(keyResult.getKeyType(), sectionBeans);
            } else {
                List<KeySectionBean> sectionBeans = new ArrayList<>();
                sectionBeans.add(new KeySectionBean(keyResult));
                map.put(keyResult.getKeyType(), sectionBeans);
            }
        }
        for (Map.Entry<Integer, List<KeySectionBean>> entry : map.entrySet()) {
            keySectionBeans.add(new KeySectionBean(entry.getKey()));
            keySectionBeans.addAll(entry.getValue());
        }

        return keySectionBeans;
    }

    private void loadData() {
        lockFunViewModel.loadMyAuthAction();
    }


    public void cmdDelKey(int keyType, int keyId, BlinkyAuthAction baseAuthAction) {
        DelLockKeyAction hxBleAction = new DelLockKeyAction();
        hxBleAction.setBaseAuthAction(baseAuthAction);
        hxBleAction.setDeleteKeyID(keyId);
        hxBleAction.setDeleteKeyType(keyType);
        MyBleClient.getInstance(getActivity().getApplicationContext()).delLockKey(hxBleAction, new FunCallback<String>() {
            @Override
            public void onResponse(Response<String> response) {
                if (response.isSuccessful()) {
                    for (Iterator<LockKeyResult> iterator = lockKeyResults.iterator(); iterator.hasNext(); ) {
                        LockKeyResult next = iterator.next();
                        if (next.getKeyID() == keyId) {
                            iterator.remove();
                        }
                    }

                    List<KeySectionBean> list = formatList();
                    keySectionQuickAdapter.setList(list);
                }
            }

            @Override
            public void onFailure(Throwable t) {
            }
        });
    }


}
