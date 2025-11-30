package com.example.hxjblesdk.ui.other;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.hxjblesdk.R;


/**
 * A simple {@link Fragment} subclass.
 */
public class AlertDialogFragment extends DialogFragment {
    private final OnButtonCallBack onButtonCallBack;
    private String positiveButtonStr;
    private String negativeButtonStr;
    private String contentTextStr;


    public AlertDialogFragment(String positiveButtonStr, String negativeButtonStr, String contentTextStr,OnButtonCallBack onButtonCallBack ) {
        this.onButtonCallBack = onButtonCallBack;
        this.positiveButtonStr = positiveButtonStr;
        this.negativeButtonStr = negativeButtonStr;
        this.contentTextStr = contentTextStr;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_del_key_confirm, container, false);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }


    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        // Use the Builder class for convenient dialog construction
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setMessage(contentTextStr)
                .setPositiveButton(positiveButtonStr, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        // FIRE ZE MISSILES!
                        onButtonCallBack.onPositiveButtonClick();
                    }
                })
                .setNegativeButton(negativeButtonStr, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        // User cancelled the dialog
                        onButtonCallBack.onNegativeButton();
                    }
                });
        // Create the AlertDialog object and return it
        return builder.create();
    }

    public interface OnButtonCallBack {
        void onPositiveButtonClick();

        void onNegativeButton();
    }

}
