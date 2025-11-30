package com.example.hxjblesdk.db;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.migration.Migration;
import androidx.sqlite.db.SupportSQLiteDatabase;

import com.example.hxjblesdk.db.lock.LockDao;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.db.test.ConTimeDao;
import com.example.hxjblesdk.db.test.ConTimeTest;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Database(entities = {Lock.class, ConTimeTest.class}, version = 2, exportSchema = false)
public abstract class AppRoomDatabase extends RoomDatabase {

    private static Migration migration1_2;

    public abstract LockDao lockDao();

    public abstract ConTimeDao testDao();

    private static volatile AppRoomDatabase INSTANCE;
    private static final int NUMBER_OF_THREADS = 4;
    public static final ExecutorService databaseWriteExecutor = Executors.newFixedThreadPool(NUMBER_OF_THREADS);

    public static AppRoomDatabase getDatabase(final Context context) {
        if (INSTANCE == null) {
            synchronized (AppRoomDatabase.class) {
                if (INSTANCE == null) {
                    migration1_2 = new Migration(1, 2) {
                        @Override
                        public void migrate(@NonNull SupportSQLiteDatabase database) {
                        }
                    };
                    INSTANCE = Room.databaseBuilder(context.getApplicationContext(),
                            AppRoomDatabase.class, "ble_database")
                            .addCallback(sAppDatabaseCallback)
                            .build();
                }
            }
        }

        return INSTANCE;

    }


    private static AppRoomDatabase.Callback sAppDatabaseCallback = new RoomDatabase.Callback() {
        @Override
        public void onOpen(@NonNull SupportSQLiteDatabase db) {
            super.onOpen(db);

            // If you want to keep data through app restarts,
            // comment out the following block
            databaseWriteExecutor.execute(() -> {
                // If you want to start with more words, just add them.
                Log.d(TAG, "onOpen() called with: db = [" + db + "]");
            });
        }


    };
    private static final String TAG = "AppRoomDatabase";
}