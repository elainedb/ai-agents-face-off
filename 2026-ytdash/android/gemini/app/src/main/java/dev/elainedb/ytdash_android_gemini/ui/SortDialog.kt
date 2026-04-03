package dev.elainedb.ytdash_android_gemini.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import dev.elainedb.ytdash_android_gemini.viewmodel.SortOption

@Composable
fun SortDialog(
    currentSort: SortOption,
    onDismiss: () -> Unit,
    onApply: (SortOption) -> Unit
) {
    var selectedSort by remember { mutableStateOf(currentSort) }

    val sortOptions = listOf(
        SortOption.PUBLISHED_NEWEST to "Publication Date (Newest First)",
        SortOption.PUBLISHED_OLDEST to "Publication Date (Oldest First)",
        SortOption.RECORDED_NEWEST to "Recording Date (Newest First)",
        SortOption.RECORDED_OLDEST to "Recording Date (Oldest First)"
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sort Videos") },
        text = {
            Column {
                sortOptions.forEach { (option, label) ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedSort = option }
                            .padding(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedSort == option,
                            onClick = { selectedSort = option }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(label)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(selectedSort) }) {
                Text("Apply")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
