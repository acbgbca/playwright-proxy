package acbgbca.proxy;

import org.springframework.aot.hint.ExecutableMode;
import org.springframework.aot.hint.RuntimeHintsRegistrar;
import org.springframework.util.ReflectionUtils;

import com.microsoft.playwright.impl.driver.jar.DriverJar;

public class RuntimeHints implements RuntimeHintsRegistrar  {

    @Override
    public void registerHints(org.springframework.aot.hint.RuntimeHints hints, ClassLoader classLoader) {
        try {
            hints.reflection().registerConstructor(
                ReflectionUtils.accessibleConstructor(DriverJar.class),
                ExecutableMode.INVOKE);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
}
