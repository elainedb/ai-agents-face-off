package dev.elainedb.ytdash_android_gemini

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

@Composable
fun FilterDialog(
    countries: List<String>,
    channels: List<String>,
    onDismiss: () -> Unit,
    onApply: (String?, String?) -> Unit
) {
    var selectedChannel by remember { mutableStateOf<String?>("All Channels") }
    var selectedCountry by remember { mutableStateOf<String?>("All Countries") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text("Channel")
                LazyColumn(modifier = Modifier.height(100.dp)) {
                    item {
                        Row {
                            RadioButton(selected = selectedChannel == "All Channels", onClick = { selectedChannel = "All Channels" })
                            Text("All Channels", modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                        }
                    }
                    items(channels) { channel ->
                        Row {
                            RadioButton(selected = selectedChannel == channel, onClick = { selectedChannel = channel })
                            Text(channel, modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                        }
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
                Text("Country")
                LazyColumn(modifier = Modifier.height(100.dp)) {
                    item {
                        Row {
                            RadioButton(selected = selectedCountry == "All Countries", onClick = { selectedCountry = "All Countries" })
                            Text("All Countries", modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                        }
                    }
                    items(countries) { country ->
                        Row {
                            RadioButton(selected = selectedCountry == country, onClick = { selectedCountry = country })
                            Text(country, modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                        }
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
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun SortDialog(
    onDismiss: () -> Unit,
    onApply: (String) -> Unit
) {
    var selectedSort by remember { mutableStateOf("DATE_DESC") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sort Videos") },
        text = {
            Column {
                Row {
                    RadioButton(selected = selectedSort == "DATE_DESC", onClick = { selectedSort = "DATE_DESC" })
                    Text("Publication Date (Newest First)", modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                }
                Row {
                    RadioButton(selected = selectedSort == "DATE_ASC", onClick = { selectedSort = "DATE_ASC" })
                    Text("Publication Date (Oldest First)", modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                }
                Row {
                    RadioButton(selected = selectedSort == "REC_DESC", onClick = { selectedSort = "REC_DESC" })
                    Text("Recording Date (Newest First)", modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                }
                Row {
                    RadioButton(selected = selectedSort == "REC_ASC", onClick = { selectedSort = "REC_ASC" })
                    Text("Recording Date (Oldest First)", modifier = Modifier.padding(start = 8.dp, top = 12.dp))
                }
            }
        },
        confirmButton = {
            Button(onClick = { onApply(selectedSort) }) {
                Text("Apply")
            }
        },
        dismissButton = {
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
