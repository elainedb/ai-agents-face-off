package dev.elainedb.ytdash_android_gemini.ui.components

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.ui.viewmodel.VideoListUiState

@Composable
fun VideoListScreen(
    uiState: VideoListUiState,
    onRefresh: () -> Unit,
    onViewMap: () -> Unit,
    onFilterClick: () -> Unit,
    onSortClick: () -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Button(onClick = onRefresh) { Text("Refresh") }
            Button(onClick = onViewMap) { Text("View Map") }
            Button(onClick = onFilterClick) { Text("Filter") }
            Button(onClick = onSortClick) { Text("Sort") }
        }

        when (uiState) {
            is VideoListUiState.Loading -> {
                CircularProgressIndicator(modifier = Modifier.padding(16.dp))
            }
            is VideoListUiState.Empty -> {
                Text("No videos found.", modifier = Modifier.padding(16.dp))
            }
            is VideoListUiState.Error -> {
                Text("Error: ${uiState.message}", color = MaterialTheme.colorScheme.error, modifier = Modifier.padding(16.dp))
            }
            is VideoListUiState.Success -> {
                Text("Showing ${uiState.totalCount} videos", modifier = Modifier.padding(start = 16.dp, bottom = 8.dp))
                LazyColumn {
                    items(uiState.videos) { video ->
                        VideoItem(video = video)
                    }
                }
            }
        }
    }
}

@Composable
fun VideoItem(video: Video) {
    val context = LocalContext.current
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clickable {
                val appIntent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                try {
                    context.startActivity(appIntent)
                } catch (ex: Exception) {
                    context.startActivity(webIntent)
                }
            },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = "Thumbnail",
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = video.title, style = MaterialTheme.typography.titleMedium)
            Text(text = video.channelName, style = MaterialTheme.typography.bodyMedium)
            Text(text = "Published: ${video.publishedAt.take(10)}", style = MaterialTheme.typography.bodySmall)
            
            if (video.tags.isNotEmpty()) {
                Text(text = "Tags: ${video.tags.joinToString(", ")}", style = MaterialTheme.typography.bodySmall)
            }
            if (video.locationCity != null || video.locationCountry != null) {
                Text(text = "Location: ${video.locationCity ?: ""} ${video.locationCountry ?: ""} (${video.locationLatitude}, ${video.locationLongitude})", style = MaterialTheme.typography.bodySmall)
            }
            if (video.recordingDate != null) {
                Text(text = "Recorded: ${video.recordingDate.take(10)}", style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}
