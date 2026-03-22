package dev.elainedb.ytdash_android_gemini.ui.screen

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterDialog(
    currentChannel: String?,
    currentCountry: String?,
    availableChannels: List<String>,
    availableCountries: List<String>,
    onApply: (String?, String?) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedChannel by remember { mutableStateOf(currentChannel) }
    var selectedCountry by remember { mutableStateOf(currentCountry) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(text = "Filter Videos") },
        text = {
            LazyColumn {
                item {
                    Text("Channel", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(bottom = 8.dp))
                }
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedChannel = null }
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedChannel == null,
                            onClick = { selectedChannel = null }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("All Channels")
                    }
                }
                items(availableChannels) { channel ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedChannel = channel }
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedChannel == channel,
                            onClick = { selectedChannel = channel }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(channel)
                    }
                }

                item {
                    Spacer(modifier = Modifier.height(16.dp))
                    Text("Country", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(bottom = 8.dp))
                }
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedCountry = null }
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedCountry == null,
                            onClick = { selectedCountry = null }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("All Countries")
                    }
                }
                items(availableCountries) { country ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedCountry = country }
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedCountry == country,
                            onClick = { selectedCountry = country }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(country)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = { onApply(selectedChannel, selectedCountry) }
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
