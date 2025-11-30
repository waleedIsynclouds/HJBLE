package com.example.hxjblesdk.db.lock;

import android.app.Application;

import androidx.lifecycle.LiveData;

import com.example.hxjblesdk.db.AppRoomDatabase;

import java.util.List;

public class LockRepository {
    private LockDao mLockDao;
    private LiveData<List<Lock>> mAllLocks;

    // Note that in order to unit test the WordRepository, you have to remove the Application
    // dependency. This adds complexity and much more code, and this sample is not about testing.
    // See the BasicSample in the android-architecture-components repository at
    // https://github.com/googlesamples
    public LockRepository(Application application) {
        AppRoomDatabase db = AppRoomDatabase.getDatabase(application);
        mLockDao = db.lockDao();
        mAllLocks = mLockDao.getAllLocks();
    }

    // Room executes all queries on a separate thread.
    // Observed LiveData will notify the observer when the data has changed.
    public LiveData<List<Lock>> getAllLocks() {
        return mAllLocks;
    }

    public LiveData<Lock> getLockByMac(String mac) {
        return mLockDao.getLocksByMac(mac);
    }

    // You must call this on a non-UI thread or your app will throw an exception. Room ensures
    // that you're not doing any long running operations on the main thread, blocking the UI.
    public void insert(Lock lock) {
        AppRoomDatabase.databaseWriteExecutor.execute(() -> {
            mLockDao.insert(lock);
        });
    }


    public void delLockWithMac(String lockMac) {
        AppRoomDatabase.databaseWriteExecutor.execute(() -> {
            mLockDao.delLockWithMac(lockMac);
        });
    }


}
