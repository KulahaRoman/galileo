package galileo.core;

public class SimpleIncomingChannel<T> implements IncomingChannel<T> {
    private final DataReader<T> reader;

    public SimpleIncomingChannel(DataReader<T> reader) {
        this.reader = reader;
    }

    @Override
    public T receiveData() throws Exception {
        return reader.readData();
    }

    @Override
    public void close() throws Exception {
        reader.close();
    }
}
