package com.example.hxjblesdk.ui.lockfun;

import android.os.Bundle;
import android.view.Menu;

import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.utils.MyBleClient;
import com.google.android.material.navigation.NavigationView;

import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

public class LockFunActivity extends AppCompatActivity {
    public static final String LOCK_INFO = "LOCK_INFO";
    private static final String TAG = "LockFunActivity";
    public static final String DEVICE = "com.example.hxjblesdk.ui.lockfun.device";

    private AppBarConfiguration mAppBarConfiguration;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LockFunViewModel lockFunViewModel = new ViewModelProvider(this).get(LockFunViewModel.class);
        Lock lockObj = getIntent().getParcelableExtra(LOCK_INFO);
        lockFunViewModel.setLockObj(lockObj);

        setContentView(R.layout.activity_main_fun);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        NavigationView navigationView = findViewById(R.id.nav_view);
        // Passing each menu ID as a set of Ids because each
        // menu should be considered as top level destinations.
        mAppBarConfiguration = new AppBarConfiguration.Builder(R.id.nav_home, R.id.nav_gallery, R.id.nav_sync_log, R.id.nav_kayManage)
                .setDrawerLayout(drawer)
                .build();
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        NavigationUI.setupActionBarWithNavController(this, navController, mAppBarConfiguration);
        NavigationUI.setupWithNavController(navigationView, navController);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
       //getMenuInflater().inflate(R.menu.menu_device_list, menu);
        return true;
    }

    @Override
    public boolean onSupportNavigateUp() {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        return NavigationUI.navigateUp(navController, mAppBarConfiguration)
                || super.onSupportNavigateUp();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //MyBleClient.getInstance(getApplication().getApplicationContext()).disConnectBle(null);
    }
}
