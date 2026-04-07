package dev.elainedb.ytdash_android_gemini

import org.junit.Test
import org.junit.Assert.*
import java.sql.DriverManager

class SqliteOrderTest2 {
    @Test
    fun testSqliteOrderBy() {
        val connection = DriverManager.getConnection("jdbc:sqlite::memory:")
        val stmt = connection.createStatement()
        stmt.execute("CREATE TABLE videos (id INT, channelName TEXT, publishedAt TEXT, locationCountry TEXT)")
        stmt.execute("INSERT INTO videos VALUES (1, 'ChA', '2024-01-01', 'US'), (2, 'ChB', '2024-02-01', 'BR'), (3, 'ChA', '2024-03-01', 'BR')")
        
        var pstmt = connection.prepareStatement("SELECT * FROM videos WHERE (? IS NULL OR ? = 'All Channels' OR channelName = ?) ORDER BY CASE WHEN ? = 'asc' THEN publishedAt END ASC, CASE WHEN ? = 'desc' THEN publishedAt END DESC")
        pstmt.setString(1, null)
        pstmt.setString(2, null)
        pstmt.setString(3, null)
        pstmt.setString(4, "desc")
        pstmt.setString(5, "desc")
        
        var rs = pstmt.executeQuery()
        var results = mutableListOf<Int>()
        while (rs.next()) {
            results.add(rs.getInt("id"))
        }
        assertEquals(listOf(3, 2, 1), results)
        
        pstmt.setString(1, "ChA")
        pstmt.setString(2, "ChA")
        pstmt.setString(3, "ChA")
        pstmt.setString(4, "desc")
        pstmt.setString(5, "desc")
        
        rs = pstmt.executeQuery()
        results = mutableListOf<Int>()
        while (rs.next()) {
            results.add(rs.getInt("id"))
        }
        assertEquals(listOf(3, 1), results)
    }
}
