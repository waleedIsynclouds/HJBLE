package com.example.hxjblesdk.db.test;

import android.app.Application;

import androidx.lifecycle.LiveData;

import com.example.hxjblesdk.db.AppRoomDatabase;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.db.lock.LockDao;

import java.util.List;

public class TestRepository {
    private ConTimeDao conTimeDao;

    public TestRepository(Application application) {
        AppRoomDatabase db = AppRoomDatabase.getDatabase(application);
        conTimeDao = db.testDao();
    }

    public void insert(ConTimeTest lock) {
        AppRoomDatabase.databaseWriteExecutor.execute(() -> {
            conTimeDao.insert(lock);
        });
    }

    public void deleteAll() {
        AppRoomDatabase.databaseWriteExecutor.execute(() -> {
            conTimeDao.deleteAll();
        });
    }
}
