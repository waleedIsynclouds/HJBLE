package com.example.hxjblesdk.ui.lockfun.keymanage;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.hxjblesdk.R;

public class KeyDetailFragment extends Fragment {

    private static final String ARG_KEY_ID = "key_id";
    private static final String ARG_KEY_TYPE = "key_type";
    private static final String ARG_KEY_NAME = "key_name";
    
    private KeyDetailViewModel mViewModel;
    private TextView keyDetailTv;
    private int keyId;
    private int keyType;
    private String keyName;

    public static KeyDetailFragment newInstance(int keyId, int keyType, String keyName) {
        KeyDetailFragment fragment = new KeyDetailFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_KEY_ID, keyId);
        args.putInt(ARG_KEY_TYPE, keyType);
        args.putString(ARG_KEY_NAME, keyName);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            keyId = getArguments().getInt(ARG_KEY_ID);
            keyType = getArguments().getInt(ARG_KEY_TYPE);
            keyName = getArguments().getString(ARG_KEY_NAME);
        }
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View inflate = inflater.inflate(R.layout.key_detail_fragment, container, false);
        keyDetailTv = inflate.findViewById(R.id.key_detail_text);
        return inflate;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Display the key details
        String details = String.format("Key ID: %d\nKey Type: %d\nKey Name: %s", 
            keyId, keyType, keyName);
        keyDetailTv.setText(details);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(KeyDetailViewModel.class);
        // TODO: Use the ViewModel with the key details
    }
}