import java.util.HashSet;
import javax.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UnsafeReflection {

    @GetMapping(value = "uf1")
    public void bad1(HttpServletRequest request) {
        String className = request.getParameter("className");
        String parameterValue = request.getParameter("parameterValue");
        try {
            Class clazz = Class.forName(className);
            Object object = clazz.getDeclaredConstructors()[0].newInstance(parameterValue); //bad
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping(value = "uf2")
    public void bad2(HttpServletRequest request) {
        String className = request.getParameter("className");
        String parameterValue = request.getParameter("parameterValue");
        try {
            ClassLoader classLoader = ClassLoader.getSystemClassLoader();
            Class clazz = classLoader.loadClass(className);
            Object object = clazz.newInstance();
            clazz.getDeclaredMethods()[0].invoke(object, parameterValue); //bad
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping(value = "uf3")
    public void bad3(HttpServletRequest request) {
        String className = request.getParameter("className");
        String parameterValue = request.getParameter("parameterValue");
        try {
            ClassLoader classLoader = ClassLoader.getSystemClassLoader();
            Class clazz = classLoader.loadClass(className);
            Object object = clazz.newInstance(); //bad
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping(value = "uf4")
    public void good1(HttpServletRequest request) throws Exception {
        HashSet<String> hashSet = new HashSet<>();
        hashSet.add("com.example.test1");
        hashSet.add("com.example.test2");
        String className = request.getParameter("className");
        String parameterValue = request.getParameter("parameterValue");
        if (!hashSet.contains(className)){ 
            throw new Exception("Class not valid: "  + className);
        }
        try {
            Class clazz = Class.forName(className);
            Object object = clazz.getDeclaredConstructors()[0].newInstance(parameterValue); //good
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping(value = "uf5")
    public void good2(HttpServletRequest request) throws Exception {
        String className = request.getParameter("className");
        String parameterValue = request.getParameter("parameterValue");
        if (!"com.example.test1".equals(className)){
            throw new Exception("Class not valid: "  + className);
        }
        try {
            Class clazz = Class.forName(className);
            Object object = clazz.getDeclaredConstructors()[0].newInstance(parameterValue); //good
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping(value = "uf6")
    public void good3(HttpServletRequest request) throws Exception {
        String className = request.getParameter("className");
        String parameterValue = request.getParameter("parameterValue");
        if (!className.equals("com.example.test1")){ //good
            throw new Exception("Class not valid: "  + className);
        }
        try {
            Class clazz = Class.forName(className);
            Object object = clazz.getDeclaredConstructors()[0].newInstance(parameterValue); //good
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
