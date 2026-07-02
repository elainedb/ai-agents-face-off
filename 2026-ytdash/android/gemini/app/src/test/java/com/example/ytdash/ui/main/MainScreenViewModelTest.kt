package com.example.ytdash.ui.main

import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Test

class MainScreenViewModelTest {
  @Test
  fun uiState_initiallySuccess() = runTest {
    val viewModel = MainScreenViewModel()
    val state = viewModel.uiState.first()
    assert(state is MainScreenUiState.Success)
    assertEquals((state as MainScreenUiState.Success).data.size, 0)
  }
}
