/* vim: set expandtab tabstop=4 shiftwidth=4 : */

import java.io.*;
import java.util.*;

public class Tdf2JSON
{
    public static String bQa(final DataInputStream dataInputStream) throws Exception
    {
        final int readInt = dataInputStream.readInt();
        // System.out.println(readInt);
        final byte[] array = new byte[readInt];
        dataInputStream.read(array, 0, readInt);
        String s = new String(array);
        // System.out.println(readInt+" -> "+s);
        return s;
    }

    public static String ah_i_a(int x, final DataInputStream dataInputStream) throws Exception
    {
        String data;
        String output;
        // System.out.println("["+x+"]");
        output = " {\n   \"no\": "+x+",\n";
        //
        Integer ii = dataInputStream.readInt();
        // System.out.println("    "+ii);
        Double d = dataInputStream.readDouble();
        // System.out.println("    "+d);
        //
        data = "";
        for (int i = 0; i < 4; ++i) {
            final Float f0 = dataInputStream.readFloat();
            final Float f1 = dataInputStream.readFloat();
            data += f0+", "+f1+", ";
        }
        output += "   \"path\": [ "+data.substring(0,data.length()-2)+" ],\n";
        //
        Double a = dataInputStream.readDouble();
        while (a < 0.0f) {
            a += 6.283185307179586;
        }
        while (a > 6.283185307179586f) {
            a -= 6.283185307179586;
        }
        output += "   \"radians\": "+a+",\n";
        //
        data = "";
        for (int readInt = dataInputStream.readInt(), j = 0; j < readInt; ++j) {
            final int readInt2 = dataInputStream.readInt();
            data += readInt2+", ";
            // if (this.c != readInt2) {
            //     this.a(readInt2);
            // }
        }
        output += "   \"leads_to\": [ "+data.substring(0,data.length()-2)+" ],\n";
        Integer dd = dataInputStream.readInt();
        Integer e = dataInputStream.readInt();
        Integer f = dataInputStream.readInt();
        Double b = dataInputStream.readDouble();
        Double c = dataInputStream.readDouble();
        Integer h = dataInputStream.readInt();
        output += "   \"distance\": "+dd+",\n";
        output += "   \"in_front_of\": "+e+",\n";
        output += "   \"type\": "+f+",\n";
        output += "   \"center\": [ "+b+","+c+" ],\n";
        output += "   \"turn_idx\": "+h+",\n";
        // if (this.h > ah.a) {
        //     ah.a = this.h;
        // }
        Integer k = dataInputStream.readInt();
        Integer bb = dataInputStream.readInt();
        Integer g = dataInputStream.readInt();
        output += "   \"turn_stops\": "+k+",\n";
        output += "   \"grid_position\": "+bb+",\n";
        output += "   \"lane\": "+g+",\n";
        data = "";
        for (int readInt3 = dataInputStream.readInt(), w = 0; w < readInt3; ++w) {
            final int readInt4 = dataInputStream.readInt();
            data += readInt4+", ";
            // if (this.c != readInt4) {
            //     this.b(readInt4);
            // }
        }
        if (data.length()>2)
            output += "   \"adjacents\": [ "+data.substring(0,data.length()-2)+" ],\n";
        data = "";
        for (int l = 0; l < 4; ++l) {
            final int readInt5 = dataInputStream.readInt();
            data += readInt5+", ";
        }
        output += "   \"max_gear\": [ "+data.substring(0,data.length()-2)+" ],\n";
        Integer i = dataInputStream.readInt();
        output += "   \"next_in\": "+i+",\n";
        return output.substring(0,output.length()-2)+ "\n },\n";
    }

    public static void loadTdp(String path) throws Exception
    {
        System.out.println("  Read "+path+" ...");
        //
        final DataInputStream dataInputStream = new DataInputStream(new FileInputStream(path));
        bQa(dataInputStream);
        System.out.println(dataInputStream.readFloat());
        bQa(dataInputStream);
        bQa(dataInputStream);
        //
        dataInputStream.close();
    }

    public static void loadTdf(String path) throws Exception
    {
        System.out.println("  Read "+path+" ...");
        //
        final DataInputStream dataInputStream = new DataInputStream(new FileInputStream(path));
        String[] tokens = path.split("\\.(?=[^\\.]+$)");
        FileWriter fw = new FileWriter(tokens[0]+".json");
        BufferedWriter bw = new BufferedWriter(fw);
        //
        bQa(dataInputStream);
        // to perform checks
        String a = "";
        String a2 = "";
        final float readFloat = dataInputStream.readFloat();
        // data
        dataInputStream.readInt();
        dataInputStream.readInt();
        dataInputStream.readDouble();
        dataInputStream.readInt();
        // count
        final int readInt = dataInputStream.readInt();
        System.out.println("  cells : "+readInt);
        //
        if (readFloat > 0.1f) {
            a = bQa(dataInputStream);
        }
        bw.write("[\n");
        String content = "";
        for (int i = 0; i < readInt; ++i) {
            content += ah_i_a(i, dataInputStream);
            // final ah obj;
            // (obj = new ah(i)).a(dataInputStream);
            // c.addElement(obj);
        }
        bw.write(content.substring(1,content.length()-2)+"\n]\n");
        if (readFloat > 0.1f) {
            a2 = bQa(dataInputStream);
        }
        dataInputStream.close();
        bw.close();
        // if (readFloat > 0.1f && (substring.compareTo(a) != 0 || substring2.compareTo(a2) != 0)) {
        //     System.err.println("Errrorrrr");
        // }
    }

    public static void main(String [] args)
    {
        try {
            if (!new File(args[0]).exists()) {
                System.err.println(args[0]+" does not exists");
                System.exit(1);
            }
            // loadTdp(args[0]);
            loadTdf(args[0]);
            System.exit(0);
        }
        catch (Exception ex) {
            System.err.println("Something bad happend");
            System.exit(1);
        }
    }
}


