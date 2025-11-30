package com.example.hxjblesdk.ui.lockfun.newfeature;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class NewFeatureViewModel extends ViewModel {

    private MutableLiveData<String> mText;

    public NewFeatureViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is gallery fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }
}