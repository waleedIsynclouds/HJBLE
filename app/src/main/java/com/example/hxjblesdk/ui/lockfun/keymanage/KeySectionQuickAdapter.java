package com.example.hxjblesdk.ui.lockfun.keymanage;

import android.util.Log;

import com.chad.library.adapter.base.BaseSectionQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.beans.KeySectionBean;
import com.example.hxjblinklibrary.blinkble.profile.data.common.KeyType;

import java.util.List;

public class KeySectionQuickAdapter extends BaseSectionQuickAdapter<KeySectionBean, BaseViewHolder> {
    private static final String TAG = "KeySectionQuickAdapter";

    /**
     * 构造方法里， super()必须设置 header layout
     * data可有可无
     */
    public KeySectionQuickAdapter(List<KeySectionBean> data) {
        super(R.layout.key_list_header_layout, data);
        setNormalLayout(R.layout.key_list_content_layout);
        addChildClickViewIds(R.id.imageButtonDel);
    }


    @Override
    protected void convertHeader(BaseViewHolder helper, KeySectionBean header) {
        if (header != null) {
            helper.setText(R.id.textView_header, header.getHeaderStr());
        }
    }

    @Override
    protected void convert(BaseViewHolder baseViewHolder, KeySectionBean keySectionBean) {
        if (keySectionBean != null) {
            Log.d(TAG, "convert() called with: baseViewHolder = [" + baseViewHolder + "], keySectionBean = [" + keySectionBean.getLockKeyResult().toString() + "]");

            baseViewHolder.setText(R.id.textView_keyName, "ID: " + keySectionBean.getLockKeyResult().getKeyID());
            int keyType = keySectionBean.getLockKeyResult().getKeyType();
            baseViewHolder.setImageResource(R.id.imageView_key_img,
                    keyType == KeyType.FINGER ? R.drawable.ic_fingerprint_24dp :
                            keyType == KeyType.PASSWORD ? R.drawable.ic_dialpad_24dp :
                                    keyType == KeyType.CARD ? R.drawable.ic_credit_card_24dp :
                                            keyType == KeyType.RANDOM_KEY ? R.drawable.ic_remote_24dp :
                                                    R.drawable.ic_key_24dp
            );
        }
    }
}