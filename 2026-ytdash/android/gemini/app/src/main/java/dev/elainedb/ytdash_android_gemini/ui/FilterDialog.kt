package dev.elainedb.ytdash_android_gemini.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
    currentChannel: String?,
    currentCountry: String?,
    onDismiss: () -> Unit,
    onApply: (String?, String?) -> Unit
) {
    var selectedChannel by remember { mutableStateOf(currentChannel ?: "All Channels") }
    var selectedCountry by remember { mutableStateOf(currentCountry ?: "All Countries") }

    val allChannels = listOf("All Channels") + availableChannels
    val allCountries = listOf("All Countries") + availableCountries

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            LazyColumn {
                item { Text("Channel", modifier = Modifier.padding(vertical = 8.dp)) }
                items(allChannels) { channel ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedChannel = channel }
                            .padding(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = channel == selectedChannel,
                            onClick = { selectedChannel = channel }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(channel)
                    }
                }
                
                item { Text("Country", modifier = Modifier.padding(vertical = 8.dp)) }
                items(allCountries) { country ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedCountry = country }
                            .padding(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = country == selectedCountry,
                            onClick = { selectedCountry = country }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(country)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                onApply(
                    if (selectedChannel == "All Channels") null else selectedChannel,
                    if (selectedCountry == "All Countries") null else selectedCountry
                )
            }) {
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
