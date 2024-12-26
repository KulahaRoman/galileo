package galileo.core;

public interface Server<T> extends AutoCloseable {
    void run() throws Exception;
}
