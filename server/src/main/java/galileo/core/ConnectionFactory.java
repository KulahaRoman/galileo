package galileo.core;

public interface ConnectionFactory<T> {
    Connection<T> createNewConnection(IncomingChannel<T> incomingChannel,
                                      OutgoingChannel<T> outgoingChannel);
}
