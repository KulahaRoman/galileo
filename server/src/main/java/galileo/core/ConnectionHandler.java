package galileo.core;

import java.util.concurrent.ExecutorService;

@FunctionalInterface
public interface ConnectionHandler<T> {
    void handleConnection(Connection<T> connection, ExecutorService executor) throws Exception;
}
