package __PACKAGE__;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class ProjectInfoTest {
    @Test
    void reportsProjectName() {
        assertEquals("__NAME__", ProjectInfo.name());
    }
}
