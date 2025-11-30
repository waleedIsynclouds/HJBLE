package com.example.hxjblesdk.adapters;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.beans.LockFunMenuBean;
import com.example.hxjblesdk.db.beans.LockListBean;

import java.util.List;

public class LockFunMenuAdapter extends BaseQuickAdapter<LockFunMenuBean, BaseViewHolder> {


    public LockFunMenuAdapter(@Nullable List<LockFunMenuBean> data) {
        super(R.layout.lock_fun_menu_item, data);
    }

    @Override
    protected void convert(@NonNull BaseViewHolder baseViewHolder, LockFunMenuBean lockFunMenuBean) {
        baseViewHolder.setImageResource(R.id.imageView_menu, lockFunMenuBean.getIconResId());
        baseViewHolder.setText(R.id.textView_menu, lockFunMenuBean.getName());

    }
}
