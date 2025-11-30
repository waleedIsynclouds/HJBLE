package com.example.hxjblesdk.ui.lockfun.keymanage;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.hxjblesdk.R;

public class ModifyKeyFragment extends Fragment {

    private ModifyKeyViewModel mViewModel;

    public static ModifyKeyFragment newInstance() {
        return new ModifyKeyFragment();
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.modify_key_fragment, container, false);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(ModifyKeyViewModel.class);
        // TODO: Use the ViewModel
    }

}