package galileo.core;

public class SimpleOutgoingChannel<T> implements OutgoingChannel<T> {
    private final DataWriter<T> writer;

    public SimpleOutgoingChannel(DataWriter<T> writer) {
        this.writer = writer;
    }

    @Override
    public void sendData(T data) throws Exception {
        writer.writeData(data);
    }

    @Override
    public void close() throws Exception {
        writer.close();
    }
}
