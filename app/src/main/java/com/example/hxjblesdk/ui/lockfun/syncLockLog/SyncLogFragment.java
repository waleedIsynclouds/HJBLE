package com.example.hxjblesdk.ui.lockfun.syncLockLog;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.hxjblesdk.R;
import com.example.hxjblesdk.ui.lockfun.LockFunViewModel;
import com.example.hxjblinklibrary.blinkble.entity.EventResponse;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SyncLockRecordAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockRecordDataResult;
import com.example.hxjblinklibrary.blinkble.parser.open.EventSyncLogParser;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.utils.MyBleClient;

public class SyncLogFragment extends Fragment {
    private static final String TAG = "SyncLogFragment";
    private LockFunViewModel lockFunViewModel;
    private BlinkyAuthAction mAuthion;

    public SyncLogFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View inflate = inflater.inflate(R.layout.fragment_sync_log, container, false);
        lockFunViewModel = new ViewModelProvider(getActivity()).get(LockFunViewModel.class);
        lockFunViewModel.getText().observe(getViewLifecycleOwner(), s -> {
            Log.e(TAG, "onCreateView: lockFunViewModel" + s);
        });
        lockFunViewModel.getAuthAction().observe(getViewLifecycleOwner(), s -> {
            Log.e(TAG, "onCreateView: getAuthAction" + s);
            mAuthion = s;
            getRecordNum(mAuthion);
        });
        lockFunViewModel.loadMyAuthAction();
        return inflate;
    }

    public void getRecordNum(BlinkyAuthAction baseAuthAction) {
        BlinkyAction blinkyAction = new BlinkyAction();
        blinkyAction.setBaseAuthAction(baseAuthAction);
        MyBleClient.getInstance(getActivity().getApplicationContext()).getRecordNum(blinkyAction, new FunCallback<Integer>() {
            @Override
            public void onResponse(Response<Integer> response) {
                syncLockLog(baseAuthAction);
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private void syncLockLog(BlinkyAuthAction baseAuthAction) {
        Log.e(TAG, "syncLockRecordAction: ");
        SyncLockRecordAction syncLockRecordAction = new SyncLockRecordAction(0, 10);

        syncLockRecordAction.setBaseAuthAction(baseAuthAction);
        MyBleClient.getInstance(getActivity().getApplicationContext()).syncLockRecord(syncLockRecordAction, new FunCallback<LockRecordDataResult>() {
            public void onResponse(Response<LockRecordDataResult> response) {
                //根据不同的log类型进行解析显示不同的日志
                int recordType = response.body().getLockLogV2List().get(0).getRecordType();
                //事件类型和记录类型一致  EventResponse
                /**
                 * {@link com.example.hxjblinklibrary.blinkble.entity.EventResponse.KeyEventConstants}
                 */
                switch (recordType) {
                    case EventResponse.KeyEventConstants.LOCK_EVT_ADD_LOCK_KEY:
                        EventSyncLogParser.AddKey addKey = EventSyncLogParser.paraseAddKey(response.body().getLockLogV2List().get(0));
                        Log.d(TAG, "syncLockLog: parase = [" + addKey + "]");
                        break;
                    case EventResponse.KeyEventConstants.LOCK_EVT_OPEN_LOCK:
                        EventSyncLogParser.UnLock unLock = EventSyncLogParser.paraseUnlock(response.body().getLockLogV2List().get(0));
                        Log.d(TAG, "syncLockLog: parase = [" + unLock + "]");
                        break;
                }

            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }
}