package com.example.hxjblesdk.adapters;

import android.widget.CheckBox;

import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.beans.LockListBean;

import java.util.List;

public class OadLockListAdapter extends BaseQuickAdapter<LockListBean, BaseViewHolder> {


    public OadLockListAdapter(@Nullable List<LockListBean> data) {
        super(R.layout.oad_lock_recyclerview_item, data);
        addChildClickViewIds(R.id.checkBox);
    }


    @Override
    protected void convert(BaseViewHolder baseViewHolder, LockListBean lockListBean) {
        baseViewHolder.setText(R.id.textViewMac, lockListBean.getLock().getLockMac() + "");
        baseViewHolder.setText(R.id.tvDeviceType, lockListBean.getLock().getDeviceType() + "");
        baseViewHolder.setText(R.id.textView_hardver, lockListBean.getLock().getHardWareVer() + "");
        baseViewHolder.setText(R.id.textView_firmver, lockListBean.getLock().getSoftWareVer() + "");

        CheckBox checkBox = baseViewHolder.getView(R.id.checkBox);
        if (lockListBean.isSelect()) {
            checkBox.setChecked(true);
        } else {
            checkBox.setChecked(false);
        }
    }
}
