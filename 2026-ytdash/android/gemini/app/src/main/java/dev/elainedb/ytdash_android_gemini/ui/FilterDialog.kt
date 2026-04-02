package dev.elainedb.ytdash_android_gemini.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun FilterDialog(
    currentChannel: String,
    currentCountry: String,
    channels: List<String>,
    countries: List<String>,
    onApply: (String, String) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedChannel by remember { mutableStateOf(currentChannel) }
    var selectedCountry by remember { mutableStateOf(currentCountry) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
                Text("By Channel", style = MaterialTheme.typography.titleMedium)
                channels.forEach { channel ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(
                            selected = (channel == selectedChannel),
                            onClick = { selectedChannel = channel }
                        )
                        Text(text = channel, modifier = Modifier.padding(start = 8.dp))
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text("By Country", style = MaterialTheme.typography.titleMedium)
                countries.forEach { country ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(
                            selected = (country == selectedCountry),
                            onClick = { selectedCountry = country }
                        )
                        Text(text = country, modifier = Modifier.padding(start = 8.dp))
                    }
                }
            }
        },
        confirmButton = {
            Button(onClick = { onApply(selectedChannel, selectedCountry) }) {
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
