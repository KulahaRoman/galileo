package galileo.core;

import java.io.Closeable;

public interface DataReader<T> extends Closeable {
    T readData() throws Exception;
}
