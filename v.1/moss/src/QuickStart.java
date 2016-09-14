import java.io.File;
import java.util.Collection;
import java.net.URL;
import org.apache.commons.io.FileUtils;
import it.zielke.moji.SocketClient;
import java.util.HashSet;

public class QuickStart {
    public static String similarityCheck(String mainDir, String baseDir) throws Exception {
        // a list of students' source code files located in the prepared
        // directory.
       // final String mainDir = System.getProperty("user.dir");
        //final String baseDir = "C:\\Users\\Peter\\Desktop\\Homework2\\base";
    

        Collection<File> files = FileUtils.listFiles(new File(
            mainDir), new String[] {"m"}, true);

        // a list of base files that was given to the students for this
        // assignment.
        Collection<File> baseFiles = FileUtils.listFiles(new File(
           baseDir), new String[] {"m"}, true);
        

        //get a new socket client to communicate with the Moss server
        //and set its parameters.
        SocketClient socketClient = new SocketClient();

        //set your Moss user ID
        socketClient.setUserID("156802855");
        //socketClient.setOpt...

        //set the programming language of all student source codes
        socketClient.setLanguage("matlab");

        //initialize connection and send parameters
        socketClient.run();

        //upload all base files
        for (File f : baseFiles) {
           socketClient.uploadBaseFile(f);
        }

        //upload all source files of students
        for (File f : files) {
            socketClient.uploadFile(f);
        }

        //finished uploading, tell server to check files
        socketClient.sendQuery();

        //get URL with Moss results and do something with it
        return socketClient.getResultURL().toString();
        
    }
}