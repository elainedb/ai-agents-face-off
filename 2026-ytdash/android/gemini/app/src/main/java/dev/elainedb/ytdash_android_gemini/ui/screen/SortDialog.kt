package dev.elainedb.ytdash_android_gemini.ui.screen

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import dev.elainedb.ytdash_android_gemini.ui.viewmodel.SortOption

@Composable
fun SortDialog(
    currentSort: SortOption,
    onApply: (SortOption) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedSort by remember { mutableStateOf(currentSort) }

    val sortOptions = listOf(
        Pair(SortOption.PUB_NEWEST, "Publication Date (Newest First)"),
        Pair(SortOption.PUB_OLDEST, "Publication Date (Oldest First)"),
        Pair(SortOption.REC_NEWEST, "Recording Date (Newest First)"),
        Pair(SortOption.REC_OLDEST, "Recording Date (Oldest First)")
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(text = "Sort Videos") },
        text = {
            Column {
                sortOptions.forEach { (option, label) ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedSort = option }
                            .padding(vertical = 8.dp),
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
            TextButton(
                onClick = { onApply(selectedSort) }
            ) {
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
