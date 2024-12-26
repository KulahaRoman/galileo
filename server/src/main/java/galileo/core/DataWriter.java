package galileo.core;

import java.io.Closeable;

public interface DataWriter<T> extends Closeable {
    void writeData(T data) throws Exception;
}