using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;

public class GetPoedit{
    static string mo_data;
    static byte[] mo_byte;

    static Dictionary<string,string> getHash()
    {
        Dictionary<string, string> hash = new Dictionary<string, string>();

        string magic = mo_data.Substring(0, 3);
        int type;

        if(magic == @"\222\018\004\149")
        {
            type = 1;
        }
        else if (magic == @"\149\004\018\222")
        {
            type = 2;
        }
        else
        {
            return null;
        }

        return hash;
    }

    static int peek_long(int offset)
    {
        int a = mo_byte[offset];
        int b = mo_byte[offset + 1];
        int c = mo_byte[offset + 2];
        int d = mo_byte[offset + 3];

        return ((d * 256 + c) * 256 + b) * 256 + a;
    }

    [MenuItem("Tools/MO")]
    static void ReadFile()
    {
        string path = "Assets/LuaFramework/Lua/3rd/i18n/zh_TW.mo";
        using (FileStream stream = File.OpenRead(path))
        {
            mo_byte = new byte[stream.Length];

            for (int i = 0; i < mo_byte.Length; i++)
            {
                mo_byte[i] = (byte)stream.ReadByte();
            }

            mo_data = Encoding.Default.GetString(mo_byte);
            getHash();
        }
    }
}
