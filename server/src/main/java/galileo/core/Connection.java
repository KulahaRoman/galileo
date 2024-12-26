package galileo.core;

/**
 * Represents a connection with remote machine.
 *
 * @param <T> transferred data type
 */
public interface Connection<T> extends IncomingChannel<T>, OutgoingChannel<T> {
}
