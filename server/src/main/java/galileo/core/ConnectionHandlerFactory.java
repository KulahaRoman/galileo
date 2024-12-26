package galileo.core;

public interface ConnectionHandlerFactory<T> {
    ConnectionHandler<T> createConnectionHandler();
}
