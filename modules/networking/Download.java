import java.io.FileOutputStream;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;

public class Download implements Runnable {
    private String path;
    private URL url;
    public boolean isError = false;
    public static volatile int numRemaining;

    public Download(String path, String url) {
        this.path = path;
        try {
            this.url = new URL(url);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String getPath() {
        return this.path;
    }

    public void run() {
        this.run(false);
    }

    public void run(boolean stop) {
        try (ReadableByteChannel channel = Channels.newChannel(this.url.openStream());
                FileOutputStream stream = new FileOutputStream(this.path)) {
            stream.getChannel().transferFrom(channel, 0, Long.MAX_VALUE);
            Download.numRemaining--;
        } catch (Exception e) {
            if (!stop) {
                this.run(true);
            } else {
                this.isError = true;
                Download.numRemaining--;
            }
        }
    }
}