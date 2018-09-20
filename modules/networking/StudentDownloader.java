import java.util.LinkedList;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.Future;

public class StudentDownloader {
    private final LinkedList<Download> downloads;
    private static ThreadPoolExecutor exec;

    public static void main(String[] args) {

    }

    public static LinkedList<Download> download(StudentDownloader student) {
        StudentDownloader[] tmp = {student};
        return StudentDownloader.download(tmp);
    }

    public static LinkedList<Download> download(StudentDownloader[] students) {
        LinkedList<Download> downloads = new LinkedList<>();
        for (int j = 0; j < students.length; j++) {
            downloads.addAll(students[j].getDownloads());
        }

        Download.numRemaining = downloads.size();

        StudentDownloader.exec = (ThreadPoolExecutor) Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors() * 2);
        for (int i = 0; i < downloads.size(); i++) {
            exec.submit(downloads.get(i));
        }
        return downloads;
    }

    public StudentDownloader(String[] paths, String[] attachmentURLs) {
        this.downloads = new LinkedList<Download>();
        for (int i = 0; i < attachmentURLs.length; i++) {
            this.downloads.add(new Download(paths[i], attachmentURLs[i]));
        }
    }
    public LinkedList<Download> getDownloads() {
        return this.downloads;
    }
}