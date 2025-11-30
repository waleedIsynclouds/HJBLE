package com.example.hxjblesdk.adapters;

import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.beans.LockListBean;

import java.util.List;

public class LockListTestAdapter extends BaseQuickAdapter<LockListBean, BaseViewHolder> {


    public LockListTestAdapter(@Nullable List<LockListBean> data) {
        super(R.layout.lock_recyclerview_item_test, data);
    }


    @Override
    protected void convert(BaseViewHolder baseViewHolder, LockListBean lockListBean) {
        baseViewHolder.setText(R.id.textViewMac, lockListBean.getLock().getLockMac() + "--->" + lockListBean.getLock().getLockName());
        baseViewHolder.setText(R.id.tvDeviceType, lockListBean.getLock().getDeviceType() + "");
        baseViewHolder.setText(R.id.textView_hardver, lockListBean.getLock().getHardWareVer() + "");
        baseViewHolder.setText(R.id.textView_firmver, lockListBean.getLock().getSoftWareVer() + "");

    }
}
