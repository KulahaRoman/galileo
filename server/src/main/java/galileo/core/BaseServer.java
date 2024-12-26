package galileo.core;

import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;

@Slf4j
public abstract class BaseServer<T> implements Server<T> {
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

    private final Acceptor<T> acceptor;
    private final ConnectionHandlerFactory<T> connectionHandlerFactory;

    private final AtomicBoolean running = new AtomicBoolean(false);

    public BaseServer(Acceptor<T> acceptor, ConnectionHandlerFactory<T> connectionHandlerFactory) {
        this.acceptor = acceptor;
        this.connectionHandlerFactory = connectionHandlerFactory;
    }

    @Override
    public void run() throws Exception {
        log.info("Server started on port {}", acceptor.getPort());
        log.info("Waiting for connection...");

        running.set(true);
        try {
            while (running.get()) {
                var connection = acceptor.acceptConnection();
                var connectionHandler = connectionHandlerFactory.createConnectionHandler();

                log.debug("Connection accepted.");

                try {
                    executor.submit(() -> {
                        try {
                            connectionHandler.handleConnection(connection, executor);
                        } catch (Exception e) {
                            log.warn("Error while handling connection", e);
                        }
                    });
                } catch (Exception e) {
                    log.warn("Failed to submit connection handler", e);
                }
            }
        } catch (Exception e) {
            log.warn("Failed to accept connection", e);
        }
    }

    @Override
    public void close() throws Exception {
        running.set(false);

        acceptor.close();
        executor.close();
    }
}