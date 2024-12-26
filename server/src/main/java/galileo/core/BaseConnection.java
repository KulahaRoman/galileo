package galileo.core;

public abstract class BaseConnection<T> implements Connection<T> {
    private final IncomingChannel<T> incomingChannel;
    private final OutgoingChannel<T> outgoingChannel;

    public BaseConnection(IncomingChannel<T> incomingChannel,
                          OutgoingChannel<T> outgoingChannel) {
        this.incomingChannel = incomingChannel;
        this.outgoingChannel = outgoingChannel;
    }

    @Override
    public T receiveData() throws Exception {
        return incomingChannel.receiveData();
    }

    @Override
    public void sendData(T data) throws Exception {
        outgoingChannel.sendData(data);
    }

    @Override
    public void close() throws Exception {
        incomingChannel.close();
        outgoingChannel.close();
    }
}
