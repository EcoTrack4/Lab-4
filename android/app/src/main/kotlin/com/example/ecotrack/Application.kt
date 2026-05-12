package com.example.ecotrack

import android.app.Application
import androidx.multidex.MultiDexApplication

class Application : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
    }
}