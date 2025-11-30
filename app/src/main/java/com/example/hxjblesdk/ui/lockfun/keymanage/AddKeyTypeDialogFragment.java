package com.example.hxjblesdk.ui.lockfun.keymanage;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemClickListener;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.example.hxjblinklibrary.blinkble.profile.data.common.KeyType;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import androidx.navigation.fragment.NavHostFragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.hxjblesdk.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * <p>A fragment that shows a list of items as a modal bottom sheet.</p>
 * <p>You can show this modal bottom sheet from your activity like this:</p>
 * <pre>
 *     AddKeyTypeDialogFragment.newInstance(30).show(getSupportFragmentManager(), "dialog");
 * </pre>
 */
public class AddKeyTypeDialogFragment extends BottomSheetDialogFragment {

    private int lockFunctionType;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        lockFunctionType = AddKeyTypeDialogFragmentArgs.fromBundle(getArguments()).getLockFunctionType();
        return inflater.inflate(R.layout.fragment_add_key_type_dialog_list, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        final RecyclerView recyclerView = (RecyclerView) view;
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), 3));
        List<Integer> allKeyTypes = Arrays.asList(KeyType.FINGER, KeyType.PASSWORD, KeyType.CARD, KeyType.REMOTE, KeyType.Face);
        List<Integer> supportKeyTypes = new ArrayList<>();
        for (Integer keyType : allKeyTypes) {
            if ((lockFunctionType & keyType) == keyType) {
                supportKeyTypes.add(keyType);
            }
        }
        ItemAdapter adapter = new ItemAdapter(supportKeyTypes);
        recyclerView.setAdapter(adapter);
        adapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(@NonNull BaseQuickAdapter<?, ?> adapter, @NonNull View view, int position) {
                addKey((Integer) adapter.getData().get(position));
            }
        });
    }

    private void addKey(Integer keyType) {
        // Create a bundle and add the keyType argument
        Bundle bundle = new Bundle();
        bundle.putInt("keyType", keyType);
        // Navigate using the action ID and bundle
        NavHostFragment.findNavController(AddKeyTypeDialogFragment.this)
                .navigate(R.id.action_addKeyTypeDialogFragment_to_addKeyFragment, bundle);
    }


    private class ItemAdapter extends BaseQuickAdapter<Integer, BaseViewHolder> {
        public ItemAdapter(List<Integer> data) {
            super(R.layout.fragment_add_key_type_dialog_item, data);
        }

        @Override
        protected void convert(BaseViewHolder baseViewHolder, Integer keyType) {
            baseViewHolder.setText(R.id.text_key_type, keyType2KeyStr(keyType));
            int imageResId = getKeyTypeImageResId(keyType);
            baseViewHolder.setImageResource(R.id.imageView_icon, imageResId);
        }
    }

    private int getKeyTypeImageResId(int keyType) {
        int imageResId = 0;
        if (keyType == KeyType.FINGER) {
            imageResId = R.drawable.ic_fingerprint_24dp;
        }else if (keyType == KeyType.PASSWORD) {
            imageResId = R.drawable.ic_dialpad_24dp;
        }else if (keyType == KeyType.CARD) {
            imageResId = R.drawable.ic_credit_card_24dp;
        }else if (keyType == KeyType.REMOTE) {
            imageResId = R.drawable.ic_remote_24dp;
        }else if (keyType == KeyType.Face) {
            imageResId = R.drawable.face_icon;
        }else {
            imageResId = R.drawable.ic_key_24dp;
        }
        return imageResId;
    }


    private String keyType2KeyStr(Integer keyType) {
        switch (keyType) {
            case KeyType.FINGER:
                return getString(R.string.add_finger);
            case KeyType.PASSWORD:
                return getString(R.string.add_password);
            case KeyType.CARD:
                return getString(R.string.add_card);
            case KeyType.REMOTE:
                return getString(R.string.add_remoteControl);
            case KeyType.Face:
                return getString(R.string.addFace);
            default:
                return "OTHER";
        }
    }
}
