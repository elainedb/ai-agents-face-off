package dev.elainedb.ytdash_android_gemini

import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.findViewTreeViewModelStoreOwner
import androidx.savedstate.findViewTreeSavedStateRegistryOwner

fun test(view: View, activity: AppCompatActivity) {
    view.findViewTreeLifecycleOwner()
}
