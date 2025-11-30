package com.example.hxjblesdk.db.test;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import com.example.hxjblesdk.db.lock.Lock;

import java.util.List;

@Dao
public interface ConTimeDao {

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    void insert(ConTimeTest ConTimeTest);

    @Query("DELETE FROM contime_test_table")
    void deleteAll();

    @Query("SELECT * from contime_test_table ORDER BY lockMac ASC")
    LiveData<List<ConTimeTest>> getAlphabetizedWords();

    @Query("DELETE FROM contime_test_table where lockMac=:lockMac")
    void delLockWithMac(String lockMac);

}