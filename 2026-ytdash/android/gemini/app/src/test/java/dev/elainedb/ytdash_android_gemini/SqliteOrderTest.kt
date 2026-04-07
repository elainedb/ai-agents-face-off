package dev.elainedb.ytdash_android_gemini

import org.junit.Test
import org.junit.Assert.*
import java.sql.DriverManager

class SqliteOrderTest {
    @Test
    fun testSqliteOrderBy() {
        val connection = DriverManager.getConnection("jdbc:sqlite::memory:")
        val stmt = connection.createStatement()
        stmt.execute("CREATE TABLE v (id INT, p INT, r INT)")
        stmt.execute("INSERT INTO v VALUES (1, 10, 20), (2, 5, 25), (3, 15, 15)")
        
        val rs = stmt.executeQuery("SELECT * FROM v ORDER BY CASE WHEN 'p'='p' THEN p END DESC, CASE WHEN 'p'='r' THEN r END ASC")
        val results = mutableListOf<Int>()
        while (rs.next()) {
            results.add(rs.getInt("id"))
        }
        assertEquals(listOf(3, 1, 2), results)
        
        val rs2 = stmt.executeQuery("SELECT * FROM v ORDER BY CASE WHEN 'r'='p' THEN p END DESC, CASE WHEN 'r'='r' THEN r END ASC")
        val results2 = mutableListOf<Int>()
        while (rs2.next()) {
            results2.add(rs2.getInt("id"))
        }
        assertEquals(listOf(3, 1, 2), results2) // wait, r ASC should be 15, 20, 25 so id 3, 1, 2
    }
}
