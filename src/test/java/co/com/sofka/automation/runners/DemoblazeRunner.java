package co.com.sofka.automation.runners;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

/**
 * Runner de la prueba. Aquí indico dónde están los features de Karate y dónde se guarda el
 * reporte HTML. Los features marcados con @ignore (helpers) no se ejecutan solos.
 */
class DemoblazeRunner {

    @Test
    void ejecutarPruebasDeApi() {
        Results resultados = Runner.path("classpath:co/com/sofka/automation/features")
                .reportDir("build/karate-reports")
                .parallel(1);
        assertEquals(0, resultados.getFailCount(), resultados.getErrorMessages());
    }
}
