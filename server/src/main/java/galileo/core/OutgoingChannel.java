package galileo.core;

public interface OutgoingChannel<T> extends AutoCloseable {
    void sendData(T data) throws Exception;
}
