package galileo.core;

/**
 * Represents a receiving channel.
 *
 * @param <T> received data type
 */
public interface IncomingChannel<T> extends AutoCloseable {
    /**
     * Receives data from the incoming channel.<br>
     * The call to this method is blocking.
     *
     * @return received data
     * @throws Exception
     */
    T receiveData() throws Exception;
}
