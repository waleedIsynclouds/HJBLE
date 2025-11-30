package com.example.hxjblesdk.viewmodel;

import android.app.Application;

import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;

import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.db.lock.LockRepository;

import java.util.List;

public class LockViewModel extends AndroidViewModel {

    private LockRepository mRepository;
    private LiveData<List<Lock>> mAllLocks;


    public LockViewModel(Application application) {
        super(application);
        mRepository = new LockRepository(application);
        mAllLocks = mRepository.getAllLocks();
    }

    public LiveData<List<Lock>> getAllLocks() {
        return mAllLocks;
    }

    public LiveData<Lock> getLockByMac(String mac) {
        return mRepository.getLockByMac(mac);
    }


    public void insert(Lock lock) {
        mRepository.insert(lock);
    }

    public void delLockWithMac(String lockMac) {
        mRepository.delLockWithMac(lockMac);
    }
}