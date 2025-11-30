package com.example.hxjblesdk.ui.lockfun.keymanage;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class KeyManageViewModel extends ViewModel {

    private MutableLiveData<String> mText;

    public KeyManageViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is slideshow fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }
}