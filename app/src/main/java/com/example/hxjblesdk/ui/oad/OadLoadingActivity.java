package com.example.hxjblesdk.ui.oad;

import android.os.Bundle;

import com.example.hxjblesdk.db.beans.LockListBean;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.navigation.NavAction;
import androidx.navigation.NavArgument;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.fragment.NavHostFragment;

import android.os.Parcelable;
import android.view.View;

import com.example.hxjblesdk.R;

import java.util.ArrayList;

public class OadLoadingActivity extends AppCompatActivity {
    public static final String UP_DATA_LIST = "hxjblesdk.ui.oad.upDataList";
    private ArrayList<LockListBean> nextToUpdate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_oad_loading);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);


        nextToUpdate = getIntent().getParcelableArrayListExtra(UP_DATA_LIST);

        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        Bundle bundle = new Bundle();
        bundle.putParcelableArrayList(UP_DATA_LIST, nextToUpdate);
        navController.setGraph(R.navigation.nav_graph_oad, bundle);
    }




}
