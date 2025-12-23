package com.example.hxjblesdk.db.lock;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import com.example.hxjblesdk.db.lock.Lock;

import java.util.List;

/**
 * Marks the class as a Data Access Object. 
 * Data Access Objects are the main classes where you define your database interactions. 
 * They can include various query methods.
 */
@Dao
public interface LockDao {

    // allowing the insert of the same word multiple times by passing a
    // conflict resolution strategy
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(Lock lock);

    @Query("DELETE FROM lock_table")
    void deleteAll();

    @Query("SELECT * from lock_table")
    LiveData<List<Lock>> getAllLocks();

    @Query("SELECT * from lock_table where lock = :mac  ")
    LiveData<Lock> getLocksByMac(String mac);

    @Query("DELETE  FROM lock_table where lock=:lockMac")
    void delLockWithMac(String lockMac);
}