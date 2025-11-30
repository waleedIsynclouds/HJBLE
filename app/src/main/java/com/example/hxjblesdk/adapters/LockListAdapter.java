package com.example.hxjblesdk.adapters;

import android.graphics.Color;
import android.view.View;
import android.widget.CheckBox;

import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.beans.LockListBean;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;

import java.util.List;

public class LockListAdapter extends BaseQuickAdapter<LockListBean, BaseViewHolder> {


    public LockListAdapter(@Nullable List<LockListBean> data) {
        super(R.layout.lock_recyclerview_item, data);
    }


    @Override
    protected void convert(BaseViewHolder baseViewHolder, LockListBean lockListBean) {
        baseViewHolder.setText(R.id.textViewMac, lockListBean.getLock().getLockMac() + "");
        baseViewHolder.setText(R.id.tvDeviceType, lockListBean.getLock().getDeviceType() + "");
        baseViewHolder.setText(R.id.textView_hardver, "HardVer: " + lockListBean.getLock().getHardWareVer());
        baseViewHolder.setText(R.id.textView_firmver, "SoftVer: " + lockListBean.getLock().getSoftWareVer());

    }
}
