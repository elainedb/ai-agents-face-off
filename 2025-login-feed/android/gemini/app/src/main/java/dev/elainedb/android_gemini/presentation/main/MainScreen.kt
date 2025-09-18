package dev.elainedb.android_gemini.presentation.main

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import dev.elainedb.android_gemini.domain.youtube.YoutubeVideo

@Composable
fun MainScreen(
    mainViewModel: MainViewModel = hiltViewModel(),
    onLogout: () -> Unit
) {
    val uiState by mainViewModel.uiState.collectAsState()
    val context = LocalContext.current

    LaunchedEffect(Unit) {
        mainViewModel.getVideos()
    }

    Scaffold(
        bottomBar = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                Button(onClick = onLogout) {
                    Text("Logout")
                }
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when (val state = uiState) {
                is MainUiState.Loading -> {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator()
                    }
                }
                is MainUiState.Success -> {
                    LazyColumn(modifier = Modifier.fillMaxSize()) {
                        items(state.videos) { video ->
                            VideoItem(video = video, onClick = {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.videoId}"))
                                context.startActivity(intent)
                            })
                        }
                    }
                }
                is MainUiState.Error -> {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text(text = state.message)
                    }
                }
            }
        }
    }
}

@Composable
fun VideoItem(video: YoutubeVideo, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(16.dp)
    ) {
        AsyncImage(
            model = video.thumbnailUrl,
            contentDescription = null,
            modifier = Modifier.size(120.dp, 90.dp),
            contentScale = ContentScale.Crop
        )
        Spacer(modifier = Modifier.width(16.dp))
        Column {
            Text(text = video.title)
            Text(text = video.channelTitle)
            Text(text = video.publishedAt.substring(0, 10))
        }
    }
}
