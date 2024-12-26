package galileo.core;

/**
 * Represents a connection acceptor.
 *
 * @param <T> transferred data type
 */
public interface Acceptor<T> extends AutoCloseable {
    /**
     * Accepts incoming connections.<br>
     * The call to this method is blocking.
     *
     * @return accepted connection
     * @throws Exception
     */
    Connection<T> acceptConnection() throws Exception;


    /**
     * Returns assigned listening port.
     *
     * @return port
     */
    int getPort();
}
