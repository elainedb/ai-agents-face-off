package dev.elainedb.ytdash_android_gemini.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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

@Composable
fun FilterDialog(
    availableChannels: List<String>,
    availableCountries: List<String>,
    onDismiss: () -> Unit,
    onApply: (String?, String?) -> Unit
) {
    var selectedChannel by remember { mutableStateOf<String?>("All Channels") }
    var selectedCountry by remember { mutableStateOf<String?>("All Countries") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
                Text("Channels")
                listOf("All Channels") + availableChannels.forEach { channel ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(
                            selected = (channel == selectedChannel),
                            onClick = { selectedChannel = channel }
                        )
                        Text(channel)
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
                Text("Countries")
                listOf("All Countries") + availableCountries.forEach { country ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(
                            selected = (country == selectedCountry),
                            onClick = { selectedCountry = country }
                        )
                        Text(country)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(selectedChannel, selectedCountry) }) {
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
